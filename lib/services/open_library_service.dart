import 'dart:convert';

import 'package:http/http.dart' as http;

/// Menangani komunikasi HTTP dengan Open Library API.
class OpenLibraryService {
  OpenLibraryService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const String _baseUrl = 'openlibrary.org';

  /// Mengambil hasil pencarian buku.
  Future<Map<String, dynamic>> searchBooks({
    String query = 'fiction',
    int limit = 20,
  }) async {
    final normalizedQuery = query.trim();

    if (normalizedQuery.isEmpty) {
      throw ArgumentError('Kata kunci pencarian tidak boleh kosong.');
    }

    final uri = Uri.https(_baseUrl, '/search.json', {
      'q': normalizedQuery,
      'limit': '$limit',
      'fields': 'key,title,author_name,subject,first_publish_year,cover_i,first_sentence',
    });

    final response = await _client.get(
      uri,
      headers: const {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Gagal mengambil data buku. HTTP ${response.statusCode}.',
      );
    }

    final dynamic decodedBody = jsonDecode(response.body);

    if (decodedBody is! Map<String, dynamic>) {
      throw const FormatException('Format respons Open Library tidak valid.');
    }

    return decodedBody;
  }

  /// Mengambil deskripsi asli berdasarkan identitas karya Open Library.
  ///
  /// Contoh key: /works/OL45804W
  Future<String?> fetchWorkDescription(String? workKey) async {
    if (workKey == null || workKey.trim().isEmpty) {
      return null;
    }

    final normalizedKey = workKey.trim();

    // Hanya menerima key karya Open Library.
    final match = RegExp(r'^/works/(OL\d+W)$').firstMatch(normalizedKey);

    if (match == null) {
      return null;
    }

    final uri = Uri.https(_baseUrl, '/works/${match.group(1)}.json');

    final response = await _client.get(
      uri,
      headers: const {'Accept': 'application/json'},
    );

    if (response.statusCode == 404) {
      return null;
    }

    if (response.statusCode != 200) {
      throw Exception(
        'Gagal mengambil deskripsi buku. '
        'HTTP ${response.statusCode}.',
      );
    }

    final dynamic decodedBody = jsonDecode(response.body);

    if (decodedBody is! Map<String, dynamic>) {
      throw const FormatException('Format deskripsi Open Library tidak valid.');
    }

    final dynamic rawDescription = decodedBody['description'];

    // Open Library dapat mengembalikan deskripsi sebagai String
    // atau objek yang mempunyai properti value.
    String? description;

    if (rawDescription is String) {
      description = rawDescription;
    } else if (rawDescription is Map<String, dynamic>) {
      final value = rawDescription['value'];

      if (value is String) {
        description = value;
      }
    }

    if (description == null || description.trim().isEmpty) {
      return null;
    }

    return description.trim();
  }

  /// Menutup HTTP client.
  void dispose() {
    _client.close();
  }
}
