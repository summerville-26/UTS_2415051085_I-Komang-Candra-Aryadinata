import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../models/book.dart';
import '../models/saved_book.dart';
import '../widgets/book_grid.dart';
import '../widgets/search_field.dart';
import '../widgets/app_error_view.dart';
import 'book_detail_screen.dart';

/// Layar katalog buku.
///
/// Menampilkan seluruh koleksi buku dengan pencarian langsung.
/// Data buku berasal dari [sampleBooks] — akan diganti dengan
/// Open Library API pada Milestone 8.
class BookCatalogScreen extends StatefulWidget {
  const BookCatalogScreen({
    super.key,
    required this.savedBooks,
    required this.onQuickSave,
    required this.onAddBook,
    required this.onDeleteBook,
  });

  final List<SavedBook> savedBooks;
  final void Function(Book book) onQuickSave;
  final void Function(SavedBook book) onAddBook;
  final void Function(String id) onDeleteBook;

  @override
  State<BookCatalogScreen> createState() => _BookCatalogScreenState();
}

class _BookCatalogScreenState extends State<BookCatalogScreen> {
  String _query = '';

  List<Book> get _filteredBooks {
    if (_query.trim().isEmpty) return sampleBooks;
    final q = _query.toLowerCase();
    return sampleBooks
        .where(
          (book) =>
              book.title.toLowerCase().contains(q) ||
              book.author.toLowerCase().contains(q) ||
              book.category.toLowerCase().contains(q),
        )
        .toList();
  }

  void _openDetail(Book book) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BookDetailScreen(
          book: book,
          savedBooks: widget.savedBooks,
          onAddBook: widget.onAddBook,
          onDeleteBook: widget.onDeleteBook,
          onQuickSave: widget.onQuickSave,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final books = _filteredBooks;

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 700;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: wide ? 32 : 20,
            vertical: 24,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Header ──────────────────────────────────────────────
                  const Text(
                    'Book Catalog',
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      color: darkText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Jelajahi koleksi dan temukan bacaan berikutnya.',
                    style: TextStyle(color: secondaryText),
                  ),
                  const SizedBox(height: 22),

                  // ─── Search field ─────────────────────────────────────────
                  SearchField(
                    hintText: 'Cari judul, penulis, kategori...',
                    onChanged: (value) => setState(() => _query = value),
                  ),
                  const SizedBox(height: 24),

                  // ─── Jumlah hasil ─────────────────────────────────────────
                  Text(
                    _query.isEmpty
                        ? '${books.length} buku tersedia'
                        : '${books.length} buku ditemukan',
                    style: const TextStyle(
                      color: secondaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ─── Grid buku / empty state ──────────────────────────────
                  if (books.isEmpty)
                    EmptyStateView(
                      title: 'Buku tidak ditemukan',
                      message:
                          'Tidak ada buku yang cocok dengan "$_query".\nCoba kata kunci yang berbeda.',
                      icon: Icons.search_off_rounded,
                    )
                  else
                    BookGrid(
                      books: books,
                      savedBooks: widget.savedBooks,
                      onQuickSave: widget.onQuickSave,
                      onCardTap: _openDetail,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
