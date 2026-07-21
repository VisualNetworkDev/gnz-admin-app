import 'dart:io';

import 'package:gnz_admin_flutter/gnz_api.dart';

Map<String, dynamic> asMap(dynamic value) {
  if (value is Map) {
    return value.map((key, val) => MapEntry(key.toString(), val));
  }
  return {};
}

List<Map<String, dynamic>> listOfMaps(dynamic value) {
  if (value is! List) return [];
  return value
      .whereType<Map>()
      .map((m) => m.map((key, val) => MapEntry(key.toString(), val)))
      .toList();
}

String text(dynamic value) => value == null ? '' : value.toString().trim();

Future<void> main() async {
  final password = Platform.environment['GNZ_ADMIN_PASSWORD'];
  if (password == null || password.isEmpty) {
    stderr.writeln('GNZ_ADMIN_PASSWORD is required.');
    exitCode = 2;
    return;
  }

  final api = GnzApi();
  final login = asMap(await api.call('adminLogin', [password]));
  final token = text(login['token']);
  if (login['success'] != true || token.isEmpty) {
    throw StateError('Admin login failed.');
  }

  final vehicles = listOfMaps(await api.call('obtenerVehiculos', []));
  final vehicle = vehicles.firstWhere((row) {
    return text(row['ano']).isNotEmpty &&
        text(row['marca']).isNotEmpty &&
        text(row['modelo']).isNotEmpty &&
        text(row['motor']).isNotEmpty;
  });

  final oils = await api.call('obtenerAceitesCompatibles', [
    vehicle['ano'],
    vehicle['marca'],
    vehicle['modelo'],
    vehicle['motor'],
  ]);
  final oilBrand = (oils as List)
      .map(text)
      .firstWhere((value) => value.isNotEmpty);

  final quote = asMap(
    await api.call('adminCalcularPrecio', [
      token,
      {
        'ano': vehicle['ano'],
        'marca': vehicle['marca'],
        'modelo': vehicle['modelo'],
        'motor': vehicle['motor'],
        'marcaAceite': oilBrand,
      },
    ]),
  );

  if (quote['success'] != true) {
    throw StateError('Quote failed: ${quote['error']}');
  }

  stdout.writeln(
    'OK ${vehicle['ano']} ${vehicle['marca']} ${vehicle['modelo']} $oilBrand total=${quote['total']}',
  );
}
