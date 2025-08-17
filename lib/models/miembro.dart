import 'package:json_annotation/json_annotation.dart';

part 'miembro.g.dart';

@JsonSerializable()
class Miembro {
  final int? id;
  final String nombre;
  final String dni;
  final DateTime fechaNacimiento;
  final String genero;
  final String telefono;
  final String direccion;
  final DateTime fechaRegistro;
  final String rol;
  final bool activo;
  final String sector;
  final String profesionOficio;
  final bool trabajoMesas;
  final bool empleado;
  final bool trabajaraMesaGenerales2025;
  final String territorio; // Asignado automáticamente del usuario logueado

  Miembro({
    this.id,
    required this.nombre,
    required this.dni,
    required this.fechaNacimiento,
    required this.genero,
    required this.telefono,
    required this.direccion,
    required this.fechaRegistro,
    required this.rol,
    required this.activo,
    required this.sector,
    required this.profesionOficio,
    required this.trabajoMesas,
    required this.empleado,
    required this.trabajaraMesaGenerales2025,
    required this.territorio,
  });

  factory Miembro.fromJson(Map<String, dynamic> json) =>
      _$MiembroFromJson(json);

  Map<String, dynamic> toJson() => _$MiembroToJson(this);

  factory Miembro.fromMap(Map<String, dynamic> map) {
    return Miembro(
      id: map['id'] as int?,
      nombre: map['nombre'] as String,
      dni: map['dni'] as String,
      fechaNacimiento: DateTime.parse(map['fecha_nacimiento'] as String),
      genero: map['genero'] as String,
      telefono: map['telefono'] as String,
      direccion: map['direccion'] as String,
      fechaRegistro: DateTime.parse(map['fecha_registro'] as String),
      rol: map['rol'] as String,
      activo: (map['activo'] as int) == 1,
      sector: map['sector'] as String,
      profesionOficio: map['profesion_oficio'] as String,
      trabajoMesas: (map['trabajo_mesas'] as int) == 1,
      empleado: (map['empleado'] as int) == 1,
      trabajaraMesaGenerales2025: (map['trabajara_mesa_generales_2025'] as int) == 1,
      territorio: map['territorio'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'dni': dni,
      'fecha_nacimiento': fechaNacimiento.toIso8601String(),
      'genero': genero,
      'telefono': telefono,
      'direccion': direccion,
      'fecha_registro': fechaRegistro.toIso8601String(),
      'rol': rol,
      'activo': activo ? 1 : 0,
      'sector': sector,
      'profesion_oficio': profesionOficio,
      'trabajo_mesas': trabajoMesas ? 1 : 0,
      'empleado': empleado ? 1 : 0,
      'trabajara_mesa_generales_2025': trabajaraMesaGenerales2025 ? 1 : 0,
      'territorio': territorio,
    };
  }

  Miembro copyWith({
    int? id,
    String? nombre,
    String? dni,
    DateTime? fechaNacimiento,
    String? genero,
    String? telefono,
    String? direccion,
    DateTime? fechaRegistro,
    String? rol,
    bool? activo,
    String? sector,
    String? profesionOficio,
    bool? trabajoMesas,
    bool? empleado,
    bool? trabajaraMesaGenerales2025,
    String? territorio,
  }) {
    return Miembro(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      dni: dni ?? this.dni,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      genero: genero ?? this.genero,
      telefono: telefono ?? this.telefono,
      direccion: direccion ?? this.direccion,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      rol: rol ?? this.rol,
      activo: activo ?? this.activo,
      sector: sector ?? this.sector,
      profesionOficio: profesionOficio ?? this.profesionOficio,
      trabajoMesas: trabajoMesas ?? this.trabajoMesas,
      empleado: empleado ?? this.empleado,
      trabajaraMesaGenerales2025: trabajaraMesaGenerales2025 ?? this.trabajaraMesaGenerales2025,
      territorio: territorio ?? this.territorio,
    );
  }

  bool matchesSearch(String query) {
    final searchTerm = query.toLowerCase();
    return nombre.toLowerCase().contains(searchTerm) ||
           dni.toLowerCase().contains(searchTerm) ||
           genero.toLowerCase().contains(searchTerm) ||
           telefono.toLowerCase().contains(searchTerm) ||
           direccion.toLowerCase().contains(searchTerm) ||
           rol.toLowerCase().contains(searchTerm) ||
           sector.toLowerCase().contains(searchTerm) ||
           profesionOficio.toLowerCase().contains(searchTerm);
  }
}
