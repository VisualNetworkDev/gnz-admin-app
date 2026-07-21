import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gnz_admin_flutter/main.dart';

void main() {
  testWidgets('GNZ Admin Pro shows mobile-ready login', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const GnzAdminProApp());
    await tester.pumpAndSettle();

    expect(find.text('GNZ Admin Pro'), findsWidgets);
    expect(find.text('Acceso administrativo'), findsOneWidget);
    expect(find.text('Clave admin'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('GNZ Admin Pro login fits a compact iPhone viewport', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const GnzAdminProApp());
    await tester.pumpAndSettle();

    expect(find.text('Entrar al panel'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
