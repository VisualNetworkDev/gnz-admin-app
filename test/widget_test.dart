import 'package:flutter_test/flutter_test.dart';
import 'package:gnz_admin_flutter/main.dart';

void main() {
  testWidgets('GNZ Admin Pro shows mobile-ready login', (tester) async {
    await tester.pumpWidget(const GnzAdminProApp());

    expect(find.text('GNZ Admin Pro'), findsWidgets);
    expect(find.text('Acceso administrativo'), findsOneWidget);
    expect(find.text('Clave admin'), findsOneWidget);
  });
}
