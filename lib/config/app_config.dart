// Configuración de entorno para la aplicación Colectivo
class AppConfig {
  // Información de la aplicación
  static const String appName = 'Colectivo';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Sistema de Registro de Miembros';
  
  // Configuración de base de datos
  static const String databaseName = 'colectivo.db';
  static const int databaseVersion = 1;
  
  // Límites de la aplicación
  static const int maxMiembrosPorTerritorio = 10000;
  static const int maxUsuarios = 100;
  static const int maxLongitudNombre = 100;
  static const int maxLongitudDireccion = 200;
  static const int minLongitudContrasena = 6;
  
  // Configuración de validación
  static const int minLongitudDni = 13;
  static const int maxLongitudDni = 13;
  static const int maxLongitudTelefono = 20;
  
  // Roles disponibles
  static const List<String> rolesDisponibles = ['admin', 'registrador'];
  static const List<String> rolesMiembro = ['Miembro', 'Delegado', 'Coordinador', 'Dirigente'];
  static const List<String> generosDisponibles = ['Masculino', 'Femenino', 'Otro'];
  
  // Territorios (pueden ser configurables según la implementación)
  static const List<String> territoriosDefault = [
    'Central',
    'Norte', 
    'Sur',
    'Este',
    'Oeste'
  ];
  
  // Configuración de interfaz
  static const double paddingStandard = 16.0;
  static const double borderRadius = 8.0;
  static const double elevationCard = 4.0;
  
  // Timeouts y límites de red (para futuras implementaciones)
  static const Duration timeoutDatabase = Duration(seconds: 10);
  static const Duration timeoutLogin = Duration(seconds: 5);
  
  // Configuración de desarrollo vs producción
  static const bool isDevelopment = bool.fromEnvironment('dart.vm.product') == false;
  static const bool enableDebugLogs = isDevelopment;
  static const bool enablePerformanceMonitoring = !isDevelopment;
  
  // Mensajes de la aplicación
  static const Map<String, String> mensajes = {
    'loginExitoso': 'Sesión iniciada correctamente',
    'loginFallido': 'Usuario o contraseña incorrectos',
    'miembroCreado': 'Miembro registrado exitosamente',
    'miembroActualizado': 'Miembro actualizado exitosamente',
    'miembroEliminado': 'Miembro eliminado exitosamente',
    'usuarioCreado': 'Usuario creado exitosamente',
    'usuarioActualizado': 'Usuario actualizado exitosamente',
    'usuarioEliminado': 'Usuario eliminado exitosamente',
    'dniDuplicado': 'Ya existe un miembro con ese DNI',
    'usuarioDuplicado': 'Ya existe un usuario con ese nombre',
    'camposObligatorios': 'Complete todos los campos obligatorios',
    'errorGeneral': 'Ocurrió un error inesperado',
    'confirmacionEliminar': '¿Está seguro que desea eliminar este registro?',
    'operacionCancelada': 'Operación cancelada',
    'sinResultados': 'No se encontraron resultados',
    'cargando': 'Cargando...',
  };
  
  // Configuración de formato de fecha
  static const String formatoFecha = 'dd/MM/yyyy';
  static const String formatoFechaHora = 'dd/MM/yyyy HH:mm';
  
  // Configuración de exportación (para futuras funcionalidades)
  static const List<String> formatosExportacion = ['CSV', 'Excel', 'PDF'];
  
  // Configuración de tema de la aplicación
  static const Map<String, dynamic> temaConfig = {
    'colorPrimario': 0xFF2196F3, // Azul
    'colorSecundario': 0xFF4CAF50, // Verde
    'colorError': 0xFFF44336, // Rojo
    'colorWarning': 0xFFFF9800, // Naranja
    'colorInfo': 0xFF2196F3, // Azul
    'colorExito': 0xFF4CAF50, // Verde
  };
  
  // URLs y endpoints (para futuras integraciones)
  static const String baseUrl = 'https://api.colectivo.com';
  static const String backupEndpoint = '/api/backup';
  static const String syncEndpoint = '/api/sync';
  
  // Configuración de backup automático (futuro)
  static const Duration intervalBackup = Duration(days: 7);
  static const int maxBackupsLocales = 5;
  
  // Validaciones específicas por región (ejemplo Argentina)
  static RegExp get regexDniArgentino => RegExp(r'^\d{13}$');
  static RegExp get regexTelefonoArgentino => RegExp(r'^(\+54\s?)?(\d{2,4}[\s\-]?)?\d{4}[\s\-]?\d{4}$');
  static RegExp get regexEmailBasico => RegExp(r'^[^@]+@[^@]+\.[^@]+$');
  
  // Métodos utilitarios
  static bool esRolValido(String rol) {
    return rolesDisponibles.contains(rol);
  }
  
  static bool esRolMiembroValido(String rol) {
    return rolesMiembro.contains(rol);
  }
  
  static bool esGeneroValido(String genero) {
    return generosDisponibles.contains(genero);
  }
  
  static bool esDniValido(String dni) {
    return regexDniArgentino.hasMatch(dni);
  }
  
  static bool esTelefonoValido(String telefono) {
    return regexTelefonoArgentino.hasMatch(telefono);
  }
  
  static String obtenerMensaje(String clave, [String valorDefault = '']) {
    return mensajes[clave] ?? valorDefault;
  }
  
  // Configuración de logs
  static void log(String mensaje, {String nivel = 'INFO'}) {
    if (enableDebugLogs) {
      final timestamp = DateTime.now().toIso8601String();
      print('[$timestamp] [$nivel] $mensaje');
    }
  }
  
  static void logError(String mensaje, [dynamic error, StackTrace? stackTrace]) {
    log('ERROR: $mensaje${error != null ? ' - $error' : ''}', nivel: 'ERROR');
    if (stackTrace != null && enableDebugLogs) {
      print(stackTrace);
    }
  }
  
  static void logInfo(String mensaje) {
    log(mensaje, nivel: 'INFO');
  }
  
  static void logWarning(String mensaje) {
    log(mensaje, nivel: 'WARNING');
  }

  // Persistencia en Web: si es true, no se permite fallback a memoria.
  static const bool requirePersistentStorageWeb = true;

  // API remota
  static const bool useRemoteApi = true; // Cambia a true para usar la API
  // Permite configurar la URL del API en tiempo de build con --dart-define=API_BASE_URL=...
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://colectivo-api:8080/api',
  );
}
