# Colectivo - Sistema de Registro de Miembros

Una aplicación Flutter Web para registrar y gestionar miembros de un colectivo, con funcionalidades de autenticación, registro, búsqueda y administración de usuarios.

## Características

### 🔐 **Autenticación**
- Login con usuario y contraseña
- Validación contra base de datos SQLite local
- Roles: `admin` y `registrador`
- Territorio asignado por usuario

### 👥 **Gestión de Miembros**
- Formulario completo de registro
- Campos: nombre, DNI, fecha de nacimiento, género, teléfono, dirección, sector, profesión, etc.
- Territorio automático según usuario logueado
- Validación de DNI único
- Estados: activo/inactivo, empleado, trabajo en mesas, etc.

### 🔍 **Búsqueda Inteligente**
- Búsqueda en tiempo real por cualquier campo
- Filtros automáticos por territorio del usuario
- Vista detallada de miembros
- Edición y eliminación de registros

### 🛠 **Panel de Administración** (Solo Admin)
- Gestión completa de usuarios
- Crear, editar y eliminar usuarios
- Asignación de roles y territorios
- Vista de todos los usuarios del sistema

### 💾 **Persistencia Local**
- Base de datos SQLite embebida
- Compatible con Flutter Web usando `sqflite_common_ffi_web`
- No requiere servidor backend externo
- Datos almacenados localmente en el navegador

## Tecnologías Utilizadas

- **Flutter Web**: Framework principal
- **Riverpod**: Gestión de estado
- **SQLite**: Base de datos local
- **GoRouter**: Navegación
- **Material Design**: Interfaz de usuario

## Usuarios de Prueba

La aplicación incluye usuarios predeterminados:

| Usuario | Contraseña | Rol | Territorio |
|---------|------------|-----|------------|
| admin | admin123 | admin | Central |
| registrador1 | reg123 | registrador | Norte |

## Instalación y Desarrollo

Variables de entorno clave
- API_BASE_URL: URL del API que verá el navegador.
   - Ejemplos: http://TU_HOST:7009/api, https://tu-dominio/api
   - Por defecto en build Docker: http://colectivo-api:8080/api (útil detrás de proxy en misma red Docker)

### Prerrequisitos
- Flutter SDK (>= 3.8.1)
- Dart SDK
- Editor de código (VS Code recomendado)

### Pasos de instalación

1. **Clonar el repositorio**
```bash
git clone <repository-url>
cd colectivo
```

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Generar archivos de código**
```bash
flutter packages pub run build_runner build
```

4. **Ejecutar en desarrollo**
```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:7009/api
# o para web específicamente
flutter run -d web-server --web-port 8080 --dart-define=API_BASE_URL=http://localhost:7009/api
```

### Estructura del Proyecto

```
lib/
├── config/
│   └── router.dart          # Configuración de rutas
├── models/
│   ├── usuario_login.dart   # Modelo de usuario
│   └── miembro.dart         # Modelo de miembro
├── providers/
│   ├── auth_provider.dart   # Provider de autenticación
│   └── miembro_provider.dart # Provider de miembros
├── screens/
│   ├── login_screen.dart    # Pantalla de login
│   ├── dashboard_screen.dart # Dashboard principal
│   └── admin_screen.dart    # Panel de administración
├── services/
│   └── database_service.dart # Servicio de base de datos
├── widgets/
│   ├── miembro_form.dart    # Formulario de miembro
│   └── miembro_search.dart  # Búsqueda de miembros
└── main.dart               # Punto de entrada
```

## Despliegue con Docker

### Variables requeridas para despliegue
- API_BASE_URL: URL pública del API que consumirá el frontend en el navegador.
- (Si despliegas también el API .NET en su stack) SA_PASSWORD: contraseña del SQL Server.

### Construcción de la imagen (local)
```bash
docker build --build-arg API_BASE_URL=http://TU_HOST:7009/api -t colectivo-web .
```

### Ejecución con Docker
```bash
# Nginx sirve en 80 dentro del contenedor
docker run -d -p 8080:80 --name colectivo-web colectivo-web
```

### Usando Docker Compose
```bash
# API_BASE_URL debe pasarse en build-time (ARG) para que Flutter lo incruste en el bundle.
# Si usas docker-compose.yml (que compila la imagen), exporta la variable y ejecuta:
$env:API_BASE_URL = "http://TU_HOST:7009/api"   # PowerShell
docker-compose up -d --build
```

### Despliegue en VPS Linux

1. **Subir archivos al servidor**
```bash
scp -r . user@your-server:/path/to/colectivo/
```

2. **En el servidor, construir y ejecutar**
```bash
cd /path/to/colectivo/
docker-compose up -d
```

3. **Verificar el estado**
```bash
docker-compose ps
docker-compose logs colectivo
```

La aplicación estará disponible en `http://your-server:8080`

### Despliegue como Portainer Stack (imagen desde GitHub Container Registry)
1) Crear red externa (si no existe):
```bash
docker network create backend
```
2) Asegura que la imagen esté publicada (ver sección CI/CD). La imagen recomendada es:
```
ghcr.io/<tu_organizacion_o_usuario>/colectivo-web:latest
```
3) En Portainer > Stacks > Add stack > Git repository o Web editor:
- Usa el `docker-compose.portainer.yml` de este repo (o pega su contenido).
- Define variables:
   - IMAGE = ghcr.io/<owner>/colectivo-web:latest
   - API_BASE_URL = http://TU_HOST:7009/api
4) Deploy stack. Accede a: `http://TU_HOST:8080`

Archivo de stack recomendado: `docker-compose.portainer.yml`
```
version: "3.8"
services:
   colectivo:
      image: ${IMAGE}
      container_name: colectivo-web
      ports:
         - "8080:80"
      restart: unless-stopped
      environment:
         - NODE_ENV=production
         # Nota: En Flutter Web, API_BASE_URL es de build-time. Asegúrate que la imagen ya se construyó con el valor correcto,
         # o usa docker-compose.portainer-build.yml para que Portainer construya con ARG API_BASE_URL.
         - API_BASE_URL=${API_BASE_URL}
      healthcheck:
         test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:8080"]
         interval: 30s
         timeout: 10s
         retries: 3
         start_period: 40s
      networks:
         - backend

networks:
   backend:
      external: true
      name: backend
```

Importante: API_BASE_URL debe ser accesible desde el navegador del usuario (no uses nombres de servicio Docker salvo que tengas un reverse proxy resolviendo).

### CI/CD con GitHub Actions (publicar imagen en GHCR)
Este repo incluye `.github/workflows/docker-web.yml` que:
- Construye la imagen con `--build-arg API_BASE_URL`.
- Publica a `ghcr.io/<owner>/colectivo-web:latest`.

Configura en GitHub (Settings > Secrets and variables > Actions):
- vars.API_BASE_URL o secrets.API_BASE_URL (ej.: http://TU_HOST:7009/api)

Disparadores: push a main/master o tag `v*.*.*`, y manual (workflow_dispatch).

## Base de Datos

### Tablas

**usuarios_login**
- id (INTEGER, PK, AUTO_INCREMENT)
- usuario (TEXT, NOT NULL, UNIQUE)
- contrasena (TEXT, NOT NULL)
- rol (TEXT, NOT NULL) - 'admin' o 'registrador'
- territorio (TEXT, NOT NULL)

Si usas API .NET y SQL Server en Docker:
- Crea una red `backend` y conecta API y SQL en esa red.
- Ejemplo de cadena de conexión (en stack del API):
```
ConnectionStrings__Default=Server=sqlserver-express;Database=ColectivoDb;User Id=sa;Password=${SA_PASSWORD};TrustServerCertificate=True;Encrypt=False;
```

**miembros**
- id (INTEGER, PK, AUTO_INCREMENT)
- nombre (TEXT, NOT NULL)
- dni (TEXT, NOT NULL, UNIQUE)
- fecha_nacimiento (TEXT, NOT NULL)
- genero (TEXT, NOT NULL)
- telefono (TEXT, NOT NULL)
- direccion (TEXT, NOT NULL)
- fecha_registro (TEXT, NOT NULL)
- rol (TEXT, NOT NULL)
- activo (INTEGER, NOT NULL, DEFAULT 1)
- sector (TEXT, NOT NULL)
- profesion_oficio (TEXT, NOT NULL)
- trabajo_mesas (INTEGER, NOT NULL, DEFAULT 0)
- empleado (INTEGER, NOT NULL, DEFAULT 0)
- trabajara_mesa_generales_2025 (INTEGER, NOT NULL, DEFAULT 0)
- territorio (TEXT, NOT NULL)

## Funcionalidades Principales

### Flujo de Usuario Registrador
1. Login con credenciales
2. Acceso al dashboard con dos pestañas:
   - **Registrar Miembro**: Formulario completo
   - **Buscar Miembros**: Lista con búsqueda en tiempo real
3. Solo puede ver miembros de su territorio

### Flujo de Usuario Admin
1. Login con credenciales de admin
2. Acceso completo al dashboard
3. Panel de administración adicional:
   - Ver todos los usuarios
   - Crear nuevos usuarios
   - Editar usuarios existentes
   - Eliminar usuarios
   - Cambiar roles y territorios

### Validaciones Implementadas
- ✅ DNI único en el sistema
- ✅ Campos obligatorios marcados
- ✅ Formato de teléfono
- ✅ Fechas válidas
- ✅ Contraseñas mínimo 6 caracteres
- ✅ Usuarios únicos

## Mantenimiento

### Logs de la aplicación
```bash
docker-compose logs -f colectivo
```

### Backup de datos
Los datos se almacenan localmente en el navegador. Para backup:
1. Exportar datos desde la interfaz (feature a implementar)
2. O acceder directamente al localStorage del navegador

### Actualizar la aplicación
```bash
git pull
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

## Desarrollo Futuro

Posibles mejoras:
- [ ] Export/Import de datos
- [ ] Reportes y estadísticas
- [ ] Notificaciones
- [ ] Integración con APIs externas
- [ ] Modo offline completo
- [ ] Sincronización entre territorios

## Soporte

Para reportar bugs o solicitar nuevas funcionalidades, crear un issue en el repositorio del proyecto.

## Licencia

Este proyecto está bajo licencia MIT. Ver archivo LICENSE para más detalles.
