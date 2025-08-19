import 'dart:math' as math;

import 'package:excel/excel.dart' as xls hide Border;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:universal_html/html.dart' as html;

import '../models/miembro.dart';
import '../providers/miembro_provider.dart';
import 'miembro_form.dart';

class MiembroSearch extends ConsumerStatefulWidget {
  final String territorio;

  const MiembroSearch({super.key, required this.territorio});

  @override
  ConsumerState<MiembroSearch> createState() => _MiembroSearchState();
}

class _MiembroSearchState extends ConsumerState<MiembroSearch> {
  final _searchController = TextEditingController();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  String _searchQuery = '';
  String? _sector;
  bool? _trabajoMesas;
  bool? _empleado;
  bool? _trabajaraMesaGenerales2025;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String q) => setState(() => _searchQuery = q);

  void _clearFilters() {
    setState(() {
      _sector = null;
      _trabajoMesas = null;
      _empleado = null;
      _trabajaraMesaGenerales2025 = null;
    });
  }

  Future<void> _exportToExcel(List<Miembro> miembros) async {
    try {
      final ex = xls.Excel.createExcel();
      final sheetName = 'Miembros';
      final sheet = ex[sheetName];
      if (ex.sheets.containsKey('Sheet1')) {
        ex.delete('Sheet1');
      }

      final headers = <xls.CellValue?>[
        xls.TextCellValue('ID'),
        xls.TextCellValue('Nombre'),
        xls.TextCellValue('DNI'),
        xls.TextCellValue('Fecha Nacimiento'),
        xls.TextCellValue('Género'),
        xls.TextCellValue('Teléfono'),
        xls.TextCellValue('Dirección'),
        xls.TextCellValue('Fecha Registro'),
        xls.TextCellValue('Rol'),
        xls.TextCellValue('Activo'),
        xls.TextCellValue('Sector'),
        xls.TextCellValue('Profesión/Oficio'),
        xls.TextCellValue('Trabajó Mesas'),
        xls.TextCellValue('Empleado'),
        xls.TextCellValue('Trabajará Mesa 2025'),
        xls.TextCellValue('Territorio'),
      ];
      sheet.appendRow(headers);

      for (final m in miembros) {
        sheet.appendRow(<xls.CellValue?>[
          xls.TextCellValue(m.id?.toString() ?? ''),
          xls.TextCellValue(m.nombre),
          xls.TextCellValue(m.dni),
          xls.TextCellValue(_dateFormat.format(m.fechaNacimiento)),
          xls.TextCellValue(m.genero),
          xls.TextCellValue(m.telefono),
          xls.TextCellValue(m.direccion),
          xls.TextCellValue(_dateFormat.format(m.fechaRegistro)),
          xls.TextCellValue(m.rol),
          xls.TextCellValue(m.activo ? 'Sí' : 'No'),
          xls.TextCellValue(m.sector),
          xls.TextCellValue(m.profesionOficio),
          xls.TextCellValue(m.trabajoMesas ? 'Sí' : 'No'),
          xls.TextCellValue(m.empleado ? 'Sí' : 'No'),
          xls.TextCellValue(m.trabajaraMesaGenerales2025 ? 'Sí' : 'No'),
          xls.TextCellValue(m.territorio),
        ]);
      }

      final bytes = ex.encode()!;
      final blob = html.Blob([bytes], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..style.display = 'none'
        ..download = 'miembros_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      html.document.body!.children.add(anchor);
      anchor.click();
      html.document.body!.children.remove(anchor);
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al exportar: $e')),
        );
      }
    }
  }

  Future<void> _showMiembroDetails(Miembro m) async {
    final isMobile = MediaQuery.of(context).size.width < 600;
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isMobile ? 420 : 720,
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: m.activo ? Colors.green : Colors.red,
                      child: Text(
                        m.nombre.isNotEmpty ? m.nombre[0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        m.nombre,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Chip(
                      label: Text(m.activo ? 'Activo' : 'Inactivo'),
                      backgroundColor: m.activo ? Colors.green[100] : Colors.red[100],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _info('DNI', m.dni),
                    _info('Género', m.genero),
                    _info('Nacimiento', _dateFormat.format(m.fechaNacimiento)),
                    _info('Teléfono', m.telefono),
                    _info('Dirección', m.direccion),
                    _info('Registro', _dateFormat.format(m.fechaRegistro)),
                    _info('Rol', m.rol),
                    _info('Sector', m.sector),
                    _info('Oficio', m.profesionOficio),
                    _info('Trabajó Mesas', m.trabajoMesas ? 'Sí' : 'No'),
                    _info('Empleado', m.empleado ? 'Sí' : 'No'),
                    _info('Trabajará Mesa 2025', m.trabajaraMesaGenerales2025 ? 'Sí' : 'No'),
                    _info('Territorio', m.territorio),
                  ],
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: Wrap(
                    spacing: 8,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cerrar'),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.edit),
                        label: const Text('Editar'),
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await _showEditDialog(m);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showEditDialog(Miembro m) async {
    await showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 840,
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(8),
            child: MiembroForm(territorio: widget.territorio, miembroToEdit: m),
          ),
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  Widget _info(String label, String value) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          SelectableText(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final wrapChildMaxWidth = math.max(160.0, math.min(320.0, MediaQuery.of(context).size.width - 48.0));

    final params = SearchParams(
      territorio: widget.territorio,
      query: _searchQuery,
      sector: _sector,
      trabajoMesas: _trabajoMesas,
      empleado: _empleado,
      trabajaraMesaGenerales2025: _trabajaraMesaGenerales2025,
    );

    Widget banner() {
      return Consumer(
        builder: (context, ref, _) {
          final status = ref.watch(storageStatusProvider);
          return status.when(
            loading: () => const SizedBox.shrink(),
            error: (e, st) => const SizedBox.shrink(),
            data: (persistent) => persistent
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Material(
                      color: Colors.amber[100],
                      child: const ListTile(
                        leading: Icon(Icons.warning_amber, color: Colors.amber),
                        title: Text('Modo no persistente'),
                        subtitle: Text('IndexedDB no disponible. Usa puerto fijo (p.ej. 8080) y evita incógnito.'),
                      ),
                    ),
                  ),
          );
        },
      );
    }

    Widget filtros() {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ExpansionTile(
            initiallyExpanded: !isMobile,
            leading: Icon(Icons.search, color: Theme.of(context).colorScheme.primary),
            title: const Text('Buscar Miembros', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Territorio: ${widget.territorio}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: const InputDecoration(
                        labelText: 'Texto a buscar',
                        hintText: 'Buscar por nombre, DNI, teléfono, dirección, etc.',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        SizedBox(
                          width: wrapChildMaxWidth,
                          child: TextField(
                            decoration: const InputDecoration(labelText: 'Sector', border: OutlineInputBorder()),
                            onChanged: (v) => setState(() => _sector = v.trim().isEmpty ? null : v.trim()),
                          ),
                        ),
                        SizedBox(
                          width: wrapChildMaxWidth,
                          child: DropdownButtonFormField<bool?>(
                            value: _trabajoMesas,
                            isExpanded: true,
                            decoration: const InputDecoration(labelText: 'Trabajó en mesas', border: OutlineInputBorder()),
                            items: const [
                              DropdownMenuItem(value: null, child: Text('Todos')),
                              DropdownMenuItem(value: true, child: Text('Sí')),
                              DropdownMenuItem(value: false, child: Text('No')),
                            ],
                            onChanged: (v) => setState(() => _trabajoMesas = v),
                          ),
                        ),
                        SizedBox(
                          width: wrapChildMaxWidth,
                          child: DropdownButtonFormField<bool?>(
                            value: _empleado,
                            isExpanded: true,
                            decoration: const InputDecoration(labelText: 'Empleado', border: OutlineInputBorder()),
                            items: const [
                              DropdownMenuItem(value: null, child: Text('Todos')),
                              DropdownMenuItem(value: true, child: Text('Sí')),
                              DropdownMenuItem(value: false, child: Text('No')),
                            ],
                            onChanged: (v) => setState(() => _empleado = v),
                          ),
                        ),
                        SizedBox(
                          width: wrapChildMaxWidth,
                          child: DropdownButtonFormField<bool?>(
                            value: _trabajaraMesaGenerales2025,
                            isExpanded: true,
                            decoration: const InputDecoration(labelText: 'Trabajará mesa 2025', border: OutlineInputBorder()),
                            items: const [
                              DropdownMenuItem(value: null, child: Text('Todos')),
                              DropdownMenuItem(value: true, child: Text('Sí')),
                              DropdownMenuItem(value: false, child: Text('No')),
                            ],
                            onChanged: (v) => setState(() => _trabajaraMesaGenerales2025 = v),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _clearFilters,
                          icon: const Icon(Icons.filter_list_off),
                          label: const Text('Limpiar filtros'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_searchQuery.isNotEmpty || (_sector != null && _sector!.isNotEmpty) || _trabajoMesas != null || _empleado != null || _trabajaraMesaGenerales2025 != null)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (_searchQuery.isNotEmpty) Chip(avatar: const Icon(Icons.text_fields, size: 16), label: Text('Texto: $_searchQuery')),
                          if (_sector != null && _sector!.isNotEmpty) Chip(avatar: const Icon(Icons.business_center, size: 16), label: Text('Sector: ${_sector!}')),
                          if (_trabajoMesas != null) Chip(avatar: const Icon(Icons.how_to_vote, size: 16), label: Text('Trabajó mesas: ${_trabajoMesas! ? 'Sí' : 'No'}')),
                          if (_empleado != null) Chip(avatar: const Icon(Icons.badge, size: 16), label: Text('Empleado: ${_empleado! ? 'Sí' : 'No'}')),
                          if (_trabajaraMesaGenerales2025 != null) Chip(avatar: const Icon(Icons.how_to_vote_outlined, size: 16), label: Text('Trabajará mesa 2025: ${_trabajaraMesaGenerales2025! ? 'Sí' : 'No'}')),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget resultados() {
      return Expanded(
        child: Card(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.group, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    const Text('Resultados', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Expanded(
                child: Consumer(
                  builder: (context, ref, _) {
                    final async = ref.watch(miembrosBusquedaProvider(params));
                    return async.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, st) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error, color: Colors.red, size: 48),
                            const SizedBox(height: 16),
                            Text('Error: $e'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => ref.invalidate(miembrosBusquedaProvider(params)),
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      ),
                      data: (miembros) {
                        if (miembros.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.person_off, color: Colors.grey, size: 48),
                                SizedBox(height: 16),
                                Text('No se encontraron miembros', style: TextStyle(fontSize: 16, color: Colors.grey)),
                              ],
                            ),
                          );
                        }
                        return Column(
                          children: [
                            Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: ElevatedButton.icon(
                                  onPressed: () => _exportToExcel(miembros),
                                  icon: const Icon(Icons.download),
                                  label: const Text('Exportar Excel'),
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListView.separated(
                                itemCount: miembros.length,
                                separatorBuilder: (_, __) => const Divider(height: 1),
                                itemBuilder: (context, i) {
                                  final m = miembros[i];
                                  return isMobile
                                      ? Card(
                                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor: m.activo ? Colors.green : Colors.red,
                                              child: Text(
                                                m.nombre.isNotEmpty ? m.nombre[0].toUpperCase() : '?',
                                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            title: Text(m.nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
                                            subtitle: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('DNI: ${m.dni}'),
                                                Text('${m.rol} • ${m.sector}'),
                                                Text('Tel: ${m.telefono}'),
                                              ],
                                            ),
                                            onTap: () => _showMiembroDetails(m),
                                            isThreeLine: true,
                                          ),
                                        )
                                      : ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor: m.activo ? Colors.green : Colors.red,
                                            child: Text(
                                              m.nombre.isNotEmpty ? m.nombre[0].toUpperCase() : '?',
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          title: Text(m.nombre, style: const TextStyle(fontWeight: FontWeight.w500)),
                                          subtitle: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('DNI: ${m.dni} • ${m.genero}'),
                                              Text('${m.rol} • ${m.sector}'),
                                              Text('Tel: ${m.telefono}'),
                                            ],
                                          ),
                                          trailing: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              FittedBox(
                                                child: Chip(
                                                  label: Text(m.activo ? 'Activo' : 'Inactivo', style: const TextStyle(fontSize: 12)),
                                                  backgroundColor: m.activo ? Colors.green[100] : Colors.red[100],
                                                ),
                                              ),
                                            ],
                                          ),
                                          onTap: () => _showMiembroDetails(m),
                                          isThreeLine: true,
                                        );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }

    final content = Column(
      children: [
        banner(),
        if (isMobile) ...[
          resultados(),
          const SizedBox(height: 12),
          filtros(),
        ] else ...[
          filtros(),
          const SizedBox(height: 16),
          resultados(),
        ],
      ],
    );

    // Si la altura es muy pequeña, permite scroll de todo el contenido
    final smallHeight = MediaQuery.of(context).size.height < 580;
    return SafeArea(
      child: smallHeight
          ? SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 8),
              child: content,
            )
          : content,
    );
  }
}
