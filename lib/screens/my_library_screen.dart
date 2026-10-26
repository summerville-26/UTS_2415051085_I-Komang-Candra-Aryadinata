import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../models/saved_book.dart';
import '../widgets/app_error_view.dart';
import 'edit_book_screen.dart';

/// Layar perpustakaan pribadi — menampilkan semua buku yang disimpan pengguna.
///
/// Fitur: filter berdasarkan status, ringkasan jumlah buku,
/// edit status/rating/catatan, dan hapus buku dengan konfirmasi.
class MyLibraryScreen extends StatefulWidget {
  const MyLibraryScreen({
    super.key,
    required this.savedBooks,
    required this.onUpdateBook,
    required this.onDeleteBook,
  });

  final List<SavedBook> savedBooks;
  final void Function(SavedBook updatedBook) onUpdateBook;
  final void Function(String id) onDeleteBook;

  @override
  State<MyLibraryScreen> createState() => _MyLibraryScreenState();
}

class _MyLibraryScreenState extends State<MyLibraryScreen> {
  /// null = tampilkan semua
  String? _activeFilter;

  List<SavedBook> get _filteredBooks {
    if (_activeFilter == null) return widget.savedBooks;
    return widget.savedBooks.where((b) => b.status == _activeFilter).toList();
  }

  Future<void> _openEdit(BuildContext context, SavedBook book) async {
    final result = await Navigator.of(context).push<SavedBook>(
      MaterialPageRoute(builder: (_) => EditBookScreen(savedBook: book)),
    );
    if (result != null) {
      widget.onUpdateBook(result);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perubahan berhasil disimpan.')),
        );
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context, SavedBook book) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Buku'),
        content: Text('Yakin ingin menghapus "${book.title}" dari koleksimu?'),
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

    if (confirmed == true) {
      widget.onDeleteBook(book.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${book.title}" dihapus dari koleksi.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final books = _filteredBooks;
    final total = widget.savedBooks.length;
    final wantToRead = widget.savedBooks
        .where((b) => b.status == SavedBook.statusWantToRead)
        .length;
    final reading = widget.savedBooks
        .where((b) => b.status == SavedBook.statusReading)
        .length;
    final completed = widget.savedBooks
        .where((b) => b.status == SavedBook.statusCompleted)
        .length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Header ────────────────────────────────────────────────
              const Text(
                'My Library',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  color: darkText,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Semua buku yang kamu simpan ada di sini.',
                style: TextStyle(color: secondaryText),
              ),
              const SizedBox(height: 22),

              // ─── Ringkasan statistik ──────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: lightBlue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.auto_stories_rounded,
                      size: 38,
                      color: primaryBlue,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Koleksi kamu',
                            style: TextStyle(color: secondaryText),
                          ),
                          Text(
                            '$total buku tersimpan',
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                              color: darkText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ─── Kartu mini statistik per status ─────────────────────
              if (total > 0)
                Row(
                  children: [
                    _StatChip(
                      label: 'Ingin Dibaca',
                      count: wantToRead,
                      color: const Color(0xFF9333EA),
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      label: 'Sedang',
                      count: reading,
                      color: primaryBlue,
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      label: 'Selesai',
                      count: completed,
                      color: const Color(0xFF16A34A),
                    ),
                  ],
                ),
              const SizedBox(height: 22),

              // ─── Filter chip ──────────────────────────────────────────
              if (total > 0) ...[
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'Semua',
                        isActive: _activeFilter == null,
                        onTap: () => setState(() => _activeFilter = null),
                      ),
                      const SizedBox(width: 8),
                      ...SavedBook.allStatuses.map(
                        (status) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _FilterChip(
                            label: SavedBook.statusLabel(status),
                            isActive: _activeFilter == status,
                            onTap: () => setState(() => _activeFilter = status),
                            color: SavedBook.statusColor(status),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
              ],

              // ─── Daftar buku / empty state ────────────────────────────
              if (widget.savedBooks.isEmpty)
                EmptyStateView(
                  title: 'Koleksimu masih kosong',
                  message:
                      'Simpan buku dari katalog untuk menambah koleksi bacaan.',
                  icon: Icons.bookmark_border_rounded,
                )
              else if (books.isEmpty)
                EmptyStateView(
                  title: 'Tidak ada buku dengan status ini',
                  message: 'Coba filter yang berbeda.',
                  icon: Icons.filter_list_off_rounded,
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: books.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return _SavedBookItem(
                      book: book,
                      onEdit: () => _openEdit(context, book),
                      onDelete: () => _confirmDelete(context, book),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Widget Item Buku Tersimpan ──────────────────────────────────────────────

class _SavedBookItem extends StatelessWidget {
  const _SavedBookItem({
    required this.book,
    required this.onEdit,
    required this.onDelete,
  });

  final SavedBook book;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final statusColor = SavedBook.statusColor(book.status);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EDF5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail buku
          Container(
            width: 52,
            height: 68,
            decoration: BoxDecoration(
              color: book.color ?? const Color(0xFFDDEAFE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              book.icon ?? Icons.menu_book_rounded,
              color: primaryBlue,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),

          // Info buku
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: darkText,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  book.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: secondaryText),
                ),
                const SizedBox(height: 8),

                // Badge status
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            SavedBook.statusIcon(book.status),
                            size: 12,
                            color: statusColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            SavedBook.statusLabel(book.status),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Rating bintang
                    if (book.rating != null) ...[
                      const SizedBox(width: 8),
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            i < (book.rating ?? 0)
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            size: 13,
                            color: const Color(0xFFF59E0B),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                // Catatan (jika ada)
                if (book.notes != null && book.notes!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    book.notes!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: secondaryText,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Tombol aksi
          Column(
            children: [
              IconButton(
                tooltip: 'Edit',
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 18),
                color: primaryBlue,
              ),
              IconButton(
                tooltip: 'Hapus',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                color: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Widget Statistik Mini ───────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Widget Filter Chip ──────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
    this.color,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? primaryBlue;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? activeColor : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : darkText,
          ),
        ),
      ),
    );
  }
}
