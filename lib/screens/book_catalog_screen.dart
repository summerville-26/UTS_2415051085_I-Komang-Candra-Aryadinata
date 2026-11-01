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

/// Katalog buku dari Open Library API dengan desain modern.
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
                  // ─── Header ───────────────────────────────────────────────
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [primaryPurple, deepPurple],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(radiusMd),
                        ),
                        child: const Icon(
                          Icons.explore_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Katalog Buku',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: darkText,
                              ),
                            ),
                            Text(
                              'Jelajahi koleksi & temukan bacaan berikutnya.',
                              style: TextStyle(
                                color: secondaryText,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: spacingMd),

                  // ─── Search ───────────────────────────────────────────────
                  SearchField(
                    controller: _searchController,
                    hintText: 'Cari judul, penulis, kategori...',
                    onChanged: _searchBooks,
                  ),
                  const SizedBox(height: spacingMd),

                  // ─── Loading bar ──────────────────────────────────────────
                  if (apiProvider.isLoading)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: const LinearProgressIndicator(
                        minHeight: 3,
                        color: primaryPurple,
                        backgroundColor: softPurple,
                      ),
                    ),
                  if (apiProvider.isLoading)
                    const SizedBox(height: spacingSm),

                  // ─── Results ──────────────────────────────────────────────
                  if (apiProvider.errorMessage != null) ...[
                    AppErrorView(
                      message: apiProvider.errorMessage!,
                      onRetry: () => apiProvider.fetchBooks(
                        query: _query.trim().isEmpty ? 'fiction' : _query,
                      ),
                    ),
                  ] else ...[
                    // Result count chip
                    if (!apiProvider.isLoading || books.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: softPurple,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          apiProvider.isLoading
                              ? 'Memuat buku...'
                              : _query.trim().isEmpty
                              ? '${books.length} buku tersedia'
                              : '${books.length} buku ditemukan untuk "$_query"',
                          style: const TextStyle(
                            color: primaryPurple,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: spacingMd),

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
