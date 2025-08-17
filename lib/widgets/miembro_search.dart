import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart' as xls hide Border;
import 'package:universal_html/html.dart' as html;
import '../models/miembro.dart';
import '../providers/miembro_provider.dart';
import '../widgets/miembro_form.dart';

class MiembroSearch extends ConsumerStatefulWidget {
  final String territorio;

  const MiembroSearch({
    super.key,
    required this.territorio,
  });

  @override
  ConsumerState<MiembroSearch> createState() => _MiembroSearchState();
}

class _MiembroSearchState extends ConsumerState<MiembroSearch> {
  final _searchController = TextEditingController();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  String _searchQuery = '';
  // Advanced filters
  String? _sector;
  bool? _trabajoMesas; // null = todos, true/false
  bool? _empleado;     // null = todos
  bool? _trabajaraMesaGenerales2025; // null = todos

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

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
      // Build workbook
      final ex = xls.Excel.createExcel();
      final sheet = ex['Miembros'];
      // Remove default blank sheet so Excel opens with our filled sheet
      if (ex.sheets.containsKey('Sheet1')) {
        ex.delete('Sheet1');
      }
      // Header
      sheet.appendRow(<xls.CellValue>[
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
        xls.TextCellValue('Trabajó en Mesas'),
        xls.TextCellValue('Empleado'),
        xls.TextCellValue('Trabajará Mesa 2025'),
        xls.TextCellValue('Territorio'),
      ]);
      for (final m in miembros) {
        sheet.appendRow(<xls.CellValue>[
          m.id != null ? xls.IntCellValue(m.id!) : xls.TextCellValue(''),
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

      // Save differently by platform; for web use universal_html to trigger download
      final bytes = ex.encode()!;
      final blob = html.Blob([bytes], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute('download', 'miembros_filtrados.xlsx')
        ..click();
      html.Url.revokeObjectUrl(url);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exportado a Excel')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al exportar: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showMiembroDetails(Miembro miembro) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: 600,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: miembro.activo ? Colors.green : Colors.red,
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            miembro.nombre,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'DNI: ${miembro.dni}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton(
                      onSelected: (value) {
                        Navigator.of(context).pop();
                        switch (value) {
                          case 'edit':
                            _showEditDialog(miembro);
                            break;
                          case 'delete':
                            _showDeleteConfirmation(miembro);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, color: Colors.blue),
                              SizedBox(width: 8),
                              Text('Editar'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Eliminar'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(),
                _buildDetailRow('Fecha de Nacimiento', _dateFormat.format(miembro.fechaNacimiento)),
                _buildDetailRow('Género', miembro.genero),
                _buildDetailRow('Teléfono', miembro.telefono),
                _buildDetailRow('Dirección', miembro.direccion),
                _buildDetailRow('Fecha de Registro', _dateFormat.format(miembro.fechaRegistro)),
                _buildDetailRow('Rol', miembro.rol),
                _buildDetailRow('Estado', miembro.activo ? 'Activo' : 'Inactivo'),
                _buildDetailRow('Sector', miembro.sector),
                _buildDetailRow('Profesión/Oficio', miembro.profesionOficio),
                _buildDetailRow('Territorio', miembro.territorio),
                const SizedBox(height: 16),
                const Text(
                  'Información Adicional:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildBooleanChip('Trabajo en Mesas', miembro.trabajoMesas),
                _buildBooleanChip('Empleado', miembro.empleado),
                _buildBooleanChip('Trabajará Mesa Generales 2025', miembro.trabajaraMesaGenerales2025),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cerrar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildBooleanChip(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0, bottom: 4.0),
      child: Chip(
        label: Text(label),
        backgroundColor: value ? Colors.green[100] : Colors.grey[200],
        avatar: Icon(
          value ? Icons.check : Icons.close,
          color: value ? Colors.green : Colors.grey,
          size: 16,
        ),
      ),
    );
  }

  void _showEditDialog(Miembro miembro) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: 800,
          height: 600,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.edit, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Text(
                      'Editar Miembro',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: SingleChildScrollView(
                    child: MiembroForm(
                      territorio: widget.territorio,
                      miembroToEdit: miembro,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Miembro miembro) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Miembro'),
        content: Text('¿Está seguro que desea eliminar a "${miembro.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final miembroService = ref.read(miembroServiceProvider);
                await miembroService.deleteMiembro(miembro.id!);
                Navigator.of(context).pop();
                
                // Invalidar providers para refrescar
                ref.invalidate(miembrosProvider);
                ref.invalidate(miembrosBusquedaProvider);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Miembro eliminado exitosamente'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al eliminar miembro: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchParams = SearchParams(
      territorio: widget.territorio,
      query: _searchQuery,
      sector: _sector,
      trabajoMesas: _trabajoMesas,
      empleado: _empleado,
      trabajaraMesaGenerales2025: _trabajaraMesaGenerales2025,
    );

    return Column(
      children: [
        // Banner de modo de almacenamiento
    Consumer(builder: (context, ref, _) {
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
                      child: ListTile(
                        leading: const Icon(Icons.warning_amber, color: Colors.amber),
            title: const Text('Modo no persistente'),
            subtitle: const Text('IndexedDB no disponible. Fija el puerto (p. ej. 8080), evita incógnito y permisos bloqueados.'),
                      ),
                    ),
                  ),
          );
        }),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.search, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Text(
                      'Buscar Miembros',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Territorio: ${widget.territorio}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
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
                      width: 220,
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Sector',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (v) => setState(() => _sector = v.trim().isEmpty ? null : v.trim()),
                      ),
                    ),
                    SizedBox(
                      width: 220,
                      child: DropdownButtonFormField<bool?>(
                        value: _trabajoMesas,
                        decoration: const InputDecoration(
                          labelText: 'Trabajó en mesas',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: null, child: Text('Todos')),
                          DropdownMenuItem(value: true, child: Text('Sí')),
                          DropdownMenuItem(value: false, child: Text('No')),
                        ],
                        onChanged: (v) => setState(() => _trabajoMesas = v),
                      ),
                    ),
                    SizedBox(
                      width: 220,
                      child: DropdownButtonFormField<bool?>(
                        value: _empleado,
                        decoration: const InputDecoration(
                          labelText: 'Empleado',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: null, child: Text('Todos')),
                          DropdownMenuItem(value: true, child: Text('Sí')),
                          DropdownMenuItem(value: false, child: Text('No')),
                        ],
                        onChanged: (v) => setState(() => _empleado = v),
                      ),
                    ),
                    SizedBox(
                      width: 220,
                      child: DropdownButtonFormField<bool?>(
                        value: _trabajaraMesaGenerales2025,
                        decoration: const InputDecoration(
                          labelText: 'Trabajará mesa 2025',
                          border: OutlineInputBorder(),
                        ),
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
                // Filter summary chips
                if (_searchQuery.isNotEmpty ||
                    (_sector != null && _sector!.isNotEmpty) ||
                    _trabajoMesas != null ||
                    _empleado != null ||
                    _trabajaraMesaGenerales2025 != null)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (_searchQuery.isNotEmpty)
                        Chip(
                          avatar: const Icon(Icons.text_fields, size: 16),
                          label: Text('Texto: $_searchQuery'),
                        ),
                      if (_sector != null && _sector!.isNotEmpty)
                        Chip(
                          avatar: const Icon(Icons.business_center, size: 16),
                          label: Text('Sector: ${_sector!}'),
                        ),
                      if (_trabajoMesas != null)
                        Chip(
                          avatar: const Icon(Icons.how_to_vote, size: 16),
                          label: Text('Trabajó mesas: ${_trabajoMesas! ? 'Sí' : 'No'}'),
                        ),
                      if (_empleado != null)
                        Chip(
                          avatar: const Icon(Icons.badge, size: 16),
                          label: Text('Empleado: ${_empleado! ? 'Sí' : 'No'}'),
                        ),
                      if (_trabajaraMesaGenerales2025 != null)
                        Chip(
                          avatar: const Icon(Icons.how_to_vote_outlined, size: 16),
                          label: Text('Trabajará mesa 2025: ${_trabajaraMesaGenerales2025! ? 'Sí' : 'No'}'),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Card(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.group, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text(
                        'Resultados',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Consumer(
                    builder: (context, ref, child) {
                      final miembrosAsync = ref.watch(miembrosBusquedaProvider(searchParams));

                      return miembrosAsync.when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (error, stackTrace) => Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error, color: Colors.red, size: 48),
                              const SizedBox(height: 16),
                              Text('Error: $error'),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => ref.invalidate(miembrosBusquedaProvider(searchParams)),
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
                                children: [
                                  const Icon(Icons.person_off, color: Colors.grey, size: 48),
                                  const SizedBox(height: 16),
                                  Text(
                                    _searchQuery.isEmpty
                                        ? 'No hay miembros registrados'
                                        : 'No se encontraron miembros',
                                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                                  ),
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
                                    onPressed: miembros.isEmpty ? null : () => _exportToExcel(miembros),
                                    icon: const Icon(Icons.download),
                                    label: const Text('Exportar Excel'),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: ListView.builder(
                            itemCount: miembros.length,
                            itemBuilder: (context, index) {
                              final miembro = miembros[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: miembro.activo ? Colors.green : Colors.red,
                                  child: Text(
                                    miembro.nombre.isNotEmpty ? miembro.nombre[0].toUpperCase() : '?',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                title: Text(
                                  miembro.nombre,
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('DNI: ${miembro.dni} • ${miembro.genero}'),
                                    Text('${miembro.rol} • ${miembro.sector}'),
                                    Text('Tel: ${miembro.telefono}'),
                                  ],
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Chip(
                                      label: Text(
                                        miembro.activo ? 'Activo' : 'Inactivo',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      backgroundColor: miembro.activo ? Colors.green[100] : Colors.red[100],
                                    ),
                                  ],
                                ),
                                onTap: () => _showMiembroDetails(miembro),
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
        ),
      ],
    );
  }
}
