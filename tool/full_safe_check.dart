import 'dart:convert';
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
  final results = <String, Object?>{};

  final login = asMap(await api.call('adminLogin', [password]));
  final token = text(login['token']);
  if (login['success'] != true || token.isEmpty) {
    throw StateError('Admin login failed.');
  }
  results['login'] = true;

  final reservations = asMap(
    await api.call('adminListarReservas', [
      token,
      {'limit': 20},
    ]),
  );
  final reservas = listOfMaps(reservations['reservas']);
  if (reservations['success'] == false) {
    throw StateError('Reservations failed: ${reservations['error']}');
  }
  results['reservas'] = reservas.length;
  results['resumen'] = reservations['resumen'];

  final catalog = asMap(await api.call('adminObtenerCatalogo', [token]));
  final catalogVehicles = listOfMaps(catalog['vehiculos']);
  final catalogPrices = listOfMaps(catalog['precios']);
  if (catalogVehicles.isEmpty || catalogPrices.isEmpty) {
    throw StateError('Catalog returned empty vehicle or price lists.');
  }
  results['catalogVehicles'] = catalogVehicles.length;
  results['catalogPrices'] = catalogPrices.length;

  final publicVehicles = listOfMaps(await api.call('obtenerVehiculos', []));
  if (publicVehicles.isEmpty) {
    throw StateError('Public vehicles returned empty list.');
  }
  results['publicVehicles'] = publicVehicles.length;

  final vehicle = publicVehicles.firstWhere((row) {
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
  final oilBrands = (oils is List ? oils : const [])
      .map(text)
      .where((value) => value.isNotEmpty)
      .toList();
  if (oilBrands.isEmpty) {
    throw StateError('Compatible oils returned empty list.');
  }
  results['compatibleOils'] = oilBrands.length;

  final quote = asMap(
    await api.call('adminCalcularPrecio', [
      token,
      {
        'ano': vehicle['ano'],
        'marca': vehicle['marca'],
        'modelo': vehicle['modelo'],
        'motor': vehicle['motor'],
        'marcaAceite': oilBrands.first,
      },
    ]),
  );
  if (quote['success'] != true || text(quote['total']).isEmpty) {
    throw StateError('Quote failed: ${quote['error']}');
  }
  results['quote'] = {
    'vehicle': '${vehicle['ano']} ${vehicle['marca']} ${vehicle['modelo']}',
    'oilBrand': oilBrands.first,
    'total': quote['total'],
    'filter': quote['tipoFiltro'],
    'altFilter': quote['tipoFiltroAlternativo'],
  };

  final discounts = await api.call('obtenerDescuentosPublicos', ['oil']);
  results['discounts'] = discounts is List ? discounts.length : 0;

  final audit = asMap(await api.call('adminObtenerAuditoriaSistema', [token]));
  if (audit['success'] == false) {
    throw StateError('Audit failed: ${audit['error']}');
  }
  results['auditIssueCount'] = audit['issueCount'];
  results['auditSummary'] = audit['summary'];

  if (reservas.isNotEmpty) {
    final first = reservas.first;
    final name = text(first['nombre']);
    final contact = text(first['telefono']).isNotEmpty
        ? text(first['telefono'])
        : text(first['correo']);
    if (name.isNotEmpty && contact.isNotEmpty) {
      final tracking = asMap(
        await api.call('consultarCitaCliente', [
          {'name': name, 'contact': contact},
        ]),
      );
      results['tracking'] = tracking['success'] == true;
      results['trackingHistory'] = listOfMaps(tracking['history']).length;
    }
  }

  stdout.writeln(const JsonEncoder.withIndent('  ').convert(results));
}
