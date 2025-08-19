import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../widgets/miembro_form.dart';
import '../widgets/miembro_search.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(usuarioLogueadoProvider);

    if (usuario == null) {
      // Redirigir al login si no hay usuario logueado
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Territorio - ${usuario.territorio}'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          actions: [
            if (usuario.rol == 'admin')
              IconButton(
                icon: const Icon(Icons.admin_panel_settings),
                onPressed: () => context.go('/admin'),
                tooltip: 'Administración',
              ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _logout(context, ref),
              tooltip: 'Cerrar Sesión',
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.person_add),
                text: 'Registrar Miembro',
              ),
              Tab(
                icon: Icon(Icons.search),
                text: 'Buscar Miembros',
              ),
            ],
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
          ),
        ),
        body: TabBarView(
          children: [
            // Pestaña de registro
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.person_add, color: Theme.of(context).colorScheme.primary),
                              const SizedBox(width: 8),
                              const Text(
                                'Registrar Nuevo ',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Territorio: ${usuario.territorio}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const Divider(),
                          MiembroForm(territorio: usuario.territorio),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Pestaña de búsqueda
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: MiembroSearch(territorio: usuario.territorio),
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
}
