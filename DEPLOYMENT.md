# Guía de Despliegue Rápido - Colectivo

## Opción 1: Despliegue Automático

### Windows
```powershell
.\deploy.ps1
```

### Linux/macOS
```bash
chmod +x deploy.sh
./deploy.sh
```

## Opción 2: Despliegue Manual

### 1. Preparar el entorno
```bash
flutter pub get
flutter packages pub run build_runner build
```

### 2. Compilar para web
```bash
flutter build web --release
```

### 3. Construir imagen Docker
```bash
docker build -t colectivo-web .
```

### 4. Ejecutar la aplicación
```bash
# Opción A: Docker directo
docker run -d -p 8080:8080 --name colectivo-web colectivo-web

# Opción B: Docker Compose
docker-compose up -d
```

## Opción 3: Desarrollo Local

```bash
flutter run -d chrome --web-port 8080
```

## Verificación

Abrir en el navegador: http://localhost:8080

### Usuarios de prueba:
- **Admin**: usuario: `admin`, contraseña: `admin123`
- **Registrador**: usuario: `registrador1`, contraseña: `reg123`

## Comandos Útiles

### Ver logs de la aplicación
```bash
docker-compose logs -f colectivo
```

### Detener la aplicación
```bash
docker-compose down
```

### Actualizar la aplicación
```bash
git pull
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### Acceder al contenedor
```bash
docker exec -it colectivo-web sh
```

### Limpiar imágenes Docker
```bash
docker system prune -f
docker rmi colectivo-web:latest
```

## Resolución de Problemas

### Puerto 8080 ocupado
```bash
# Cambiar puerto en docker-compose.yml
ports:
  - "8081:8080"  # Usar puerto 8081 en lugar de 8080
```

### Problemas con SQLite en Web
- La aplicación usa `sqflite_common_ffi_web` para compatibilidad web
- Los datos se almacenan localmente en el navegador
- Para reset completo: borrar datos del navegador (F12 > Application > Storage)

### Error de dependencias Flutter
```bash
flutter clean
flutter pub get
flutter packages pub run build_runner clean
flutter packages pub run build_runner build
```

### Error de permisos en Linux
```bash
sudo chown -R $USER:$USER .
chmod +x deploy.sh
```

## Despliegue en VPS

### 1. Subir archivos al servidor
```bash
rsync -avz --exclude node_modules . user@your-server:/path/to/colectivo/
```

### 2. En el servidor
```bash
cd /path/to/colectivo
docker-compose up -d
```

### 3. Configurar proxy reverso (Nginx)
```nginx
server {
    listen 80;
    server_name your-domain.com;
    
    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## Monitoreo

### Healthcheck
```bash
curl http://localhost:8080
```

### Status del contenedor
```bash
docker ps | grep colectivo
```

### Recursos utilizados
```bash
docker stats colectivo-web
```
