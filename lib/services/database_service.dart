import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite_common/sqlite_api.dart';
import '../models/usuario_login.dart';
import '../models/miembro.dart';
import 'data_service.dart';
import '../config/app_config.dart';

class DatabaseService implements DataService {
  static Database? _database;
  static const String _databaseName = 'colectivo.db';
  static const int _databaseVersion = 1;

  // Singleton
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Future<Database> get database async {
    if (_database == null) {
      await _initDatabase();
    }
    return _database!;
  }

  Future<void> _initDatabase() async {
    try {
      // Initialize the FFI for web
      final factory = databaseFactoryFfiWeb;
      
      _database = await factory.openDatabase(
        _databaseName,
        options: OpenDatabaseOptions(
          version: _databaseVersion,
          onCreate: _onCreate,
        ),
      );
      
      print('Database initialized successfully');
    } catch (e) {
      print('Error initializing database: $e');
      if (AppConfig.requirePersistentStorageWeb) {
        // No permitir fallback en Web si se requiere persistencia
        rethrow;
      }
      // Fallback: usar datos en memoria si SQLite falla
      await _initInMemoryData();
    }
  }

  // Fallback para datos en memoria si SQLite no funciona
  static final List<UsuarioLogin> _memoryUsuarios = [];
  static final List<Miembro> _memoryMiembros = [];
  static bool _memoryInitialized = false;
  static bool _useMemoryFallback = false;

  Future<void> _initInMemoryData() async {
    if (!_memoryInitialized) {
      _memoryUsuarios.clear();
      _memoryUsuarios.addAll([
        UsuarioLogin(
          id: 1,
          usuario: 'admin',
          contrasena: 'admin123',
          rol: 'admin',
          territorio: 'Central',
        ),
        UsuarioLogin(
          id: 2,
          usuario: 'registrador1',
          contrasena: 'reg123',
          rol: 'registrador',
          territorio: 'Norte',
        ),
      ]);
      _memoryInitialized = true;
      _useMemoryFallback = true;
      print('In-memory data initialized as fallback');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // Crear tabla usuarios_login
    await db.execute('''
      CREATE TABLE usuarios_login(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario TEXT NOT NULL UNIQUE,
        contrasena TEXT NOT NULL,
        rol TEXT NOT NULL,
        territorio TEXT NOT NULL
      )
    ''');

    // Crear tabla miembros
    await db.execute('''
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
      )
    ''');

    // Insertar usuario admin por defecto
    await db.insert('usuarios_login', {
      'usuario': 'admin',
      'contrasena': 'admin123',
      'rol': 'admin',
      'territorio': 'Central'
    });

    // Insertar usuario registrador por defecto
    await db.insert('usuarios_login', {
      'usuario': 'registrador1',
      'contrasena': 'reg123',
      'rol': 'registrador',
      'territorio': 'Norte'
    });
  }

  // Public status helpers
  bool get isUsingMemoryFallback => _useMemoryFallback;

  @override
  Future<bool> isPersistentStorage() async {
    try {
      // Ensure initialization
      await database;
      return !_useMemoryFallback;
    } catch (_) {
      return false;
    }
  }

  // CRUD para usuarios_login
  @override
  Future<int> insertUsuario(UsuarioLogin usuario) async {
    final db = await database;
    return await db.insert('usuarios_login', usuario.toMap());
  }

  @override
  Future<List<UsuarioLogin>> getAllUsuarios() async {
    try {
      if (_useMemoryFallback || _database == null) {
        await _initInMemoryData();
        return List<UsuarioLogin>.from(_memoryUsuarios);
      }
      
      final db = await database;
      final maps = await db.query('usuarios_login');
      return List.generate(maps.length, (i) => UsuarioLogin.fromMap(maps[i]));
    } catch (e) {
      print('Error en getAllUsuarios: $e');
      // Fallback to in-memory
      await _initInMemoryData();
      return List<UsuarioLogin>.from(_memoryUsuarios);
    }
  }

  @override
  Future<UsuarioLogin?> getUsuarioByCredentials(String usuario, String contrasena) async {
    try {
      if (_useMemoryFallback || _database == null) {
        await _initInMemoryData();
        return _memoryUsuarios.firstWhere(
          (u) => u.usuario == usuario && u.contrasena == contrasena,
          orElse: () => throw StateError('Usuario no encontrado'),
        );
      }
      
      final db = await database;
      final maps = await db.query(
        'usuarios_login',
        where: 'usuario = ? AND contrasena = ?',
        whereArgs: [usuario, contrasena],
      );

      if (maps.isNotEmpty) {
        return UsuarioLogin.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print('Error en getUsuarioByCredentials: $e');
      // Fallback to in-memory
      await _initInMemoryData();
      try {
        return _memoryUsuarios.firstWhere(
          (u) => u.usuario == usuario && u.contrasena == contrasena,
        );
      } catch (e2) {
        return null;
      }
    }
  }

  @override
  Future<int> updateUsuario(UsuarioLogin usuario) async {
    final db = await database;
    return await db.update(
      'usuarios_login',
      usuario.toMap(),
      where: 'id = ?',
      whereArgs: [usuario.id],
    );
  }

  @override
  Future<int> deleteUsuario(int id) async {
    final db = await database;
    return await db.delete(
      'usuarios_login',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CRUD para miembros
  @override
  Future<int> insertMiembro(Miembro miembro) async {
    try {
      if (_useMemoryFallback || _database == null) {
        await _initInMemoryData();
        final newId = _memoryMiembros.length + 1;
        final nuevoMiembro = miembro.copyWith(id: newId);
        _memoryMiembros.add(nuevoMiembro);
        return newId;
      }
      
      final db = await database;
      return await db.insert('miembros', miembro.toMap());
    } catch (e) {
      print('Error en insertMiembro: $e');
      // Fallback to in-memory
      await _initInMemoryData();
      _useMemoryFallback = true;
      final newId = _memoryMiembros.length + 1;
      final nuevoMiembro = miembro.copyWith(id: newId);
      _memoryMiembros.add(nuevoMiembro);
      return newId;
    }
  }

  @override
  Future<List<Miembro>> getMiembrosByTerritorio(String territorio) async {
    try {
      if (_useMemoryFallback || _database == null) {
        await _initInMemoryData();
        return _memoryMiembros.where((m) => m.territorio == territorio).toList();
      }
      
      final db = await database;
      final maps = await db.query(
        'miembros',
        where: 'territorio = ?',
        whereArgs: [territorio],
        orderBy: 'nombre ASC',
      );
      return List.generate(maps.length, (i) => Miembro.fromMap(maps[i]));
    } catch (e) {
      print('Error en getMiembrosByTerritorio: $e');
      // Fallback to in-memory
      await _initInMemoryData();
      _useMemoryFallback = true;
      return _memoryMiembros.where((m) => m.territorio == territorio).toList();
    }
  }

  @override
  Future<List<Miembro>> searchMiembrosByTerritorio(String territorio, String query) async {
    try {
      if (_useMemoryFallback || _database == null) {
        await _initInMemoryData();
        return _memoryMiembros
            .where((m) => m.territorio == territorio && m.matchesSearch(query))
            .toList();
      }
      
      final db = await database;
      final searchTerm = '%$query%';
      final maps = await db.query(
        'miembros',
        where: '''territorio = ? AND (
          nombre LIKE ? OR 
          dni LIKE ? OR 
          genero LIKE ? OR 
          telefono LIKE ? OR 
          direccion LIKE ? OR 
          rol LIKE ? OR 
          sector LIKE ? OR 
          profesion_oficio LIKE ?
        )''',
        whereArgs: [territorio, searchTerm, searchTerm, searchTerm, searchTerm, searchTerm, searchTerm, searchTerm, searchTerm],
        orderBy: 'nombre ASC',
      );
      return List.generate(maps.length, (i) => Miembro.fromMap(maps[i]));
    } catch (e) {
      print('Error en searchMiembrosByTerritorio: $e');
      // Fallback to in-memory
      await _initInMemoryData();
      _useMemoryFallback = true;
      return _memoryMiembros
          .where((m) => m.territorio == territorio && m.matchesSearch(query))
          .toList();
    }
  }

  @override
  Future<List<Miembro>> searchMiembrosAdvanced({
    required String territorio,
    String? query,
    String? sector,
    bool? trabajoMesas,
    bool? empleado,
    bool? trabajaraMesaGenerales2025,
  }) async {
    try {
      if (_useMemoryFallback || _database == null) {
        await _initInMemoryData();
        Iterable<Miembro> it = _memoryMiembros.where((m) => m.territorio == territorio);
        if (query != null && query.trim().isNotEmpty) {
          it = it.where((m) => m.matchesSearch(query));
        }
        if (sector != null && sector.trim().isNotEmpty) {
          final s = sector.toLowerCase();
          it = it.where((m) => m.sector.toLowerCase().contains(s));
        }
        if (trabajoMesas != null) {
          it = it.where((m) => m.trabajoMesas == trabajoMesas);
        }
        if (empleado != null) {
          it = it.where((m) => m.empleado == empleado);
        }
        if (trabajaraMesaGenerales2025 != null) {
          it = it.where((m) => m.trabajaraMesaGenerales2025 == trabajaraMesaGenerales2025);
        }
        final list = it.toList();
        list.sort((a, b) => a.nombre.compareTo(b.nombre));
        return list;
      }

      final db = await database;
      final whereClauses = <String>['territorio = ?'];
      final args = <Object?>[territorio];
      if (query != null && query.trim().isNotEmpty) {
        final term = '%${query.trim()}%';
        whereClauses.add('('
            'nombre LIKE ? OR dni LIKE ? OR genero LIKE ? OR telefono LIKE ? OR direccion LIKE ? OR rol LIKE ? OR sector LIKE ? OR profesion_oficio LIKE ?'
            ')');
        args.addAll([term, term, term, term, term, term, term, term]);
      }
      if (sector != null && sector.trim().isNotEmpty) {
        whereClauses.add('LOWER(sector) LIKE ?');
        args.add('%${sector.trim().toLowerCase()}%');
      }
      if (trabajoMesas != null) {
        whereClauses.add('trabajo_mesas = ?');
        args.add(trabajoMesas ? 1 : 0);
      }
      if (empleado != null) {
        whereClauses.add('empleado = ?');
        args.add(empleado ? 1 : 0);
      }
      if (trabajaraMesaGenerales2025 != null) {
        whereClauses.add('trabajara_mesa_generales_2025 = ?');
        args.add(trabajaraMesaGenerales2025 ? 1 : 0);
      }

      final maps = await db.query(
        'miembros',
        where: whereClauses.join(' AND '),
        whereArgs: args,
        orderBy: 'nombre ASC',
      );
      return List.generate(maps.length, (i) => Miembro.fromMap(maps[i]));
    } catch (e) {
      print('Error en searchMiembrosAdvanced: $e');
      await _initInMemoryData();
      _useMemoryFallback = true;
      return searchMiembrosAdvanced(
        territorio: territorio,
        query: query,
        sector: sector,
        trabajoMesas: trabajoMesas,
        empleado: empleado,
        trabajaraMesaGenerales2025: trabajaraMesaGenerales2025,
      );
    }
  }

  @override
  Future<int> updateMiembro(Miembro miembro) async {
    final db = await database;
    return await db.update(
      'miembros',
      miembro.toMap(),
      where: 'id = ?',
      whereArgs: [miembro.id],
    );
  }

  @override
  Future<int> deleteMiembro(int id) async {
    final db = await database;
    return await db.delete(
      'miembros',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<bool> isDniExists(String dni, {int? excludeId}) async {
    try {
      if (_useMemoryFallback || _database == null) {
        await _initInMemoryData();
        return _memoryMiembros.any((m) => 
            m.dni == dni && (excludeId == null || m.id != excludeId));
      }
      
      final db = await database;
      String whereClause = 'dni = ?';
      List<dynamic> whereArgs = [dni];
      
      if (excludeId != null) {
        whereClause += ' AND id != ?';
        whereArgs.add(excludeId);
      }
      
      final maps = await db.query(
        'miembros',
        where: whereClause,
        whereArgs: whereArgs,
      );
      
      return maps.isNotEmpty;
    } catch (e) {
      print('Error en isDniExists: $e');
      // Fallback to in-memory
      await _initInMemoryData();
      _useMemoryFallback = true;
      return _memoryMiembros.any((m) => 
          m.dni == dni && (excludeId == null || m.id != excludeId));
    }
  }

  @override
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
    }
  }
}
