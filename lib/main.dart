import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'config/router.dart';
import 'providers/miembro_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(const ProviderScope(child: ColectivoApp()));
}

class ColectivoApp extends ConsumerWidget {
  const ColectivoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    // Chequeo de persistencia en Web (IndexedDB)
    ref.listen(storageStatusProvider, (prev, next) {
      next.whenData((persistent) async {
        if (!persistent) {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
                title: const Text('Almacenamiento no disponible'),
                content: const Text(
                  'No se pudo acceder a IndexedDB. Los datos no serán persistentes.\n\n'
                  'Solución: Ejecuta con puerto fijo (p. ej. 8080), evita modo incógnito y permite almacenamiento de sitio.',
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      ref.invalidate(storageStatusProvider);
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('Reintentar'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('Entendido'),
                  ),
                ],
              ),
          );
        }
      });
    });

  return MaterialApp.router(
      title: 'Colectivo - Registro de Miembros',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'),
        Locale('en', 'US'),
      ],
      locale: const Locale('es', 'ES'),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 2,
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
  routerConfig: router,
    );
  }
}
