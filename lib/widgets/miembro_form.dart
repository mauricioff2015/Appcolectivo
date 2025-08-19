import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/miembro.dart';
import '../providers/miembro_provider.dart';

class MiembroForm extends ConsumerStatefulWidget {
  final String territorio;
  final Miembro? miembroToEdit;

  const MiembroForm({
    super.key,
    required this.territorio,
    this.miembroToEdit,
  });

  @override
  ConsumerState<MiembroForm> createState() => _MiembroFormState();
}

class _MiembroFormState extends ConsumerState<MiembroForm> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _dniController = TextEditingController();
  final _fechaNacimientoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();
  final _sectorController = TextEditingController();
  final _profesionOficioController = TextEditingController();

  String _genero = 'Masculino';
  String _rol = 'Miembro';
  bool _activo = true;
  bool _trabajoMesas = false;
  bool _empleado = false;
  bool _trabajaraMesaGenerales2025 = false;
  DateTime? _fechaNacimiento;
  bool _isLoading = false;

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    if (widget.miembroToEdit != null) {
      _loadMiembroData();
    }
  }

  void _loadMiembroData() {
    final miembro = widget.miembroToEdit!;
    _nombreController.text = miembro.nombre;
    _dniController.text = miembro.dni;
    _fechaNacimiento = miembro.fechaNacimiento;
    _fechaNacimientoController.text = _dateFormat.format(miembro.fechaNacimiento);
    _genero = miembro.genero;
    _telefonoController.text = miembro.telefono;
    _direccionController.text = miembro.direccion;
    _rol = miembro.rol;
    _activo = miembro.activo;
    _sectorController.text = miembro.sector;
    _profesionOficioController.text = miembro.profesionOficio;
    _trabajoMesas = miembro.trabajoMesas;
    _empleado = miembro.empleado;
    _trabajaraMesaGenerales2025 = miembro.trabajaraMesaGenerales2025;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _dniController.dispose();
    _fechaNacimientoController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _sectorController.dispose();
    _profesionOficioController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento ?? DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
    );

    if (picked != null) {
      setState(() {
        _fechaNacimiento = picked;
        _fechaNacimientoController.text = _dateFormat.format(picked);
      });
    }
  }

  Future<void> _saveMiembro() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fechaNacimiento == null) {
      _showErrorSnackBar('Seleccione la fecha de nacimiento');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final miembroService = ref.read(miembroServiceProvider);

      // Verificar si el DNI ya existe (excepto para edición)
      final dniExists = await miembroService.isDniExists(
        _dniController.text.trim(),
        excludeId: widget.miembroToEdit?.id,
      );

      if (dniExists) {
        _showErrorSnackBar('Ya existe un miembro con ese DNI');
        return;
      }

      final miembro = Miembro(
        id: widget.miembroToEdit?.id,
        nombre: _nombreController.text.trim(),
        dni: _dniController.text.trim(),
        fechaNacimiento: _fechaNacimiento!,
        genero: _genero,
        telefono: _telefonoController.text.trim(),
        direccion: _direccionController.text.trim(),
        fechaRegistro: widget.miembroToEdit?.fechaRegistro ?? DateTime.now(),
        rol: _rol,
        activo: _activo,
        sector: _sectorController.text.trim(),
        profesionOficio: _profesionOficioController.text.trim(),
        trabajoMesas: _trabajoMesas,
        empleado: _empleado,
        trabajaraMesaGenerales2025: _trabajaraMesaGenerales2025,
        territorio: widget.territorio,
      );

      if (widget.miembroToEdit != null) {
        await miembroService.updateMiembro(miembro);
        _showSuccessSnackBar('Miembro actualizado exitosamente');
      } else {
        await miembroService.createMiembro(miembro);
        _showSuccessSnackBar('Miembro registrado exitosamente');
        _clearForm();
      }

      // Invalidar el provider para refrescar la lista
      ref.invalidate(miembrosProvider);
      
    } catch (e) {
      _showErrorSnackBar('Error al guardar: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearForm() {
    _nombreController.clear();
    _dniController.clear();
    _fechaNacimientoController.clear();
    _telefonoController.clear();
    _direccionController.clear();
    _sectorController.clear();
    _profesionOficioController.clear();
    setState(() {
      _genero = 'Masculino';
      _rol = 'Miembro';
      _activo = true;
      _trabajoMesas = false;
      _empleado = false;
      _trabajaraMesaGenerales2025 = false;
      _fechaNacimiento = null;
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 600;
    const double gap = 16.0;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Información básica
          if (isMobile) ...[
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre Completo *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingrese el nombre';
                }
                return null;
              },
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: gap),
            TextFormField(
              controller: _dniController,
              decoration: const InputDecoration(
                labelText: 'DNI *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(13),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingrese el DNI';
                }
                if (value.length != 13) {
                  return 'El DNI debe tener 13 dígitos';
                }
                return null;
              },
            ),
            const SizedBox(height: gap),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _nombreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre Completo *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingrese el nombre';
                      }
                      return null;
                    },
                    textCapitalization: TextCapitalization.words,
                  ),
                ),
                const SizedBox(width: gap),
                Expanded(
                  child: TextFormField(
                    controller: _dniController,
                    decoration: const InputDecoration(
                      labelText: 'DNI *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(13),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingrese el DNI';
                      }
                      if (value.length != 13) {
                        return 'El DNI debe tener 13 dígitos';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: gap),
          ],

          if (isMobile) ...[
            TextFormField(
              controller: _fechaNacimientoController,
              decoration: const InputDecoration(
                labelText: 'Fecha de Nacimiento *',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: _selectDate,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Seleccione la fecha de nacimiento';
                }
                return null;
              },
            ),
            const SizedBox(height: gap),
            DropdownButtonFormField<String>(
              value: _genero,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Género *',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
                DropdownMenuItem(value: 'Femenino', child: Text('Femenino')),
                DropdownMenuItem(value: 'Otro', child: Text('Otro')),
              ],
              onChanged: (value) {
                setState(() {
                  _genero = value!;
                });
              },
            ),
            const SizedBox(height: gap),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _fechaNacimientoController,
                    decoration: const InputDecoration(
                      labelText: 'Fecha de Nacimiento *',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: _selectDate,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Seleccione la fecha de nacimiento';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: gap),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _genero,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Género *',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
                      DropdownMenuItem(value: 'Femenino', child: Text('Femenino')),
                      DropdownMenuItem(value: 'Otro', child: Text('Otro')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _genero = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: gap),
          ],

          // Contacto
          if (isMobile) ...[
            TextFormField(
              controller: _telefonoController,
              decoration: const InputDecoration(
                labelText: 'Teléfono *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingrese el teléfono';
                }
                return null;
              },
            ),
            const SizedBox(height: gap),
            TextFormField(
              controller: _direccionController,
              decoration: const InputDecoration(
                labelText: 'Dirección *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingrese la dirección';
                }
                return null;
              },
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: gap),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _telefonoController,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingrese el teléfono';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: gap),
                Expanded(
                  child: TextFormField(
                    controller: _direccionController,
                    decoration: const InputDecoration(
                      labelText: 'Dirección *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingrese la dirección';
                      }
                      return null;
                    },
                    textCapitalization: TextCapitalization.words,
                  ),
                ),
              ],
            ),
            const SizedBox(height: gap),
          ],

          // Información organizacional
          if (isMobile) ...[
            DropdownButtonFormField<String>(
              value: _rol,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Rol *',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Miembro', child: Text('Miembro')),
                DropdownMenuItem(value: 'Delegado', child: Text('Delegado')),
                DropdownMenuItem(value: 'Coordinador', child: Text('Coordinador')),
                DropdownMenuItem(value: 'Dirigente', child: Text('Dirigente')),
              ],
              onChanged: (value) {
                setState(() {
                  _rol = value!;
                });
              },
            ),
            const SizedBox(height: gap),
            TextFormField(
              controller: _sectorController,
              decoration: const InputDecoration(
                labelText: 'Sector *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingrese el sector';
                }
                return null;
              },
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: gap),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _rol,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Rol *',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Miembro', child: Text('Miembro')),
                      DropdownMenuItem(value: 'Delegado', child: Text('Delegado')),
                      DropdownMenuItem(value: 'Coordinador', child: Text('Coordinador')),
                      DropdownMenuItem(value: 'Dirigente', child: Text('Dirigente')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _rol = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: gap),
                Expanded(
                  child: TextFormField(
                    controller: _sectorController,
                    decoration: const InputDecoration(
                      labelText: 'Sector *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingrese el sector';
                      }
                      return null;
                    },
                    textCapitalization: TextCapitalization.words,
                  ),
                ),
              ],
            ),
            const SizedBox(height: gap),
          ],

          TextFormField(
            controller: _profesionOficioController,
            decoration: const InputDecoration(
              labelText: 'Profesión/Oficio *',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Ingrese la profesión/oficio';
              }
              return null;
            },
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),

          // Checkboxes
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Información Adicional',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    title: const Text('Miembro Activo'),
                    value: _activo,
                    onChanged: (value) {
                      setState(() {
                        _activo = value!;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Trabajo en Mesas'),
                    value: _trabajoMesas,
                    onChanged: (value) {
                      setState(() {
                        _trabajoMesas = value!;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Empleado'),
                    value: _empleado,
                    onChanged: (value) {
                      setState(() {
                        _empleado = value!;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Trabajará Mesa Generales 2025'),
                    value: _trabajaraMesaGenerales2025,
                    onChanged: (value) {
                      setState(() {
                        _trabajaraMesaGenerales2025 = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Botones
          if (isMobile) ...[
            if (widget.miembroToEdit == null)
              OutlinedButton(
                onPressed: _isLoading ? null : _clearForm,
                child: const Text('Limpiar'),
              ),
            const SizedBox(height: gap),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveMiembro,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(widget.miembroToEdit != null ? 'Actualizar' : 'Registrar'),
            ),
          ] else ...[
            Row(
              children: [
                if (widget.miembroToEdit == null) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : _clearForm,
                      child: const Text('Limpiar'),
                    ),
                  ),
                  const SizedBox(width: gap),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveMiembro,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(widget.miembroToEdit != null ? 'Actualizar' : 'Registrar'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
