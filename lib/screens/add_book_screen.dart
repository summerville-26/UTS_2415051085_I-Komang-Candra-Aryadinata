import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../models/book.dart';
import '../models/saved_book.dart';

/// Layar form untuk menambahkan buku ke daftar bacaan pribadi.
class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key, required this.book});

  final Book book;

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  String _selectedStatus = SavedBook.statusWantToRead;
  double _rating = 0;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final savedBook = SavedBook(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: widget.book.title,
      author: widget.book.author,
      coverUrl: widget.book.coverUrl,
      openLibraryKey: widget.book.openLibraryKey,
      category: widget.book.category,
      color: widget.book.color,
      icon: widget.book.icon,
      status: _selectedStatus,
      rating: _rating > 0 ? _rating : null,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    Navigator.of(context).pop(savedBook);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        title: const Text('Tambah ke Koleksi'),
        backgroundColor: pageBackground,
        foregroundColor: darkText,
        iconTheme: const IconThemeData(color: primaryPurple),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Info buku (read-only) ─────────────────────────────────────
              _BookInfoCard(book: widget.book),
              const SizedBox(height: spacingLg),

              // ─── Status membaca ────────────────────────────────────────────
              _SectionHeader(
                icon: Icons.bookmark_rounded,
                title: 'Status Membaca',
                subtitle: 'Pilih status yang sesuai kondisi bacaanmu.',
              ),
              const SizedBox(height: 12),
              _StatusSelector(
                selected: _selectedStatus,
                onChanged: (status) => setState(() => _selectedStatus = status),
              ),
              const SizedBox(height: spacingLg),

              // ─── Rating ────────────────────────────────────────────────────
              Row(
                children: [
                  _SectionHeader(
                    icon: Icons.star_rounded,
                    title: 'Rating',
                  ),
                  const Spacer(),
                  Text(
                    _rating == 0 ? 'Belum dirating' : '${_rating.toInt()}/5',
                    style: const TextStyle(color: secondaryText, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _StarRatingInput(
                rating: _rating,
                onChanged: (r) => setState(() => _rating = r),
              ),
              const SizedBox(height: spacingLg),

              // ─── Catatan ───────────────────────────────────────────────────
              _SectionHeader(
                icon: Icons.edit_note_rounded,
                title: 'Catatan Pribadi',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                maxLines: 4,
                maxLength: 500,
                decoration: const InputDecoration(
                  hintText: 'Tulis catatan, kutipan favorit, atau kesan kamu...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: spacingXl),

              // ─── Tombol simpan ─────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.bookmark_add_rounded),
                  label: const Text('Simpan ke Koleksi'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Reusable widgets ─────────────────────────────────────────────────────────

class _BookInfoCard extends StatelessWidget {
  const _BookInfoCard({required this.book});
  final Book book;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(spacingMd),
      decoration: BoxDecoration(
        color: cardSurface,
        borderRadius: BorderRadius.circular(radiusMd),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: primaryPurple.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(radiusSm),
            child: Container(
              width: 58,
              height: 76,
              color: book.color,
              child: book.coverUrl != null && book.coverUrl!.isNotEmpty
                  ? Image.network(
                      book.coverUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(book.icon, color: primaryPurple, size: 30),
                    )
                  : Icon(book.icon, color: primaryPurple, size: 30),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: darkText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  book.author,
                  style: const TextStyle(color: secondaryText, fontSize: 13),
                ),
                const SizedBox(height: 7),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: softPurple,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    book.category,
                    style: const TextStyle(
                      fontSize: 11,
                      color: primaryPurple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: primaryPurple, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: darkText,
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 3),
          Text(
            subtitle!,
            style: const TextStyle(color: secondaryText, fontSize: 12),
          ),
        ],
      ],
    );
  }
}

// ─── Status Selector ──────────────────────────────────────────────────────────

class _StatusSelector extends StatelessWidget {
  const _StatusSelector({required this.selected, required this.onChanged});

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: SavedBook.allStatuses.map((status) {
        final isActive = selected == status;
        final color = SavedBook.statusColor(status);

        return Padding(
          padding: const EdgeInsets.only(bottom: spacingSm),
          child: InkWell(
            onTap: () => onChanged(status),
            borderRadius: BorderRadius.circular(radiusMd),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: spacingMd, vertical: 14),
              decoration: BoxDecoration(
                color: isActive ? color.withValues(alpha: 0.08) : cardSurface,
                borderRadius: BorderRadius.circular(radiusMd),
                border: Border.all(
                  color: isActive ? color : borderColor,
                  width: isActive ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: isActive
                          ? color.withValues(alpha: 0.15)
                          : const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      SavedBook.statusIcon(status),
                      size: 18,
                      color: isActive ? color : secondaryText,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      SavedBook.statusLabel(status),
                      style: TextStyle(
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        color: isActive ? color : darkText,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (isActive)
                    Icon(
                      Icons.check_circle_rounded,
                      color: color,
                      size: 20,
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Star Rating Input ────────────────────────────────────────────────────────

class _StarRatingInput extends StatelessWidget {
  const _StarRatingInput({required this.rating, required this.onChanged});

  final double rating;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        final starValue = index + 1.0;
        return GestureDetector(
          onTap: () => onChanged(rating == starValue ? 0 : starValue),
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: Icon(
                index < rating
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
                key: ValueKey('$index-${index < rating}'),
                color: warningColor,
                size: 38,
              ),
            ),
          ),
        );
      }),
    );
  }
}
