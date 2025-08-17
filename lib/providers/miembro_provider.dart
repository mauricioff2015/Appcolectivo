import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/miembro.dart';
import '../services/data_service.dart';
import '../providers/auth_provider.dart';

// Provider para el servicio de miembros
final miembroServiceProvider = Provider<MiembroService>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return MiembroService(databaseService);
});

// Provider para estado de almacenamiento (persistente vs memoria)
final storageStatusProvider = FutureProvider<bool>((ref) async {
  final databaseService = ref.watch(databaseServiceProvider);
  return await databaseService.isPersistentStorage();
});

// Provider para la lista de miembros por territorio
final miembrosProvider = FutureProvider.family<List<Miembro>, String>((ref, territorio) async {
  final miembroService = ref.watch(miembroServiceProvider);
  return await miembroService.getMiembrosByTerritorio(territorio);
});

// Provider para búsqueda de miembros
final miembrosBusquedaProvider = FutureProvider.family<List<Miembro>, SearchParams>((ref, params) async {
  final miembroService = ref.watch(miembroServiceProvider);
  final noQuery = params.query.trim().isEmpty;
  final noFilters = params.sector == null &&
      params.trabajoMesas == null &&
      params.empleado == null &&
      params.trabajaraMesaGenerales2025 == null;

  if (noQuery && noFilters) {
    return await miembroService.getMiembrosByTerritorio(params.territorio);
  }

  return await miembroService.searchMiembrosAdvanced(
    territorio: params.territorio,
    query: noQuery ? null : params.query,
    sector: params.sector,
    trabajoMesas: params.trabajoMesas,
    empleado: params.empleado,
    trabajaraMesaGenerales2025: params.trabajaraMesaGenerales2025,
  );
});

class SearchParams {
  final String territorio;
  final String query;
  final String? sector;
  final bool? trabajoMesas;
  final bool? empleado;
  final bool? trabajaraMesaGenerales2025;

  SearchParams({
    required this.territorio,
    required this.query,
    this.sector,
    this.trabajoMesas,
    this.empleado,
    this.trabajaraMesaGenerales2025,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchParams &&
          runtimeType == other.runtimeType &&
          territorio == other.territorio &&
          query == other.query &&
          sector == other.sector &&
          trabajoMesas == other.trabajoMesas &&
          empleado == other.empleado &&
          trabajaraMesaGenerales2025 == other.trabajaraMesaGenerales2025;

  @override
  int get hashCode => Object.hash(
        territorio,
        query,
        sector,
        trabajoMesas,
        empleado,
        trabajaraMesaGenerales2025,
      );
}

class MiembroService {
  final DataService _databaseService;

  MiembroService(this._databaseService);

  Future<int> createMiembro(Miembro miembro) async {
    return await _databaseService.insertMiembro(miembro);
  }

  Future<List<Miembro>> getMiembrosByTerritorio(String territorio) async {
    return await _databaseService.getMiembrosByTerritorio(territorio);
  }

  Future<List<Miembro>> searchMiembrosByTerritorio(String territorio, String query) async {
    return await _databaseService.searchMiembrosByTerritorio(territorio, query);
  }

  Future<List<Miembro>> searchMiembrosAdvanced({
    required String territorio,
    String? query,
    String? sector,
    bool? trabajoMesas,
    bool? empleado,
    bool? trabajaraMesaGenerales2025,
  }) async {
    return await _databaseService.searchMiembrosAdvanced(
      territorio: territorio,
      query: query,
      sector: sector,
      trabajoMesas: trabajoMesas,
      empleado: empleado,
      trabajaraMesaGenerales2025: trabajaraMesaGenerales2025,
    );
  }

  Future<int> updateMiembro(Miembro miembro) async {
    return await _databaseService.updateMiembro(miembro);
  }

  Future<int> deleteMiembro(int id) async {
    return await _databaseService.deleteMiembro(id);
  }

  Future<bool> isDniExists(String dni, {int? excludeId}) async {
    return await _databaseService.isDniExists(dni, excludeId: excludeId);
  }
}
