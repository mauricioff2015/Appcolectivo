import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../models/usuario_login.dart';

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> {
  @override
  Widget build(BuildContext context) {
    final usuario = ref.watch(usuarioLogueadoProvider);

    if (usuario == null || usuario.rol != 'admin') {
      // Redirigir si no es admin
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard),
            onPressed: () => context.go('/dashboard'),
            tooltip: 'Dashboard',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context, ref),
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.admin_panel_settings, 
                               color: Colors.red, size: 32),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Administración de Usuarios',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Administrador: ${usuario.usuario} - ${usuario.territorio}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () => _showCreateUserDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Nuevo Usuario'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FutureBuilder<List<UsuarioLogin>>(
                    future: ref.read(authServiceProvider).getAllUsuarios(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      }

                      final usuarios = snapshot.data ?? [];

                      return ListView.builder(
                        itemCount: usuarios.length,
                        itemBuilder: (context, index) {
                          final user = usuarios[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: user.rol == 'admin' 
                                  ? Colors.red : Colors.blue,
                              child: Icon(
                                user.rol == 'admin' 
                                    ? Icons.admin_panel_settings 
                                    : Icons.person,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(user.usuario),
                            subtitle: Text('${user.rol} - ${user.territorio}'),
                            trailing: PopupMenuButton(
                              onSelected: (value) {
                                switch (value) {
                                  case 'edit':
                                    _showEditUserDialog(context, user);
                                    break;
                                  case 'delete':
                                    _showDeleteConfirmation(context, user);
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
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _logout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Está seguro que desea cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(usuarioLogueadoProvider.notifier).state = null;
              Navigator.of(context).pop();
              context.go('/');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCreateUserDialog(BuildContext context) {
    final usuarioController = TextEditingController();
    final contrasenaController = TextEditingController();
    String selectedRol = 'registrador';
    final territorioController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crear Nuevo Usuario'),
        content: SizedBox(
          width: 400,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: usuarioController,
                  decoration: const InputDecoration(
                    labelText: 'Usuario',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingrese el usuario';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: contrasenaController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingrese la contraseña';
                    }
                    if (value.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRol,
                  decoration: const InputDecoration(
                    labelText: 'Rol',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'admin', child: Text('Administrador')),
                    DropdownMenuItem(value: 'registrador', child: Text('Registrador')),
                  ],
                  onChanged: (value) {
                    selectedRol = value!;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: territorioController,
                  decoration: const InputDecoration(
                    labelText: 'Territorio',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingrese el territorio';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  final authService = ref.read(authServiceProvider);
                  final nuevoUsuario = UsuarioLogin(
                    usuario: usuarioController.text.trim(),
                    contrasena: contrasenaController.text,
                    rol: selectedRol,
                    territorio: territorioController.text.trim(),
                  );
                  
                  await authService.createUsuario(nuevoUsuario);
                  Navigator.of(context).pop();
                  setState(() {});
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Usuario creado exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al crear usuario: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog(BuildContext context, UsuarioLogin usuario) {
    final usuarioController = TextEditingController(text: usuario.usuario);
    final contrasenaController = TextEditingController();
    String selectedRol = usuario.rol;
    final territorioController = TextEditingController(text: usuario.territorio);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Usuario'),
        content: SizedBox(
          width: 400,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: usuarioController,
                  decoration: const InputDecoration(
                    labelText: 'Usuario',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingrese el usuario';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: contrasenaController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Nueva Contraseña (opcional)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty && value.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRol,
                  decoration: const InputDecoration(
                    labelText: 'Rol',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'admin', child: Text('Administrador')),
                    DropdownMenuItem(value: 'registrador', child: Text('Registrador')),
                  ],
                  onChanged: (value) {
                    selectedRol = value!;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: territorioController,
                  decoration: const InputDecoration(
                    labelText: 'Territorio',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingrese el territorio';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  final authService = ref.read(authServiceProvider);
                  final usuarioActualizado = usuario.copyWith(
                    usuario: usuarioController.text.trim(),
                    contrasena: contrasenaController.text.isNotEmpty 
                        ? contrasenaController.text 
                        : usuario.contrasena,
                    rol: selectedRol,
                    territorio: territorioController.text.trim(),
                  );
                  
                  await authService.updateUsuario(usuarioActualizado);
                  Navigator.of(context).pop();
                  setState(() {});
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Usuario actualizado exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al actualizar usuario: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, UsuarioLogin usuario) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Usuario'),
        content: Text('¿Está seguro que desea eliminar al usuario "${usuario.usuario}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final authService = ref.read(authServiceProvider);
                await authService.deleteUsuario(usuario.id!);
                Navigator.of(context).pop();
                setState(() {});
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Usuario eliminado exitosamente'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al eliminar usuario: $e'),
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
}
