import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:intl/intl.dart';

import '../models/miembro.dart';
import 'data_service.dart';
import 'export_saver_io.dart' if (dart.library.html) 'export_saver_web.dart';

/// Builds Excel workbooks for Miembros and exposes a helper to fetch filtered
/// data using DataService and return the Excel as bytes.
class ExportService {
  /// Default column headers for Miembro export.
  static const List<String> defaultHeaders = [
    'ID',
    'Nombre',
    'DNI',
    'Fecha Nacimiento',
    'Género',
    'Teléfono',
    'Dirección',
    'Fecha Registro',
    'Rol',
    'Activo',
    'Sector',
    'Profesión/Oficio',
    'Trabajo Mesas',
    'Empleado',
    'Trabajará Mesa Generales 2025',
    'Territorio',
  ];

  static final DateFormat _date = DateFormat('dd/MM/yyyy');

  /// Query miembros with filters and return an Excel workbook (bytes)
  /// with a header row and one row per member.
  static Future<Uint8List> exportMiembrosFilteredToExcelBytes({
    required DataService dataService,
    required String territorio,
    String? query,
    String? sector,
    bool? trabajoMesas,
    bool? empleado,
    bool? trabajaraMesaGenerales2025,
    String sheetName = 'Miembros',
    List<String>? headers,
  }) async {
    final miembros = await dataService.searchMiembrosAdvanced(
      territorio: territorio,
      query: query,
      sector: sector,
      trabajoMesas: trabajoMesas,
      empleado: empleado,
      trabajaraMesaGenerales2025: trabajaraMesaGenerales2025,
    );
    return buildMiembrosExcelBytes(
      miembros: miembros,
      sheetName: sheetName,
      headers: headers ?? defaultHeaders,
    );
  }

  /// Build an Excel workbook with the provided miembros and return it as bytes.
  static Uint8List buildMiembrosExcelBytes({
    required List<Miembro> miembros,
    List<String> headers = defaultHeaders,
    String sheetName = 'Miembros',
  }) {
    final excel = Excel.createExcel();
    final sheet = excel[sheetName];

  // Write header row (Excel 4.x expects List<CellValue?>)
  sheet.appendRow(headers.map((h) => TextCellValue(h)).toList());

    for (final m in miembros) {
      final row = _miembroToRow(m).map((v) => TextCellValue(v)).toList();
      sheet.appendRow(row);
    }

    // Remove default Sheet1 if we used another name
    if (sheetName != 'Sheet1' && excel.sheets.containsKey('Sheet1')) {
      excel.delete('Sheet1');
    }

    final bytes = excel.encode()!;
    return Uint8List.fromList(bytes);
  }

  /// Convenience: export filtered miembros and save to disk (desktop) or
  /// trigger a download (web). On web, [outputPathOrName] is used as the
  /// download file name; on desktop it can be a full path.
  static Future<void> exportAndSaveFiltered({
    required DataService dataService,
    required String territorio,
    String? query,
    String? sector,
    bool? trabajoMesas,
    bool? empleado,
    bool? trabajaraMesaGenerales2025,
    String sheetName = 'Miembros',
    List<String>? headers,
    required String outputPathOrName,
  }) async {
    final bytes = await exportMiembrosFilteredToExcelBytes(
      dataService: dataService,
      territorio: territorio,
      query: query,
      sector: sector,
      trabajoMesas: trabajoMesas,
      empleado: empleado,
      trabajaraMesaGenerales2025: trabajaraMesaGenerales2025,
      sheetName: sheetName,
      headers: headers,
    );
    await saveExcelBytes(bytes, fileNameOrPath: outputPathOrName);
  }

  static List<String> _miembroToRow(Miembro m) {
    String fmt(DateTime d) => _date.format(d);
    String yn(bool v) => v ? 'Sí' : 'No';
    return [
      (m.id ?? '').toString(),
      m.nombre,
      m.dni,
      fmt(m.fechaNacimiento),
      m.genero,
      m.telefono,
      m.direccion,
      fmt(m.fechaRegistro),
      m.rol,
      yn(m.activo),
      m.sector,
      m.profesionOficio,
      yn(m.trabajoMesas),
      yn(m.empleado),
      yn(m.trabajaraMesaGenerales2025),
      m.territorio,
    ];
  }
}
