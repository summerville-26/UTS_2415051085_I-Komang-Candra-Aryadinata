import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../models/book.dart';
import '../models/saved_book.dart';
import '../services/open_library_service.dart';
import 'add_book_screen.dart';

class BookDetailScreen extends StatefulWidget {
  const BookDetailScreen({
    super.key,
    required this.book,
    required this.savedBooks,
    required this.onAddBook,
    required this.onDeleteBook,
    required this.onQuickSave,
  });

  final Book book;
  final List<SavedBook> savedBooks;
  final void Function(SavedBook book) onAddBook;
  final void Function(String id) onDeleteBook;
  final void Function(Book book) onQuickSave;

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  late final OpenLibraryService _service;

  String? _description;
  bool _isLoadingDescription = false;
  bool _descriptionFailed = false;

  @override
  void initState() {
    super.initState();
    _service = OpenLibraryService();
    _loadDescription();
  }

  Future<void> _loadDescription() async {
    final book = widget.book;

    // Buku lokal tetap menggunakan deskripsi yang sudah dimilikinya.
    if (book.openLibraryKey == null) {
      if (mounted) {
        setState(() {
          _description = book.description.trim().isNotEmpty
              ? book.description.trim()
              : null;
        });
      }
      return;
    }

    setState(() {
      _isLoadingDescription = true;
      _descriptionFailed = false;
    });

    try {
      final description = await _service.fetchWorkDescription(
        book.openLibraryKey,
      );

      if (!mounted) return;

      setState(() {
        _description = description;
        _isLoadingDescription = false;
      });
    } catch (error) {
      debugPrint('Gagal mengambil deskripsi buku: $error');

      if (!mounted) return;

      setState(() {
        _description = null;
        _isLoadingDescription = false;
        _descriptionFailed = true;
      });
    }
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  SavedBook? get _savedBook {
    for (final saved in widget.savedBooks) {
      if (saved.title == widget.book.title) {
        return saved;
      }
    }
    return null;
  }

  bool get _isSaved => _savedBook != null;

  Future<void> _handleAddToList() async {
    final result = await Navigator.of(context).push<SavedBook>(
      MaterialPageRoute(builder: (_) => AddBookScreen(book: widget.book)),
    );

    if (result != null) {
      widget.onAddBook(result);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${widget.book.title}" ditambahkan ke koleksi.'),
          backgroundColor: const Color(0xFF16A34A),
        ),
      );
    }
  }

  Future<void> _handleRemoveFromList() async {
    final saved = _savedBook;
    if (saved == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus dari Koleksi'),
        content: Text(
          'Yakin ingin menghapus "${widget.book.title}" '
          'dari daftar bacaanmu?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      widget.onDeleteBook(saved.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${widget.book.title}" dihapus dari koleksi.')),
      );

      Navigator.of(context).pop();
    }
  }

  Widget _buildBookCover(Book book) {
    final coverUrl = book.coverUrl;

    return Container(
      width: double.infinity,
      height: 230,
      decoration: BoxDecoration(
        color: book.color,
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,
      child: coverUrl != null && coverUrl.trim().isNotEmpty
          ? Image.network(
              coverUrl,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;

                return Center(
                  child: CircularProgressIndicator(
                    value: progress.expectedTotalBytes != null
                        ? progress.cumulativeBytesLoaded /
                              progress.expectedTotalBytes!
                        : null,
                    color: primaryBlue,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return _buildCoverFallback(book);
              },
            )
          : _buildCoverFallback(book),
    );
  }

  Widget _buildCoverFallback(Book book) {
    return Center(child: Icon(book.icon, size: 85, color: primaryBlue));
  }

  Widget _buildDescription() {
    if (_isLoadingDescription) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Memuat deskripsi buku...',
                style: TextStyle(color: secondaryText),
              ),
            ),
          ],
        ),
      );
    }

    if (_descriptionFailed) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Deskripsi buku tidak dapat dimuat saat ini.',
            style: TextStyle(color: secondaryText, height: 1.7, fontSize: 14),
          ),
          TextButton.icon(
            onPressed: _loadDescription,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba lagi'),
          ),
        ],
      );
    }

    if (_description == null || _description!.trim().isEmpty) {
      return const Text(
        'Deskripsi buku belum tersedia di Open Library.',
        style: TextStyle(color: secondaryText, height: 1.7, fontSize: 14),
      );
    }

    return Text(
      _description!,
      style: const TextStyle(color: secondaryText, height: 1.7, fontSize: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    final saved = _savedBook;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Buku')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBookCover(book),
            const SizedBox(height: 24),

            Text(
              book.title,
              style: const TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
                color: darkText,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              'Oleh ${book.author}',
              style: const TextStyle(color: secondaryText, fontSize: 15),
            ),
            const SizedBox(height: 14),

            Chip(
              label: Text(book.category),
              avatar: const Icon(Icons.category_outlined, size: 17),
              backgroundColor: lightBlue,
              side: BorderSide.none,
            ),

            if (saved != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: SavedBook.statusColor(saved.status)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: SavedBook.statusColor(saved.status)
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      SavedBook.statusIcon(saved.status),
                      size: 16,
                      color: SavedBook.statusColor(saved.status),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      SavedBook.statusLabel(saved.status),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: SavedBook.statusColor(saved.status),
                      ),
                    ),
                    if (saved.rating != null) ...[
                      const SizedBox(width: 8),
                      const Text('·', style: TextStyle(color: secondaryText)),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: Color(0xFFF59E0B),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        saved.rating!.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: darkText,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            const Text(
              'Tentang buku',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: darkText,
              ),
            ),
            const SizedBox(height: 8),
            _buildDescription(),

            const SizedBox(height: 32),

            if (_isSaved) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _handleRemoveFromList,
                  icon: const Icon(
                    Icons.bookmark_remove_rounded,
                    color: Colors.red,
                  ),
                  label: const Text(
                    'Hapus dari Koleksi',
                    style: TextStyle(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _handleAddToList,
                  icon: const Icon(Icons.bookmark_add_rounded),
                  label: const Text('Tambah ke Daftar Bacaan'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
