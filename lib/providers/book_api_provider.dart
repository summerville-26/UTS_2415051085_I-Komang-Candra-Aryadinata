import 'package:flutter/foundation.dart';

import '../models/book.dart';
import '../repositories/book_repository.dart';

class BookApiProvider extends ChangeNotifier {
  BookApiProvider({required this._repository});

  final BookRepository _repository;

  List<Book> _books = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _query = 'fiction';

  List<Book> get books => List.unmodifiable(_books);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get query => _query;
  bool get isEmpty => !_isLoading && _errorMessage == null && _books.isEmpty;

  Future<void> fetchBooks({String? query}) async {
    final newQuery = query?.trim() ?? _query;

    if (newQuery.isEmpty) {
      _errorMessage = 'Kata kunci pencarian tidak boleh kosong.';
      _books = [];
      _isLoading = false;
      notifyListeners();
      return;
    }

    _query = newQuery;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _repository.fetchBooks(query: _query);
      _books = results;
    } catch (error) {
      _books = [];
      _errorMessage =
          'Gagal memuat buku. Periksa koneksi internet dan coba lagi.';
      debugPrint('BookApiProvider.fetchBooks error: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchBooks(String query) async {
    await fetchBooks(query: query);
  }
}
