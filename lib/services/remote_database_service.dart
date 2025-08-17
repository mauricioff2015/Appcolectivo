import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/miembro.dart';
import '../models/usuario_login.dart';
import 'data_service.dart';

// A DataService implementation backed by a remote HTTP API
class RemoteDatabaseService implements DataService {
  final String baseUrl;
  final http.Client _client;

  RemoteDatabaseService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        baseUrl = (baseUrl ?? AppConfig.apiBaseUrl).replaceAll(RegExp(r'/+$'), '');

  Uri _u(String path, [Map<String, dynamic>? q]) {
    final p = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$baseUrl$p').replace(queryParameters: q?.map((k, v) => MapEntry(k, v?.toString())));
  }

  @override
  Future<bool> isPersistentStorage() async => true;

  // Usuarios
  @override
  Future<List<UsuarioLogin>> getAllUsuarios() async {
  final res = await _client.get(_u('/UsuariosLogin'));
  _ensureOk(res, 'GET /UsuariosLogin');
    final list = jsonDecode(res.body) as List<dynamic>;
    return list.map((e) => UsuarioLogin.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<UsuarioLogin?> getUsuarioByCredentials(String usuario, String contrasena) async {
  final res = await _client.get(_u('/UsuariosLogin'));
  _ensureOk(res, 'GET /UsuariosLogin');
    final list = (jsonDecode(res.body) as List<dynamic>)
        .map((e) => UsuarioLogin.fromJson(e as Map<String, dynamic>))
        .toList();
    try {
      return list.firstWhere((u) => u.usuario == usuario && u.contrasena == contrasena);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<int> insertUsuario(UsuarioLogin usuario) async {
  final payload = usuario.toJson();
  // Backend expects root object; force id: 0 on create
  payload['id'] = 0;
  // ignore: avoid_print
  print('API REQUEST [POST /UsuariosLogin]\n${jsonEncode(payload)}');
  final res = await _client.post(_u('/UsuariosLogin'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(payload));
  _ensureOk(res, 'POST /UsuariosLogin');
    final created = UsuarioLogin.fromJson(jsonDecode(res.body));
    return created.id ?? 0;
  }

  @override
  Future<int> updateUsuario(UsuarioLogin usuario) async {
    final id = usuario.id ?? 0;
  final payload = usuario.toJson();
  payload['id'] = id;
  // ignore: avoid_print
  print('API REQUEST [PUT /UsuariosLogin/$id]\n${jsonEncode(payload)}');
  final res = await _client.put(_u('/UsuariosLogin/$id'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(payload));
  _ensureOk(res, 'PUT /UsuariosLogin/$id');
    return id;
  }

  @override
  Future<int> deleteUsuario(int id) async {
  final res = await _client.delete(_u('/UsuariosLogin/$id'));
  _ensureOk(res, 'DELETE /UsuariosLogin/$id');
    return id;
  }

  // Miembros
  @override
  Future<int> insertMiembro(Miembro miembro) async {
  final payload = _miembroToApi(miembro);
  // Backend expects root object with id: 0 on create
  payload['id'] = 0;
  // ignore: avoid_print
  print('API REQUEST [POST /Miembros]\n${jsonEncode(payload)}');
  final res = await _client.post(_u('/Miembros'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload));
  _ensureOk(res, 'POST /Miembros');
    final created = Miembro.fromJson(jsonDecode(res.body));
    return created.id ?? 0;
  }

  @override
  Future<List<Miembro>> getMiembrosByTerritorio(String territorio) async {
    // No hay endpoint directo; usamos /Miembros y filtramos.
  final res = await _client.get(_u('/Miembros'));
  _ensureOk(res, 'GET /Miembros');
    final list = (jsonDecode(res.body) as List<dynamic>)
        .map((e) => Miembro.fromJson(e as Map<String, dynamic>))
        .where((m) => m.territorio == territorio)
        .toList();
    return list;
  }

  @override
  Future<List<Miembro>> searchMiembrosByTerritorio(String territorio, String query) async {
  final res = await _client.get(_u('/Miembros/search', {
      'territorio': territorio,
      'query': query,
    }));
  _ensureOk(res, 'GET /Miembros/search');
    final list = (jsonDecode(res.body) as List<dynamic>)
        .map((e) => Miembro.fromJson(e as Map<String, dynamic>))
        .toList();
    return list;
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
  final res = await _client.get(_u('/Miembros/search', {
      'territorio': territorio,
      if (query != null && query.isNotEmpty) 'query': query,
      if (sector != null && sector.isNotEmpty) 'sector': sector,
      if (trabajoMesas != null) 'trabajoMesas': trabajoMesas,
      if (empleado != null) 'empleado': empleado,
      if (trabajaraMesaGenerales2025 != null) 'trabajaraMesaGenerales2025': trabajaraMesaGenerales2025,
    }));
  _ensureOk(res, 'GET /Miembros/search');
    final list = (jsonDecode(res.body) as List<dynamic>)
        .map((e) => Miembro.fromJson(e as Map<String, dynamic>))
        .toList();
    return list;
  }

  @override
  Future<int> updateMiembro(Miembro miembro) async {
    final id = miembro.id ?? 0;
  final payload = _miembroToApi(miembro);
  // Ensure the payload id matches the path id
  payload['id'] = id;
  // ignore: avoid_print
  print('API REQUEST [PUT /Miembros/$id]\n${jsonEncode(payload)}');
  final res = await _client.put(_u('/Miembros/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload));
  _ensureOk(res, 'PUT /Miembros/$id');
    return id;
  }

  @override
  Future<int> deleteMiembro(int id) async {
  final res = await _client.delete(_u('/Miembros/$id'));
  _ensureOk(res, 'DELETE /Miembros/$id');
    return id;
  }

  @override
  Future<bool> isDniExists(String dni, {int? excludeId}) async {
  final res = await _client.get(_u('/Miembros'));
  _ensureOk(res, 'GET /Miembros');
    final list = (jsonDecode(res.body) as List<dynamic>)
        .map((e) => Miembro.fromJson(e as Map<String, dynamic>))
        .toList();
    return list.any((m) => m.dni == dni && (excludeId == null || m.id != excludeId));
  }

  @override
  Future<void> close() async {
    _client.close();
  }

  void _ensureOk(http.Response res, [String? context]) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      final ctx = context != null ? ' [$context]' : '';
      String details = res.body;
      try {
        final parsed = jsonDecode(res.body);
        if (parsed is Map<String, dynamic>) {
          final title = parsed['title'];
          final detail = parsed['detail'];
          final errors = parsed['errors'];
          final buf = StringBuffer();
          if (title != null) buf.writeln('title: $title');
          if (detail != null) buf.writeln('detail: $detail');
          if (errors is Map<String, dynamic>) {
            buf.writeln('errors:');
            errors.forEach((k, v) {
              if (v is List) {
                buf.writeln('  - $k: ${v.join('; ')}');
              } else {
                buf.writeln('  - $k: $v');
              }
            });
          }
          final s = buf.toString().trim();
          if (s.isNotEmpty) {
            details = s;
          }
        }
      } catch (_) {
        // keep raw body
      }
      final msg = 'API ERROR$ctx HTTP ${res.statusCode}\n$details';
      // Print in console for visibility during development
      // ignore: avoid_print
      print(msg);
      throw ApiException(res.statusCode, body: res.body, context: context, details: details);
    }
  }
  Map<String, dynamic> _miembroToApi(Miembro m) {
    final j = Map<String, dynamic>.from(m.toJson());
    // Validaciones según OpenAPI (Colectivo.Api)
    final nombre = (j['nombre'] as String?)?.trim() ?? '';
    if (nombre.isEmpty) {
      throw ArgumentError('El nombre es requerido');
    }
    if (nombre.length > 200) {
      throw ArgumentError('El nombre excede el máximo de 200 caracteres');
    }

    final dni = (j['dni'] as String?)?.trim() ?? '';
    final dniRegex = RegExp(r'^\d{13}$');
    if (!dniRegex.hasMatch(dni)) {
      throw ArgumentError('El DNI debe tener exactamente 13 dígitos');
    }

    j['nombre'] = nombre;
    j['dni'] = dni;

    // Normalizar cadenas opcionales: si vienen vacías -> null
    void nullIfEmpty(String key, {int? maxLen}) {
      final v = j[key];
      if (v is String) {
        final t = v.trim();
        if (t.isEmpty) {
          j[key] = null;
        } else {
          if (maxLen != null && t.length > maxLen) {
            throw ArgumentError('$key excede el máximo de $maxLen caracteres');
          }
          j[key] = t;
        }
      }
    }

    nullIfEmpty('genero', maxLen: 50);
    nullIfEmpty('telefono', maxLen: 50);
    nullIfEmpty('direccion', maxLen: 250);
    nullIfEmpty('rol', maxLen: 50);
    nullIfEmpty('sector', maxLen: 100);
    nullIfEmpty('profesionOficio', maxLen: 150);
    nullIfEmpty('territorio', maxLen: 100);

    // Asegurar ISO 8601 para fechas
    j['fechaNacimiento'] = m.fechaNacimiento.toIso8601String();
    j['fechaRegistro'] = m.fechaRegistro.toIso8601String();

  // Para POST: omitir id si es null o no entero para evitar errores de binding
  if (j['id'] == null || j['id'] is! int) {
      j.remove('id');
    }
    return j;
  }
}

/// Structured exception for API errors.
class ApiException implements Exception {
  final int statusCode;
  final String? body;
  final String? context;
  final String? details;
  ApiException(this.statusCode, {this.body, this.context, this.details});
  @override
  String toString() {
    final ctx = context != null ? ' [$context]' : '';
    return 'ApiException: HTTP $statusCode$ctx${details != null ? '\n$details' : ''}';
  }
}
