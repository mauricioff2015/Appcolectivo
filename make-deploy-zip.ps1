Param(
  [string]$OutputDir = "dist",
  [string]$ZipName = $null
)

Write-Host "Preparando ZIP de despliegue para Portainer..." -ForegroundColor Cyan

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $projectRoot

# Validar artefactos de Flutter Web
if (-not (Test-Path "build/web/index.html")) {
  Write-Error "No existe 'build/web'. Primero ejecuta: flutter build web --release (o usa Docker para compilar)."
  exit 1
}

$ts = Get-Date -Format 'yyyyMMdd_HHmmss'
if (-not $ZipName) { $ZipName = "colectivo-web_deploy_$ts.zip" }

$ctx = Join-Path -Path $OutputDir -ChildPath 'deploy_ctx'

if (Test-Path $ctx) { Remove-Item $ctx -Recurse -Force }
New-Item -ItemType Directory -Force -Path $ctx | Out-Null

# Copiar artefactos web
Copy-Item -Recurse -Force 'build/web' (Join-Path $ctx 'web')

# nginx.conf (usa el del repo si existe; si no, crea uno básico SPA)
$nginxConfDest = Join-Path $ctx 'nginx.conf'
if (Test-Path 'nginx.conf') {
  Copy-Item -Force 'nginx.conf' $nginxConfDest
} else {
  @'
server {
    listen 80;
    server_name _;
    root /usr/share/nginx/html;
    index index.html;
    location / {
        try_files $uri $uri/ /index.html;
    }
}
'@ | Set-Content -Path $nginxConfDest -NoNewline
}

# Dockerfile mínimo para servir el bundle con Nginx
$dockerfilePath = Join-Path $ctx 'Dockerfile'
@(
  'FROM nginx:stable-alpine',
  'COPY ./web /usr/share/nginx/html',
  'COPY nginx.conf /etc/nginx/conf.d/default.conf',
  'EXPOSE 80'
) | Set-Content -Path $dockerfilePath

# Comprimir
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
$zipPath = Join-Path -Path $OutputDir -ChildPath $ZipName
if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
Compress-Archive -Path (Join-Path $ctx '*') -DestinationPath $zipPath -Force

Write-Host "ZIP creado: $((Resolve-Path $zipPath).Path)" -ForegroundColor Green
Get-Item $zipPath | Select-Object FullName, Length

Write-Host "Sube este ZIP a Portainer: Images > Build a new image > Upload (URL/Upload build context)" -ForegroundColor Yellow
