import '../models/book.dart';
import '../services/open_library_service.dart';

/// Menghubungkan sumber data API dengan model Book.
class BookRepository {
  BookRepository({required this._service});

  final OpenLibraryService _service;

  /// Mengambil buku dari API dan mengubahnya menjadi daftar objek Book.
  Future<List<Book>> fetchBooks({
    String query = 'fiction',
    int limit = 20,
  }) async {
    final response = await _service.searchBooks(query: query, limit: limit);

    final dynamic rawDocs = response['docs'];

    if (rawDocs is! List) {
      throw const FormatException(
        'Data buku tidak ditemukan dalam respons API.',
      );
    }

    final books = <Book>[];

    for (final item in rawDocs) {
      if (item is Map<String, dynamic>) {
        books.add(Book.fromOpenLibraryJson(item));
      }
    }

    return books;
  }
}
