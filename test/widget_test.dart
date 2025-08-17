// Test básico para la aplicación Colectivo
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:colectivo/main.dart';

void main() {
  testWidgets('App loads without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: ColectivoApp()));

    // Verify that the login screen loads
    expect(find.text('Colectivo'), findsOneWidget);
    expect(find.text('Sistema de Registro de Miembros'), findsOneWidget);
    
    // Verify login form fields exist
    expect(find.text('Usuario'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
    expect(find.text('Iniciar Sesión'), findsOneWidget);
  });

  testWidgets('Login form validation works', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: ColectivoApp()));

    // Try to submit empty form
    await tester.tap(find.text('Iniciar Sesión'));
    await tester.pump();

    // Should show validation errors
    expect(find.text('Por favor ingrese su usuario'), findsOneWidget);
    expect(find.text('Por favor ingrese su contraseña'), findsOneWidget);
  });
}
