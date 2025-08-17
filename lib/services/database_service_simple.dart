import '../models/usuario_login.dart';
import '../models/miembro.dart';

/// Servicio de base de datos simplificado que usa memoria para Flutter Web
class DatabaseService {
  // Singleton
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal() {
    _initializeData();
  }

  // Datos en memoria
  static final List<UsuarioLogin> _usuarios = [];
  static final List<Miembro> _miembros = [];
  static int _nextUsuarioId = 1;
  static int _nextMiembroId = 1;
  static bool _initialized = false;

  void _initializeData() {
    if (_initialized) return;

    // Usuarios por defecto
    _usuarios.clear();
    _usuarios.addAll([
      UsuarioLogin(
        id: _nextUsuarioId++,
        usuario: 'admin',
        contrasena: 'admin123',
        rol: 'admin',
        territorio: 'Central',
      ),
      UsuarioLogin(
        id: _nextUsuarioId++,
        usuario: 'registrador1',
        contrasena: 'reg123',
        rol: 'registrador',
        territorio: 'Norte',
      ),
    ]);

    _initialized = true;
    print('DatabaseService initialized with in-memory data');
  }

  // Simular Future para mantener compatibilidad con la API
  Future<Database> get database async {
    return Future.value(Database());
  }

  // CRUD para usuarios_login
  Future<int> insertUsuario(UsuarioLogin usuario) async {
    try {
      final newId = _nextUsuarioId++;
      final nuevoUsuario = usuario.copyWith(id: newId);
      _usuarios.add(nuevoUsuario);
      print('Usuario creado: ${usuario.usuario}');
      return newId;
    } catch (e) {
      print('Error insertando usuario: $e');
      rethrow;
    }
  }

  Future<List<UsuarioLogin>> getAllUsuarios() async {
    try {
      return List<UsuarioLogin>.from(_usuarios);
    } catch (e) {
      print('Error obteniendo usuarios: $e');
      return [];
    }
  }

  Future<UsuarioLogin?> getUsuarioByCredentials(String usuario, String contrasena) async {
    try {
      print('Buscando usuario: $usuario con contraseña: $contrasena');
      final encontrado = _usuarios.where((u) => 
        u.usuario == usuario && u.contrasena == contrasena
      ).firstOrNull;
      
      if (encontrado != null) {
        print('Usuario encontrado: ${encontrado.usuario} - Rol: ${encontrado.rol}');
      } else {
        print('Usuario no encontrado. Usuarios disponibles:');
        for (final u in _usuarios) {
          print('  - ${u.usuario} / ${u.contrasena}');
        }
      }
      
      return encontrado;
    } catch (e) {
      print('Error en autenticación: $e');
      return null;
    }
  }

  Future<int> updateUsuario(UsuarioLogin usuario) async {
    try {
      final index = _usuarios.indexWhere((u) => u.id == usuario.id);
      if (index != -1) {
        _usuarios[index] = usuario;
        return 1;
      }
      return 0;
    } catch (e) {
      print('Error actualizando usuario: $e');
      rethrow;
    }
  }

  Future<int> deleteUsuario(int id) async {
    try {
      final index = _usuarios.indexWhere((u) => u.id == id);
      if (index != -1) {
        _usuarios.removeAt(index);
        return 1;
      }
      return 0;
    } catch (e) {
      print('Error eliminando usuario: $e');
      rethrow;
    }
  }

  // CRUD para miembros
  Future<int> insertMiembro(Miembro miembro) async {
    try {
      // Verificar DNI único
      if (_miembros.any((m) => m.dni == miembro.dni)) {
        throw Exception('Ya existe un miembro con el DNI ${miembro.dni}');
      }

      final newId = _nextMiembroId++;
      final nuevoMiembro = miembro.copyWith(id: newId);
      _miembros.add(nuevoMiembro);
      print('Miembro creado: ${miembro.nombre}');
      return newId;
    } catch (e) {
      print('Error insertando miembro: $e');
      rethrow;
    }
  }

  Future<List<Miembro>> getMiembrosByTerritorio(String territorio) async {
    try {
      final resultado = _miembros
          .where((m) => m.territorio == territorio)
          .toList();
      resultado.sort((a, b) => a.nombre.compareTo(b.nombre));
      return resultado;
    } catch (e) {
      print('Error obteniendo miembros por territorio: $e');
      return [];
    }
  }

  Future<List<Miembro>> searchMiembrosByTerritorio(String territorio, String query) async {
    try {
      final resultado = _miembros
          .where((m) => m.territorio == territorio && m.matchesSearch(query))
          .toList();
      resultado.sort((a, b) => a.nombre.compareTo(b.nombre));
      return resultado;
    } catch (e) {
      print('Error en búsqueda de miembros: $e');
      return [];
    }
  }

  Future<int> updateMiembro(Miembro miembro) async {
    try {
      final index = _miembros.indexWhere((m) => m.id == miembro.id);
      if (index != -1) {
        // Verificar DNI único (excluyendo el miembro actual)
        if (_miembros.any((m) => m.dni == miembro.dni && m.id != miembro.id)) {
          throw Exception('Ya existe un miembro con el DNI ${miembro.dni}');
        }
        _miembros[index] = miembro;
        return 1;
      }
      return 0;
    } catch (e) {
      print('Error actualizando miembro: $e');
      rethrow;
    }
  }

  Future<int> deleteMiembro(int id) async {
    try {
      final index = _miembros.indexWhere((m) => m.id == id);
      if (index != -1) {
        _miembros.removeAt(index);
        return 1;
      }
      return 0;
    } catch (e) {
      print('Error eliminando miembro: $e');
      rethrow;
    }
  }

  Future<bool> isDniExists(String dni, {int? excludeId}) async {
    try {
      return _miembros.any((m) => 
          m.dni == dni && (excludeId == null || m.id != excludeId));
    } catch (e) {
      print('Error verificando DNI: $e');
      return false;
    }
  }

  Future<void> close() async {
    // No action needed for in-memory storage
    print('DatabaseService closed');
  }

  // Métodos de debugging
  void printStatus() {
    print('=== DATABASE STATUS ===');
    print('Usuarios: ${_usuarios.length}');
    for (final u in _usuarios) {
      print('  - ${u.usuario} (${u.rol}) - ${u.territorio}');
    }
    print('Miembros: ${_miembros.length}');
    for (final m in _miembros) {
      print('  - ${m.nombre} (${m.dni}) - ${m.territorio}');
    }
    print('=======================');
  }
}

// Clase Database mock para mantener compatibilidad
class Database {
  // Mock class
}

extension ListExtension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
