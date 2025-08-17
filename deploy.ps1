# Script de despliegue para Colectivo - Flutter Web (Windows)
Write-Host "🚀 Iniciando despliegue de Colectivo..." -ForegroundColor Green

# Verificar que Flutter está instalado
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Flutter no está instalado. Por favor instale Flutter primero." -ForegroundColor Red
    exit 1
}

# Verificar que Docker está instalado
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Docker no está instalado. Por favor instale Docker primero." -ForegroundColor Red
    exit 1
}

Write-Host "✅ Verificaciones iniciales completadas" -ForegroundColor Green

# Obtener dependencias
Write-Host "📦 Obteniendo dependencias..." -ForegroundColor Yellow
flutter pub get

# Generar archivos de código
Write-Host "🔨 Generando archivos de código..." -ForegroundColor Yellow
flutter packages pub run build_runner build

# Analizar código
Write-Host "🔍 Analizando código..." -ForegroundColor Yellow
$analyzeResult = flutter analyze
if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️ Se encontraron warnings en el análisis, pero continuando..." -ForegroundColor Yellow
}

# Ejecutar tests
Write-Host "🧪 Ejecutando tests..." -ForegroundColor Yellow
flutter test

# Compilar para web
Write-Host "🏗️ Compilando aplicación para web..." -ForegroundColor Yellow
flutter build web --release

# Construir imagen Docker
Write-Host "🐳 Construyendo imagen Docker..." -ForegroundColor Yellow
docker build -t colectivo-web:latest .

# Verificar que la imagen se creó correctamente
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Imagen Docker creada exitosamente" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 Para ejecutar la aplicación:" -ForegroundColor Cyan
    Write-Host "   docker run -d -p 8080:8080 --name colectivo-web colectivo-web:latest" -ForegroundColor White
    Write-Host "   O usar: docker-compose up -d" -ForegroundColor White
    Write-Host ""
    Write-Host "🌐 La aplicación estará disponible en: http://localhost:8080" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "👥 Usuarios de prueba:" -ForegroundColor Cyan
    Write-Host "   Admin: admin / admin123" -ForegroundColor White
    Write-Host "   Registrador: registrador1 / reg123" -ForegroundColor White
    Write-Host ""
    Write-Host "🎉 Despliegue completado exitosamente!" -ForegroundColor Green
} else {
    Write-Host "❌ Error al construir la imagen Docker" -ForegroundColor Red
    exit 1
}
