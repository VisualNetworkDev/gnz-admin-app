import 'dart:convert';
import 'dart:io';

class GnzApi {
  GnzApi({
    this.endpoint =
        'https://script.google.com/macros/s/AKfycbzIjm2vj89cpRw5mzwYRVLAO4XPBRBSBoTFm5eing4vd0MQVWRj62hVd_Ghex0wN4pLsw/exec',
  });

  final String endpoint;
  final HttpClient _client = HttpClient()
    ..connectionTimeout = const Duration(seconds: 25);

  Future<dynamic> call(String fn, List<dynamic> args) async {
    final body = _formEncode({
      'api': '1',
      'desktop': '1',
      'requestId': 'flutter_${DateTime.now().millisecondsSinceEpoch}',
      'fn': fn,
      'args': jsonEncode(args),
    });

    var uri = Uri.parse(endpoint);
    var response = await _postForm(uri, body);
    for (var i = 0; i < 5; i++) {
      if (response.statusCode < 300 ||
          response.statusCode >= 400 ||
          response.location == null) {
        break;
      }
      uri = uri.resolve(response.location!);
      response = await _get(uri);
    }

    final decoded = jsonDecode(response.text);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Apps Script devolvio una respuesta invalida.');
    }

    final ok = decoded['ok'] == true;
    if (!ok || response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        decoded['error']?.toString() ?? 'Apps Script rechazo la solicitud.',
      );
    }

    return decoded['result'];
  }

  Future<_ApiResponse> _postForm(Uri uri, String body) async {
    final request = await _client.postUrl(uri);
    request.headers.contentType = ContentType(
      'application',
      'x-www-form-urlencoded',
      charset: 'utf-8',
    );
    request.followRedirects = false;
    request.maxRedirects = 5;
    request.add(utf8.encode(body));

    final response = await request.close().timeout(const Duration(seconds: 60));
    final text = await response.transform(utf8.decoder).join();
    return _ApiResponse(
      statusCode: response.statusCode,
      text: text,
      location: response.headers.value(HttpHeaders.locationHeader),
    );
  }

  Future<_ApiResponse> _get(Uri uri) async {
    final request = await _client.getUrl(uri);
    request.followRedirects = false;
    request.maxRedirects = 5;
    final response = await request.close().timeout(const Duration(seconds: 60));
    final text = await response.transform(utf8.decoder).join();
    return _ApiResponse(
      statusCode: response.statusCode,
      text: text,
      location: response.headers.value(HttpHeaders.locationHeader),
    );
  }

  String _formEncode(Map<String, String> values) {
    return values.entries
        .map(
          (entry) =>
              '${Uri.encodeQueryComponent(entry.key)}=${Uri.encodeQueryComponent(entry.value)}',
        )
        .join('&');
  }
}

class _ApiResponse {
  const _ApiResponse({
    required this.statusCode,
    required this.text,
    required this.location,
  });

  final int statusCode;
  final String text;
  final String? location;
}
