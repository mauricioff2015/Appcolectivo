import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/login_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/admin_screen.dart';
import '../providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
        redirect: (context, state) {
          final usuario = ref.read(usuarioLogueadoProvider);
          if (usuario == null) {
            return '/';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => const AdminScreen(),
        redirect: (context, state) {
          final usuario = ref.read(usuarioLogueadoProvider);
          if (usuario == null) {
            return '/';
          }
          if (usuario.rol != 'admin') {
            return '/dashboard';
          }
          return null;
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Página no encontrada',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text('Error: ${state.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Ir al inicio'),
            ),
          ],
        ),
      ),
    ),
  );
});
