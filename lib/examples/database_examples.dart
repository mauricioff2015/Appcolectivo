// Ejemplos de uso del DatabaseService - Colectivo

import 'package:colectivo/services/database_service.dart';
import 'package:colectivo/models/usuario_login.dart';
import 'package:colectivo/models/miembro.dart';

/// Esta clase contiene ejemplos de cómo usar el DatabaseService
/// para operaciones CRUD con usuarios y miembros
class DatabaseExamples {
  final DatabaseService _db = DatabaseService();

  /// Ejemplo: Crear un nuevo usuario administrador
  Future<void> crearUsuarioAdmin() async {
    final admin = UsuarioLogin(
      usuario: 'nuevo_admin',
      contrasena: 'password123',
      rol: 'admin',
      territorio: 'Sur',
    );

    final id = await _db.insertUsuario(admin);
    print('Usuario admin creado con ID: $id');
  }

  /// Ejemplo: Crear un nuevo usuario registrador
  Future<void> crearUsuarioRegistrador() async {
    final registrador = UsuarioLogin(
      usuario: 'registrador_este',
      contrasena: 'reg456',
      rol: 'registrador',
      territorio: 'Este',
    );

    await _db.insertUsuario(registrador);
    print('Usuario registrador creado');
  }

  /// Ejemplo: Autenticar un usuario
  Future<void> autenticarUsuario() async {
    final usuario = await _db.getUsuarioByCredentials('admin', 'admin123');
    
    if (usuario != null) {
      print('Login exitoso: ${usuario.usuario} - ${usuario.rol}');
      print('Territorio: ${usuario.territorio}');
    } else {
      print('Credenciales inválidas');
    }
  }

  /// Ejemplo: Registrar un nuevo miembro
  Future<void> registrarMiembro() async {
    final miembro = Miembro(
      nombre: 'Juan Carlos Pérez',
      dni: '12345678',
      fechaNacimiento: DateTime(1980, 5, 15),
      genero: 'Masculino',
      telefono: '+54 9 11 1234-5678',
      direccion: 'Av. Libertador 1234, CABA',
      fechaRegistro: DateTime.now(),
      rol: 'Miembro',
      activo: true,
      sector: 'Educación',
      profesionOficio: 'Profesor',
      trabajoMesas: true,
      empleado: false,
      trabajaraMesaGenerales2025: true,
      territorio: 'Central',
    );

    final id = await _db.insertMiembro(miembro);
    print('Miembro registrado con ID: $id');
  }

  /// Ejemplo: Buscar miembros por territorio
  Future<void> buscarMiembrosPorTerritorio() async {
    final miembros = await _db.getMiembrosByTerritorio('Central');
    
    print('Miembros del territorio Central:');
    for (final miembro in miembros) {
      print('- ${miembro.nombre} (${miembro.dni}) - ${miembro.profesionOficio}');
    }
  }

  /// Ejemplo: Búsqueda de miembros con filtro
  Future<void> buscarMiembrosConFiltro() async {
    final miembros = await _db.searchMiembrosByTerritorio('Central', 'profesor');
    
    print('Miembros que coinciden con "profesor":');
    for (final miembro in miembros) {
      print('- ${miembro.nombre}: ${miembro.profesionOficio}');
    }
  }

  /// Ejemplo: Verificar si un DNI ya existe
  Future<void> verificarDni() async {
    final existe = await _db.isDniExists('12345678');
    
    if (existe) {
      print('El DNI ya está registrado');
    } else {
      print('El DNI está disponible');
    }
  }

  /// Ejemplo: Actualizar datos de un miembro
  Future<void> actualizarMiembro() async {
    // Primero obtener el miembro
    final miembros = await _db.getMiembrosByTerritorio('Central');
    if (miembros.isNotEmpty) {
      final miembro = miembros.first;
      
      // Actualizar datos
      final miembroActualizado = miembro.copyWith(
        telefono: '+54 9 11 9999-8888',
        direccion: 'Nueva dirección 456',
        sector: 'Salud',
      );

      await _db.updateMiembro(miembroActualizado);
      print('Miembro actualizado: ${miembro.nombre}');
    }
  }

  /// Ejemplo: Obtener estadísticas básicas
  Future<void> obtenerEstadisticas() async {
    // Obtener todos los usuarios
    final usuarios = await _db.getAllUsuarios();
    final admins = usuarios.where((u) => u.rol == 'admin').length;
    final registradores = usuarios.where((u) => u.rol == 'registrador').length;
    
    print('=== ESTADÍSTICAS ===');
    print('Total usuarios: ${usuarios.length}');
    print('Administradores: $admins');
    print('Registradores: $registradores');
    
    // Estadísticas por territorio
    final territorios = usuarios.map((u) => u.territorio).toSet();
    print('\nUsuarios por territorio:');
    for (final territorio in territorios) {
      final count = usuarios.where((u) => u.territorio == territorio).length;
      print('- $territorio: $count usuarios');
      
      // Miembros por territorio
      final miembros = await _db.getMiembrosByTerritorio(territorio);
      final activos = miembros.where((m) => m.activo).length;
      print('  Miembros: ${miembros.length} (Activos: $activos)');
    }
  }

  /// Ejemplo: Datos de prueba completos
  Future<void> insertarDatosPrueba() async {
    print('Insertando datos de prueba...');
    
    // Usuarios adicionales
    await _db.insertUsuario(UsuarioLogin(
      usuario: 'admin_sur',
      contrasena: 'admin123',
      rol: 'admin',
      territorio: 'Sur',
    ));

    await _db.insertUsuario(UsuarioLogin(
      usuario: 'reg_oeste',
      contrasena: 'reg123',
      rol: 'registrador',
      territorio: 'Oeste',
    ));

    // Miembros de prueba
    final miembrosPrueba = [
      Miembro(
        nombre: 'María González',
        dni: '23456789',
        fechaNacimiento: DateTime(1985, 3, 20),
        genero: 'Femenino',
        telefono: '+54 9 11 2222-3333',
        direccion: 'San Martín 567, Vicente López',
        fechaRegistro: DateTime.now(),
        rol: 'Delegado',
        activo: true,
        sector: 'Comercio',
        profesionOficio: 'Comerciante',
        trabajoMesas: true,
        empleado: true,
        trabajaraMesaGenerales2025: true,
        territorio: 'Norte',
      ),
      Miembro(
        nombre: 'Carlos Rodríguez',
        dni: '34567890',
        fechaNacimiento: DateTime(1978, 11, 8),
        genero: 'Masculino',
        telefono: '+54 9 11 4444-5555',
        direccion: 'Rivadavia 890, Morón',
        fechaRegistro: DateTime.now(),
        rol: 'Coordinador',
        activo: true,
        sector: 'Industria',
        profesionOficio: 'Mecánico',
        trabajoMesas: false,
        empleado: false,
        trabajaraMesaGenerales2025: false,
        territorio: 'Oeste',
      ),
      Miembro(
        nombre: 'Ana Martínez',
        dni: '45678901',
        fechaNacimiento: DateTime(1990, 7, 12),
        genero: 'Femenino',
        telefono: '+54 9 11 6666-7777',
        direccion: 'Belgrano 123, Quilmes',
        fechaRegistro: DateTime.now(),
        rol: 'Miembro',
        activo: true,
        sector: 'Salud',
        profesionOficio: 'Enfermera',
        trabajoMesas: true,
        empleado: true,
        trabajaraMesaGenerales2025: true,
        territorio: 'Sur',
      ),
    ];

    for (final miembro in miembrosPrueba) {
      await _db.insertMiembro(miembro);
    }

    print('Datos de prueba insertados correctamente');
  }

  /// Ejemplo: Limpiar todos los datos (excepto usuarios por defecto)
  Future<void> limpiarDatos() async {
    // Nota: SQLite no tiene TRUNCATE, habría que implementar DELETE
    // Este es solo un ejemplo de cómo se podría hacer
    print('Para limpiar datos, implementar DELETE queries');
    print('Por ejemplo: DELETE FROM miembros WHERE id > 0');
    print('Y: DELETE FROM usuarios_login WHERE usuario NOT IN (\'admin\', \'registrador1\')');
  }
}

// Ejemplo de uso:
void main() async {
  final examples = DatabaseExamples();
  
  try {
    await examples.crearUsuarioRegistrador();
    await examples.registrarMiembro();
    await examples.buscarMiembrosPorTerritorio();
    await examples.obtenerEstadisticas();
  } catch (e) {
    print('Error: $e');
  }
}
