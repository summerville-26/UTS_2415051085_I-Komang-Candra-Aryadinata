import 'package:flutter/material.dart';

import '../models/book.dart';
import '../models/saved_book.dart';
import 'book_card.dart';

/// Grid responsif yang menampilkan daftar buku.
///
/// Jumlah kolom menyesuaikan lebar layar:
/// - ≥ 900 px: 4 kolom
/// - ≥ 560 px: 3 kolom
/// - < 560 px: 2 kolom
///
/// Widget ini tidak bertanggung jawab atas navigasi.
/// Navigasi ke [BookDetailScreen] ditangani oleh layar induk via [onCardTap].
class BookGrid extends StatelessWidget {
  const BookGrid({
    super.key,
    required this.books,
    required this.savedBooks,
    required this.onQuickSave,
    required this.onCardTap,
  });

  final List<Book> books;

  /// Daftar buku yang sudah disimpan — digunakan untuk menentukan status bookmark.
  final List<SavedBook> savedBooks;

  /// Dipanggil saat ikon bookmark ditekan. Induk menangani logika tambah/hapus.
  final void Function(Book book) onQuickSave;

  /// Dipanggil saat kartu buku ditekan. Induk menangani navigasi ke detail.
  final void Function(Book book) onCardTap;

  bool _isSaved(String title) => savedBooks.any((s) => s.title == title);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 900
            ? 4
            : width >= 560
            ? 3
            : 2;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: books.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 250,
          ),
          itemBuilder: (context, index) {
            final book = books[index];
            return BookCard(
              book: book,
              isSaved: _isSaved(book.title),
              onToggleSaved: () => onQuickSave(book),
              onOpen: () => onCardTap(book),
            );
          },
        );
      },
    );
  }
}
