// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usuario_login.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UsuarioLogin _$UsuarioLoginFromJson(Map<String, dynamic> json) => UsuarioLogin(
  id: (json['id'] as num?)?.toInt(),
  usuario: json['usuario'] as String,
  contrasena: json['contrasena'] as String,
  rol: json['rol'] as String,
  territorio: json['territorio'] as String,
);

Map<String, dynamic> _$UsuarioLoginToJson(UsuarioLogin instance) =>
    <String, dynamic>{
      'id': instance.id,
      'usuario': instance.usuario,
      'contrasena': instance.contrasena,
      'rol': instance.rol,
      'territorio': instance.territorio,
    };
