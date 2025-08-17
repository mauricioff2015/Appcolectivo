import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/usuario_login.dart';
import '../services/database_service.dart';
import '../services/remote_database_service.dart';
import '../services/data_service.dart';
import '../config/app_config.dart';

// Provider para el usuario logueado actual
final usuarioLogueadoProvider = StateProvider<UsuarioLogin?>((ref) => null);

// Provider para el servicio de base de datos
final databaseServiceProvider = Provider<DataService>((ref) {
  if (AppConfig.useRemoteApi) {
    return RemoteDatabaseService();
  }
  return DatabaseService();
});

// Provider para autenticación
final authServiceProvider = Provider<AuthService>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return AuthService(databaseService);
});

class AuthService {
  final DataService _databaseService;

  AuthService(this._databaseService);

  Future<UsuarioLogin?> login(String usuario, String contrasena) async {
    return await _databaseService.getUsuarioByCredentials(usuario, contrasena);
  }

  Future<List<UsuarioLogin>> getAllUsuarios() async {
    return await _databaseService.getAllUsuarios();
  }

  Future<int> createUsuario(UsuarioLogin usuario) async {
    return await _databaseService.insertUsuario(usuario);
  }

  Future<int> updateUsuario(UsuarioLogin usuario) async {
    return await _databaseService.updateUsuario(usuario);
  }

  Future<int> deleteUsuario(int id) async {
    return await _databaseService.deleteUsuario(id);
  }
}
