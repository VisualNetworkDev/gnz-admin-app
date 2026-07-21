import 'dart:convert';
import 'dart:io';

class UpdateManifest {
  const UpdateManifest({
    required this.version,
    required this.title,
    required this.notes,
    required this.installerUrl,
    required this.required,
    required this.publishedAt,
  });

  factory UpdateManifest.fromJson(Map<String, dynamic> json) {
    return UpdateManifest(
      version: _text(json['version']),
      title: _text(json['title'], fallback: 'Actualizacion disponible'),
      notes: (json['notes'] is List)
          ? (json['notes'] as List)
                .map(_text)
                .where((line) => line.isNotEmpty)
                .toList()
          : const [],
      installerUrl: _text(json['installerUrl']),
      required: json['required'] == true,
      publishedAt: _text(json['publishedAt']),
    );
  }

  final String version;
  final String title;
  final List<String> notes;
  final String installerUrl;
  final bool required;
  final String publishedAt;
}

class GnzUpdater {
  GnzUpdater({required this.manifestUrl});

  final String manifestUrl;
  final HttpClient _client = HttpClient()
    ..connectionTimeout = const Duration(seconds: 25);

  Future<UpdateManifest> fetchLatest() async {
    final request = await _client.getUrl(Uri.parse(manifestUrl));
    request.headers.set(HttpHeaders.cacheControlHeader, 'no-cache');
    final response = await request.close().timeout(const Duration(seconds: 45));
    final text = await response.transform(utf8.decoder).join();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'No se pudo leer el manifiesto de actualizacion (${response.statusCode}).',
      );
    }
    final decoded = jsonDecode(text);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('El manifiesto de actualizacion no es valido.');
    }
    final manifest = UpdateManifest.fromJson(decoded);
    if (manifest.version.isEmpty || manifest.installerUrl.isEmpty) {
      throw Exception('El manifiesto de actualizacion esta incompleto.');
    }
    return manifest;
  }

  Future<File> downloadInstaller(
    UpdateManifest manifest, {
    required void Function(double progress) onProgress,
  }) async {
    final uri = Uri.parse(manifest.installerUrl);
    final request = await _client.getUrl(uri);
    final response = await request.close().timeout(const Duration(minutes: 5));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'No se pudo descargar el instalador (${response.statusCode}).',
      );
    }

    final fileName = 'GNZ-Admin-Pro-${manifest.version}-Setup.exe';
    final file = File('${Directory.systemTemp.path}\\$fileName');
    final sink = file.openWrite();
    final total = response.contentLength;
    var received = 0;

    try {
      await for (final chunk in response) {
        received += chunk.length;
        sink.add(chunk);
        if (total > 0) {
          onProgress(received / total);
        }
      }
    } finally {
      await sink.close();
    }
    onProgress(1);
    return file;
  }
}

int compareVersions(String left, String right) {
  final a = left.split('.').map((part) => int.tryParse(part) ?? 0).toList();
  final b = right.split('.').map((part) => int.tryParse(part) ?? 0).toList();
  final length = a.length > b.length ? a.length : b.length;
  for (var i = 0; i < length; i++) {
    final av = i < a.length ? a[i] : 0;
    final bv = i < b.length ? b[i] : 0;
    if (av != bv) return av.compareTo(bv);
  }
  return 0;
}

String _text(dynamic value, {String fallback = ''}) {
  final clean = value == null ? '' : value.toString().trim();
  return clean.isEmpty ? fallback : clean;
}
