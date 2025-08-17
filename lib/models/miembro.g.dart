// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'miembro.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Miembro _$MiembroFromJson(Map<String, dynamic> json) => Miembro(
  id: (json['id'] as num?)?.toInt(),
  nombre: json['nombre'] as String,
  dni: json['dni'] as String,
  fechaNacimiento: DateTime.parse(json['fechaNacimiento'] as String),
  genero: json['genero'] as String,
  telefono: json['telefono'] as String,
  direccion: json['direccion'] as String,
  fechaRegistro: DateTime.parse(json['fechaRegistro'] as String),
  rol: json['rol'] as String,
  activo: json['activo'] as bool,
  sector: json['sector'] as String,
  profesionOficio: json['profesionOficio'] as String,
  trabajoMesas: json['trabajoMesas'] as bool,
  empleado: json['empleado'] as bool,
  trabajaraMesaGenerales2025: json['trabajaraMesaGenerales2025'] as bool,
  territorio: json['territorio'] as String,
);

Map<String, dynamic> _$MiembroToJson(Miembro instance) => <String, dynamic>{
  'id': instance.id,
  'nombre': instance.nombre,
  'dni': instance.dni,
  'fechaNacimiento': instance.fechaNacimiento.toIso8601String(),
  'genero': instance.genero,
  'telefono': instance.telefono,
  'direccion': instance.direccion,
  'fechaRegistro': instance.fechaRegistro.toIso8601String(),
  'rol': instance.rol,
  'activo': instance.activo,
  'sector': instance.sector,
  'profesionOficio': instance.profesionOficio,
  'trabajoMesas': instance.trabajoMesas,
  'empleado': instance.empleado,
  'trabajaraMesaGenerales2025': instance.trabajaraMesaGenerales2025,
  'territorio': instance.territorio,
};
