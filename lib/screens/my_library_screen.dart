import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../models/saved_book.dart';
import '../widgets/app_error_view.dart';
import 'edit_book_screen.dart';

/// Layar perpustakaan pribadi — menampilkan semua buku yang disimpan pengguna.
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
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Perubahan berhasil disimpan.'),
              ],
            ),
            backgroundColor: successColor,
          ),
        );
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context, SavedBook book) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Buku'),
        content: Text(
          'Yakin ingin menghapus "${book.title}" dari koleksimu?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: errorColor),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      widget.onDeleteBook(book.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.delete_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('"${book.title}" dihapus dari koleksi.'),
                ),
              ],
            ),
          ),
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
              constraints: const BoxConstraints(maxWidth: 900),
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
                          Icons.collections_bookmark_rounded,
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
                              'Koleksi Saya',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: darkText,
                              ),
                            ),
                            Text(
                              'Semua buku yang kamu simpan ada di sini.',
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

                  // ─── Stats Overview ───────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(spacingMd),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [primaryPurple, deepPurple],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(radiusLg),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(radiusMd),
                          ),
                          child: const Icon(
                            Icons.auto_stories_rounded,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Koleksi kamu',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$total buku tersimpan',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: spacingSm),

                  // ─── Stat chips ───────────────────────────────────────────
                  if (total > 0)
                    Row(
                      children: [
                        _StatChip(
                          label: 'Ingin Dibaca',
                          count: wantToRead,
                          icon: Icons.bookmark_rounded,
                          color: deepPurple,
                        ),
                        const SizedBox(width: spacingSm),
                        _StatChip(
                          label: 'Sedang Baca',
                          count: reading,
                          icon: Icons.menu_book_rounded,
                          color: warningColor,
                        ),
                        const SizedBox(width: spacingSm),
                        _StatChip(
                          label: 'Selesai',
                          count: completed,
                          icon: Icons.check_circle_rounded,
                          color: successColor,
                        ),
                      ],
                    ),
                  const SizedBox(height: spacingMd),

                  // ─── Filter chips ─────────────────────────────────────────
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
                          const SizedBox(width: spacingSm),
                          ...SavedBook.allStatuses.map(
                            (status) => Padding(
                              padding: const EdgeInsets.only(right: spacingSm),
                              child: _FilterChip(
                                label: SavedBook.statusLabel(status),
                                isActive: _activeFilter == status,
                                onTap: () =>
                                    setState(() => _activeFilter = status),
                                color: SavedBook.statusColor(status),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: spacingMd),
                  ],

                  // ─── Book list ────────────────────────────────────────────
                  if (widget.savedBooks.isEmpty)
                    EmptyStateView(
                      title: 'Koleksimu masih kosong',
                      message:
                          'Simpan buku dari katalog untuk menambah koleksi bacaan.',
                      icon: Icons.collections_bookmark_outlined,
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
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
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
      },
    );
  }
}

// ─── Saved Book Item ──────────────────────────────────────────────────────────

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
    final hasCover = book.coverUrl != null && book.coverUrl!.trim().isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(radiusMd),
        onTap: onEdit,
        splashColor: primaryPurple.withValues(alpha: 0.06),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardSurface,
            borderRadius: BorderRadius.circular(radiusMd),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: primaryPurple.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(radiusSm),
                child: Container(
                  width: 54,
                  height: 72,
                  color: book.color ?? softPurple,
                  child: hasCover
                      ? Image.network(
                          book.coverUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            book.icon ?? Icons.menu_book_rounded,
                            color: primaryPurple,
                            size: 28,
                          ),
                        )
                      : Icon(
                          book.icon ?? Icons.menu_book_rounded,
                          color: primaryPurple,
                          size: 28,
                        ),
                ),
              ),
              const SizedBox(width: 12),

              // Book info
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
                        height: 1.3,
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

                    // Status + rating row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                SavedBook.statusIcon(book.status),
                                size: 11,
                                color: statusColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                SavedBook.statusLabel(book.status),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ),
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
                                color: warningColor,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    // Notes
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
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Action buttons
              Column(
                children: [
                  _actionButton(
                    icon: Icons.edit_rounded,
                    color: primaryPurple,
                    tooltip: 'Edit',
                    onTap: onEdit,
                  ),
                  const SizedBox(height: 4),
                  _actionButton(
                    icon: Icons.delete_rounded,
                    color: errorColor,
                    tooltip: 'Hapus',
                    onTap: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }
}

// ─── Stat Chip ────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
  });

  final String label;
  final int count;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(radiusMd),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
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
                fontSize: 9,
                color: color.withValues(alpha: 0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Filter Chip ──────────────────────────────────────────────────────────────

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
    final activeColor = color ?? primaryPurple;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? activeColor : cardSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? activeColor : borderColor,
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
