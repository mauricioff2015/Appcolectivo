# Documentación Técnica - Sistema Colectivo

## Arquitectura de la Aplicación

### Patrón de Diseño
- **MVVM (Model-View-ViewModel)** implementado con Riverpod
- **Repository Pattern** para acceso a datos
- **Dependency Injection** mediante Riverpod providers
- **State Management** con Riverpod StateNotifier/FutureProvider

### Estructura de Capas

```
┌─────────────────────────────────────┐
│           UI LAYER                  │
│  (Screens & Widgets)               │
├─────────────────────────────────────┤
│         PROVIDER LAYER              │
│  (Riverpod Providers)              │
├─────────────────────────────────────┤
│        SERVICE LAYER                │
│  (Business Logic)                  │
├─────────────────────────────────────┤
│         DATA LAYER                  │
│  (Models & Database)               │
└─────────────────────────────────────┘
```

## Componentes Principales

### 1. Models (`lib/models/`)

#### `UsuarioLogin`
```dart
class UsuarioLogin {
  final int? id;
  final String usuario;
  final String contrasena;
  final String rol; // 'admin' | 'registrador'
  final String territorio;
}
```

#### `Miembro`
```dart
class Miembro {
  final int? id;
  final String nombre;
  final String dni;
  final DateTime fechaNacimiento;
  final String genero;
  final String telefono;
  final String direccion;
  final DateTime fechaRegistro;
  final String rol;
  final bool activo;
  final String sector;
  final String profesionOficio;
  final bool trabajoMesas;
  final bool empleado;
  final bool trabajaraMesaGenerales2025;
  final String territorio;
}
```

### 2. Services (`lib/services/`)

#### `DatabaseService`
Servicio singleton para manejo de SQLite con las siguientes responsabilidades:
- Inicialización de base de datos
- CRUD operations para usuarios y miembros
- Validaciones de integridad (DNI único)
- Búsquedas y filtros

**Métodos principales:**
```dart
// Usuarios
Future<int> insertUsuario(UsuarioLogin usuario)
Future<List<UsuarioLogin>> getAllUsuarios()
Future<UsuarioLogin?> getUsuarioByCredentials(String usuario, String contrasena)
Future<int> updateUsuario(UsuarioLogin usuario)
Future<int> deleteUsuario(int id)

// Miembros
Future<int> insertMiembro(Miembro miembro)
Future<List<Miembro>> getMiembrosByTerritorio(String territorio)
Future<List<Miembro>> searchMiembrosByTerritorio(String territorio, String query)
Future<int> updateMiembro(Miembro miembro)
Future<int> deleteMiembro(int id)
Future<bool> isDniExists(String dni, {int? excludeId})
```

### 3. Providers (`lib/providers/`)

#### `AuthProvider`
- `usuarioLogueadoProvider`: StateProvider<UsuarioLogin?>
- `databaseServiceProvider`: Provider<DatabaseService>
- `authServiceProvider`: Provider<AuthService>

#### `MiembroProvider`
- `miembroServiceProvider`: Provider<MiembroService>
- `miembrosProvider`: FutureProvider.family<List<Miembro>, String>
- `miembrosBusquedaProvider`: FutureProvider.family<List<Miembro>, SearchParams>

### 4. Screens (`lib/screens/`)

#### `LoginScreen`
- Formulario de autenticación
- Validación de credenciales
- Redirección por rol de usuario
- Manejo de errores de login

#### `DashboardScreen`
- TabBar con dos pestañas:
  - Registro de miembros
  - Búsqueda de miembros
- Control de acceso por rol
- Navegación contextual

#### `AdminScreen`
- CRUD completo de usuarios
- Lista de usuarios con filtros
- Modales para crear/editar usuarios
- Confirmaciones para eliminar

### 5. Widgets (`lib/widgets/`)

#### `MiembroForm`
- Formulario completo para miembros
- Validaciones en tiempo real
- Selector de fechas
- Checkboxes para flags booleanos
- Modo edición/creación

#### `MiembroSearch`
- Búsqueda en tiempo real
- Lista paginada de resultados
- Vista detallada en modal
- Opciones de editar/eliminar

## Base de Datos

### Esquema SQLite

#### Tabla `usuarios_login`
```sql
CREATE TABLE usuarios_login(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  usuario TEXT NOT NULL UNIQUE,
  contrasena TEXT NOT NULL,
  rol TEXT NOT NULL,
  territorio TEXT NOT NULL
);
```

#### Tabla `miembros`
```sql
CREATE TABLE miembros(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nombre TEXT NOT NULL,
  dni TEXT NOT NULL UNIQUE,
  fecha_nacimiento TEXT NOT NULL,
  genero TEXT NOT NULL,
  telefono TEXT NOT NULL,
  direccion TEXT NOT NULL,
  fecha_registro TEXT NOT NULL,
  rol TEXT NOT NULL,
  activo INTEGER NOT NULL DEFAULT 1,
  sector TEXT NOT NULL,
  profesion_oficio TEXT NOT NULL,
  trabajo_mesas INTEGER NOT NULL DEFAULT 0,
  empleado INTEGER NOT NULL DEFAULT 0,
  trabajara_mesa_generales_2025 INTEGER NOT NULL DEFAULT 0,
  territorio TEXT NOT NULL
);
```

### Índices Recomendados
```sql
-- Índices para mejorar rendimiento
CREATE INDEX idx_usuarios_login_credentials ON usuarios_login(usuario, contrasena);
CREATE INDEX idx_usuarios_territorio ON usuarios_login(territorio);
CREATE INDEX idx_miembros_dni ON miembros(dni);
CREATE INDEX idx_miembros_territorio ON miembros(territorio);
CREATE INDEX idx_miembros_activo ON miembros(activo);
CREATE INDEX idx_miembros_search ON miembros(territorio, activo, nombre);
```

## Routing

### Configuración con GoRouter
```dart
GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', name: 'login', builder: LoginScreen),
    GoRoute(path: '/dashboard', name: 'dashboard', builder: DashboardScreen),
    GoRoute(path: '/admin', name: 'admin', builder: AdminScreen),
  ],
)
```

### Guards de Autenticación
- Login requerido para `/dashboard` y `/admin`
- Rol admin requerido para `/admin`
- Redirección automática según rol

## Validaciones

### Cliente (Flutter)
- Campos obligatorios marcados con `*`
- Validación de formato DNI (7-8 dígitos)
- Validación de longitud de contraseña (min 6 caracteres)
- Validación de formato de teléfono
- Validación de fechas (no futuras para nacimiento)

### Base de Datos
- Constraints UNIQUE en DNI y usuario
- Constraints NOT NULL en campos requeridos
- Validación de integridad referencial

## Seguridad

### Consideraciones Actuales
- ⚠️ **Contraseñas en texto plano** (para demostración)
- ✅ Validación de roles en cada pantalla
- ✅ Filtrado por territorio automático
- ✅ Validaciones de entrada

### Recomendaciones para Producción
```dart
// Hash de contraseñas
import 'package:crypto/crypto.dart';

String hashPassword(String password) {
  final bytes = utf8.encode(password);
  final digest = sha256.convert(bytes);
  return digest.toString();
}
```

## Performance

### Optimizaciones Implementadas
- ✅ Lazy loading de listas de miembros
- ✅ Búsqueda debounced
- ✅ Índices en campos de búsqueda
- ✅ Providers con cache automático (Riverpod)
- ✅ Tree shaking de iconos

### Métricas Esperadas
- **Carga inicial**: < 3 segundos
- **Búsqueda**: < 500ms
- **Inserción/Actualización**: < 200ms
- **Tamaño bundle web**: < 2MB (gzipped)

## Testing

### Test Coverage
```bash
# Ejecutar tests
flutter test

# Coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Tipos de Tests
- **Unit Tests**: Modelos y servicios
- **Widget Tests**: Componentes UI
- **Integration Tests**: Flujos completos

## Deployment

### Ambientes

#### Desarrollo
```bash
flutter run -d chrome --web-port 8080
```

#### Producción
```bash
flutter build web --release
docker build -t colectivo-web .
docker run -p 8080:8080 colectivo-web
```

### CI/CD Pipeline Sugerido
```yaml
# .github/workflows/deploy.yml
name: Deploy
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test
      - run: flutter build web --release
      - run: docker build -t colectivo .
      - run: docker push registry/colectivo:latest
```

## Monitoreo

### Logs Recomendados
```dart
// En AppConfig
AppConfig.logInfo('Usuario logueado: ${usuario.usuario}');
AppConfig.logError('Error en login', error, stackTrace);
```

### Métricas a Monitorear
- Tiempo de carga de pantallas
- Errores de base de datos
- Usuarios activos por territorio
- Operaciones por minuto

## Extensibilidad

### Futuras Funcionalidades

#### Backup/Sincronización
```dart
abstract class BackupService {
  Future<void> exportData();
  Future<void> importData(String data);
  Future<void> syncWithServer();
}
```

#### Reportes
```dart
abstract class ReportService {
  Future<List<MiembroStats>> getMiembrosStats();
  Future<Uint8List> generatePdfReport();
  Future<String> generateCsvExport();
}
```

#### Notificaciones
```dart
abstract class NotificationService {
  Future<void> sendWelcomeNotification(Miembro miembro);
  Future<void> sendReminderNotification(List<Miembro> miembros);
}
```

### Plugin Architecture
La aplicación puede extenderse mediante:
- Custom providers para nuevas funcionalidades
- Widgets reutilizables
- Services intercambiables
- Configuración por ambiente

## Troubleshooting

### Problemas Comunes

#### SQLite Web Compatibility
```dart
// Solución implementada
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
databaseFactory = databaseFactoryFfiWeb;
```

#### Riverpod State Management
```dart
// Invalidar cache cuando sea necesario
ref.invalidate(miembrosProvider);
```

#### Build Web Errors
```bash
# Limpiar y reconstruir
flutter clean
flutter pub get
flutter build web --release
```

### Logs de Debug
```dart
// Habilitar logs detallados
flutter run --verbose
```

## Contacto y Soporte

Para reportes de bugs o consultas técnicas, crear issues en el repositorio del proyecto con:
- Descripción detallada del problema
- Pasos para reproducir
- Logs relevantes
- Versión de Flutter utilizada
