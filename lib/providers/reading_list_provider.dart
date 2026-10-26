import 'package:flutter/foundation.dart';

import '../models/book.dart';
import '../models/saved_book.dart';

/// Mengelola daftar bacaan yang digunakan bersama oleh beberapa screen.
class ReadingListProvider extends ChangeNotifier {
  final List<SavedBook> _savedBooks = [];

  /// Daftar bacaan yang dapat dibaca oleh screen.
  List<SavedBook> get savedBooks => List.unmodifiable(_savedBooks);

  /// Memeriksa apakah buku sudah tersimpan.
  bool isSaved(Book book) {
    return _savedBooks.any((item) => item.title == book.title);
  }

  /// Menyimpan buku atau menghapusnya jika sudah tersimpan.
  void toggleQuickSave(Book book) {
    final existingIndex = _savedBooks.indexWhere(
      (item) => item.title == book.title,
    );

    if (existingIndex >= 0) {
      _savedBooks.removeAt(existingIndex);
    } else {
      _savedBooks.add(
        SavedBook(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: book.title,
          author: book.author,
          coverUrl: book.coverUrl,
          openLibraryKey: book.openLibraryKey,
          category: book.category,
          color: book.color,
          icon: book.icon,
          status: SavedBook.statusWantToRead,
        ),
      );
    }

    notifyListeners();
  }

  /// Menambahkan buku baru atau mengganti buku dengan judul yang sama.
  void addBook(SavedBook savedBook) {
    _savedBooks.removeWhere((item) => item.title == savedBook.title);
    _savedBooks.add(savedBook);
    notifyListeners();
  }

  /// Memperbarui buku berdasarkan ID.
  void updateBook(SavedBook updatedBook) {
    final index = _savedBooks.indexWhere((item) => item.id == updatedBook.id);

    if (index == -1) return;

    _savedBooks[index] = updatedBook;
    notifyListeners();
  }

  /// Menghapus buku berdasarkan ID.
  void deleteBook(String id) {
    final oldLength = _savedBooks.length;
    _savedBooks.removeWhere((item) => item.id == id);

    if (_savedBooks.length != oldLength) {
      notifyListeners();
    }
  }
}
