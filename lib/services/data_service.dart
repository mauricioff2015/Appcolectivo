import '../models/miembro.dart';
import '../models/usuario_login.dart';

// Unified data service contract for local DB and remote API
abstract class DataService {
  // Status
  Future<bool> isPersistentStorage();

  // Usuarios
  Future<List<UsuarioLogin>> getAllUsuarios();
  Future<UsuarioLogin?> getUsuarioByCredentials(String usuario, String contrasena);
  Future<int> insertUsuario(UsuarioLogin usuario);
  Future<int> updateUsuario(UsuarioLogin usuario);
  Future<int> deleteUsuario(int id);

  // Miembros
  Future<int> insertMiembro(Miembro miembro);
  Future<List<Miembro>> getMiembrosByTerritorio(String territorio);
  Future<List<Miembro>> searchMiembrosByTerritorio(String territorio, String query);
  Future<List<Miembro>> searchMiembrosAdvanced({
    required String territorio,
    String? query,
    String? sector,
    bool? trabajoMesas,
    bool? empleado,
    bool? trabajaraMesaGenerales2025,
  });
  Future<int> updateMiembro(Miembro miembro);
  Future<int> deleteMiembro(int id);
  Future<bool> isDniExists(String dni, {int? excludeId});

  // Optional cleanup
  Future<void> close();
}
