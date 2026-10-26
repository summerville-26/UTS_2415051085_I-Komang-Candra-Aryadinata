import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../models/book.dart';
import '../models/saved_book.dart';
import '../providers/book_api_provider.dart';
import '../widgets/book_grid.dart';
import '../widgets/search_field.dart';
import '../widgets/app_error_view.dart';
import 'book_detail_screen.dart';

/// Katalog buku yang mengambil data dari Open Library API.
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
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  bool _initialFetchStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialFetchStarted) {
      _initialFetchStarted = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        final provider = context.read<BookApiProvider>();
        if (provider.books.isEmpty &&
            !provider.isLoading &&
            provider.errorMessage == null) {
          provider.fetchBooks(query: 'fiction');
        }
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchBooks(String value) {
    setState(() => _query = value);

    final query = value.trim();
    if (query.isEmpty) {
      context.read<BookApiProvider>().fetchBooks(query: 'fiction');
    } else {
      context.read<BookApiProvider>().searchBooks(query);
    }
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
    final apiProvider = context.watch<BookApiProvider>();
    final books = apiProvider.books;

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
                  SearchField(
                    hintText: 'Cari judul, penulis, kategori...',
                    onChanged: _searchBooks,
                  ),
                  const SizedBox(height: 24),
                  if (apiProvider.isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: LinearProgressIndicator(),
                    ),
                  if (apiProvider.errorMessage != null) ...[
                    AppErrorView(
                      message: apiProvider.errorMessage!,
                      onRetry: () => apiProvider.fetchBooks(
                        query: _query.trim().isEmpty ? 'fiction' : _query,
                      ),
                    ),
                  ] else ...[
                    Text(
                      apiProvider.isLoading
                          ? 'Memuat buku...'
                          : _query.trim().isEmpty
                          ? '${books.length} buku tersedia'
                          : '${books.length} buku ditemukan',
                      style: const TextStyle(
                        color: secondaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (!apiProvider.isLoading && books.isEmpty)
                      EmptyStateView(
                        title: 'Buku tidak ditemukan',
                        message: _query.trim().isEmpty
                            ? 'Belum ada data buku yang tersedia.'
                            : 'Tidak ada buku yang cocok dengan "$_query".\nCoba kata kunci yang berbeda.',
                        icon: Icons.search_off_rounded,
                      )
                    else if (books.isNotEmpty)
                      BookGrid(
                        books: books,
                        savedBooks: widget.savedBooks,
                        onQuickSave: widget.onQuickSave,
                        onCardTap: _openDetail,
                      ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
