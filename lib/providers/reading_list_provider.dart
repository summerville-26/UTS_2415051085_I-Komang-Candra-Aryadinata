import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/book.dart';
import '../models/saved_book.dart';

/// Mengelola daftar bacaan yang disimpan di Supabase.
class ReadingListProvider extends ChangeNotifier {
  ReadingListProvider() {
    loadBooks();
  }

  final SupabaseClient _client = Supabase.instance.client;
  final List<SavedBook> _savedBooks = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<SavedBook> get savedBooks => List.unmodifiable(_savedBooks);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get _userId {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw StateError('Sesi pengguna Supabase belum tersedia.');
    }
    return user.id;
  }

  /// Memuat buku milik pengguna yang sedang aktif.
  Future<void> loadBooks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _client
          .from('saved_books')
          .select()
          .eq('user_id', _userId)
          .order('created_at', ascending: false);

      _savedBooks
        ..clear()
        ..addAll(
          (response as List).map(
            (item) =>
                SavedBook.fromJson(Map<String, dynamic>.from(item as Map)),
          ),
        );
    } catch (error, stackTrace) {
      _errorMessage = 'Gagal memuat koleksi buku.';
      debugPrint('Gagal memuat buku: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Memeriksa apakah buku dari katalog sudah disimpan.
  bool isSaved(Book book) {
    return _savedBooks.any((item) {
      if (book.openLibraryKey != null && book.openLibraryKey!.isNotEmpty) {
        return item.openLibraryKey == book.openLibraryKey;
      }
      return item.title.trim().toLowerCase() == book.title.trim().toLowerCase();
    });
  }

  /// Menyimpan buku katalog atau menghapusnya jika sudah tersimpan.
  Future<void> toggleQuickSave(Book book) async {
    final existingIndex = _savedBooks.indexWhere((item) {
      if (book.openLibraryKey != null && book.openLibraryKey!.isNotEmpty) {
        return item.openLibraryKey == book.openLibraryKey;
      }
      return item.title.trim().toLowerCase() == book.title.trim().toLowerCase();
    });

    try {
      if (existingIndex >= 0) {
        await deleteBook(_savedBooks[existingIndex].id);
        return;
      }

      final newBook = SavedBook(
        id: '',
        title: book.title,
        author: book.author,
        coverUrl: book.coverUrl,
        openLibraryKey: book.openLibraryKey,
        category: book.category,
        color: book.color,
        icon: book.icon,
        status: SavedBook.statusWantToRead,
      );

      await _insertBook(newBook);
    } catch (error, stackTrace) {
      _errorMessage = 'Gagal memperbarui koleksi buku.';
      debugPrint('Gagal quick save: $error');
      debugPrintStack(stackTrace: stackTrace);
      notifyListeners();
    }
  }

  /// Menyimpan buku baru ke database.
  Future<void> addBook(SavedBook savedBook) async {
    try {
      final existingIndex = _savedBooks.indexWhere(
        (item) =>
            item.title.trim().toLowerCase() ==
            savedBook.title.trim().toLowerCase(),
      );

      if (existingIndex >= 0) {
        final existing = _savedBooks[existingIndex];
        final updated = SavedBook(
          id: existing.id,
          title: savedBook.title,
          author: savedBook.author,
          coverUrl: savedBook.coverUrl,
          openLibraryKey: savedBook.openLibraryKey,
          category: savedBook.category,
          color: savedBook.color,
          icon: savedBook.icon,
          status: savedBook.status,
          rating: savedBook.rating,
          notes: savedBook.notes,
          createdAt: existing.createdAt,
          completedAt: savedBook.completedAt,
        );
        await updateBook(updated);
        return;
      }

      await _insertBook(savedBook);
    } catch (error, stackTrace) {
      _errorMessage = 'Gagal menyimpan buku.';
      debugPrint('Gagal menambahkan buku: $error');
      debugPrintStack(stackTrace: stackTrace);
      notifyListeners();
    }
  }

  Future<void> _insertBook(SavedBook book) async {
    final row = await _client
        .from('saved_books')
        .insert(book.toInsertJson(_userId))
        .select()
        .single();

    _savedBooks.insert(0, SavedBook.fromJson(Map<String, dynamic>.from(row)));

    _errorMessage = null;
    notifyListeners();
  }

  /// Memperbarui buku berdasarkan ID Supabase.
  Future<void> updateBook(SavedBook updatedBook) async {
    try {
      final row = await _client
          .from('saved_books')
          .update(updatedBook.toUpdateJson())
          .eq('id', updatedBook.id)
          .eq('user_id', _userId)
          .select()
          .maybeSingle();

      if (row == null) {
        _errorMessage = 'Buku tidak ditemukan atau tidak dapat diperbarui.';
        notifyListeners();
        return;
      }

      final savedBook = SavedBook.fromJson(Map<String, dynamic>.from(row));

      final index = _savedBooks.indexWhere((item) => item.id == savedBook.id);

      if (index >= 0) {
        _savedBooks[index] = savedBook;
      } else {
        _savedBooks.insert(0, savedBook);
      }

      _errorMessage = null;
      notifyListeners();
    } catch (error, stackTrace) {
      _errorMessage = 'Gagal memperbarui buku.';
      debugPrint('Gagal update buku: $error');
      debugPrintStack(stackTrace: stackTrace);
      notifyListeners();
    }
  }

  /// Menghapus buku berdasarkan ID Supabase.
  Future<void> deleteBook(String id) async {
    try {
      await _client
          .from('saved_books')
          .delete()
          .eq('id', id)
          .eq('user_id', _userId);

      _savedBooks.removeWhere((item) => item.id == id);
      _errorMessage = null;
      notifyListeners();
    } catch (error, stackTrace) {
      _errorMessage = 'Gagal menghapus buku.';
      debugPrint('Gagal menghapus buku: $error');
      debugPrintStack(stackTrace: stackTrace);
      notifyListeners();
    }
  }
}
