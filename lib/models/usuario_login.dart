import 'package:json_annotation/json_annotation.dart';

part 'usuario_login.g.dart';

@JsonSerializable()
class UsuarioLogin {
  final int? id;
  final String usuario;
  final String contrasena;
  final String rol; // 'admin' o 'registrador'
  final String territorio;

  UsuarioLogin({
    this.id,
    required this.usuario,
    required this.contrasena,
    required this.rol,
    required this.territorio,
  });

  factory UsuarioLogin.fromJson(Map<String, dynamic> json) =>
      _$UsuarioLoginFromJson(json);

  Map<String, dynamic> toJson() => _$UsuarioLoginToJson(this);

  factory UsuarioLogin.fromMap(Map<String, dynamic> map) {
    return UsuarioLogin(
      id: map['id'] as int?,
      usuario: map['usuario'] as String,
      contrasena: map['contrasena'] as String,
      rol: map['rol'] as String,
      territorio: map['territorio'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usuario': usuario,
      'contrasena': contrasena,
      'rol': rol,
      'territorio': territorio,
    };
  }

  UsuarioLogin copyWith({
    int? id,
    String? usuario,
    String? contrasena,
    String? rol,
    String? territorio,
  }) {
    return UsuarioLogin(
      id: id ?? this.id,
      usuario: usuario ?? this.usuario,
      contrasena: contrasena ?? this.contrasena,
      rol: rol ?? this.rol,
      territorio: territorio ?? this.territorio,
    );
  }
}
