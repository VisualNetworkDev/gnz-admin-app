import 'dart:convert';
import 'dart:io';

import 'package:gnz_admin_flutter/gnz_api.dart';

Map<String, dynamic> asMap(dynamic value) {
  if (value is Map) {
    return value.map((key, val) => MapEntry(key.toString(), val));
  }
  return {};
}

String text(dynamic value, {String fallback = ''}) {
  final clean = value == null ? '' : value.toString().trim();
  return clean.isEmpty ? fallback : clean;
}

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

  Future<Map<String, dynamic>> callExpectRejected(
    String method,
    List<dynamic> args,
  ) async {
    try {
      final result = asMap(await api.call(method, args));
      if (result['success'] == true) {
        throw StateError('$method unexpectedly succeeded during guard check.');
      }
      return {
        'method': method,
        'rejected': true,
        'message': text(
          result['error'] ?? result['message'],
          fallback: 'Rejected without message',
        ),
      };
    } catch (error) {
      if (error is StateError) {
        rethrow;
      }
      return {
        'method': method,
        'rejected': true,
        'message': error.toString().replaceFirst('Exception: ', ''),
      };
    }
  }

  final checks = <Map<String, dynamic>>[];
  checks.add(
    await callExpectRejected('adminCrearReserva', [token, <String, dynamic>{}]),
  );
  checks.add(
    await callExpectRejected('adminCrearReservaFrenosFluidos', [
      token,
      <String, dynamic>{},
    ]),
  );
  checks.add(
    await callExpectRejected('adminActualizarEstado', [
      token,
      'R_DO_NOT_EXIST_GUARD_CHECK',
      'Cancelada',
    ]),
  );
  checks.add(
    await callExpectRejected('adminGuardarVehiculo', [
      token,
      {'ano': '20'},
    ]),
  );
  checks.add(
    await callExpectRejected('adminGuardarPrecio', [
      token,
      {'tipo': '', 'marca': ''},
    ]),
  );
  checks.add(await callExpectRejected('adminEliminarVehiculo', [token, '0']));
  checks.add(await callExpectRejected('adminEliminarPrecio', [token, '0']));

  stdout.writeln(const JsonEncoder.withIndent('  ').convert(checks));
}
