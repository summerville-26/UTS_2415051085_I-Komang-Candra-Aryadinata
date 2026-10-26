import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../models/saved_book.dart';

/// Layar form untuk mengedit data buku yang sudah tersimpan di koleksi.
///
/// Menerima [SavedBook] dan mengembalikan [SavedBook] yang sudah diperbarui
/// via [Navigator.pop] saat pengguna menyimpan perubahan.
/// Integrasi Supabase dilakukan pada Milestone 11.
class EditBookScreen extends StatefulWidget {
  const EditBookScreen({super.key, required this.savedBook});

  final SavedBook savedBook;

  @override
  State<EditBookScreen> createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _notesController;

  late String _selectedStatus;
  late double _rating;

  @override
  void initState() {
    super.initState();
    // Pre-fill dengan data yang sudah ada
    _selectedStatus = widget.savedBook.status;
    _rating = widget.savedBook.rating ?? 0;
    _notesController = TextEditingController(
      text: widget.savedBook.notes ?? '',
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final updated = widget.savedBook.copyWithUpdated(
      status: _selectedStatus,
      rating: _rating > 0 ? _rating : null,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    Navigator.of(context).pop(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Buku')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Info buku (read-only) ───────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 72,
                      decoration: BoxDecoration(
                        color:
                            widget.savedBook.color ?? const Color(0xFFDDEAFE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        widget.savedBook.icon ?? Icons.menu_book_rounded,
                        color: primaryBlue,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.savedBook.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: darkText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.savedBook.author,
                            style: const TextStyle(
                              color: secondaryText,
                              fontSize: 13,
                            ),
                          ),
                          if (widget.savedBook.category != null) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: lightBlue,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                widget.savedBook.category!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: primaryBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ─── Status membaca ──────────────────────────────────────────
              const Text(
                'Status Membaca',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: darkText,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Perbarui status sesuai perkembangan bacaanmu.',
                style: TextStyle(color: secondaryText, fontSize: 12),
              ),
              const SizedBox(height: 12),
              _StatusSelector(
                selected: _selectedStatus,
                onChanged: (status) => setState(() => _selectedStatus = status),
              ),
              const SizedBox(height: 28),

              // ─── Rating ──────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Rating',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: darkText,
                    ),
                  ),
                  Text(
                    _rating == 0 ? 'Belum dirating' : '${_rating.toInt()}/5',
                    style: const TextStyle(color: secondaryText, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _StarRatingInput(
                rating: _rating,
                onChanged: (r) => setState(() => _rating = r),
              ),
              const SizedBox(height: 28),

              // ─── Catatan ─────────────────────────────────────────────────
              const Text(
                'Catatan Pribadi',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: darkText,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 4,
                maxLength: 500,
                decoration: const InputDecoration(
                  hintText:
                      'Tulis catatan, kutipan favorit, atau kesan kamu...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 32),

              // ─── Tombol simpan ───────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.save_rounded),
                  label: const Text('Simpan Perubahan'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
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

// ─── Widget Pemilih Status ───────────────────────────────────────────────────

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
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () => onChanged(status),
            borderRadius: BorderRadius.circular(14),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                color: isActive ? color.withValues(alpha: 0.08) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isActive ? color : const Color(0xFFE2E8F0),
                  width: isActive ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    SavedBook.statusIcon(status),
                    size: 20,
                    color: isActive ? color : secondaryText,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    SavedBook.statusLabel(status),
                    style: TextStyle(
                      fontWeight: isActive
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isActive ? color : darkText,
                    ),
                  ),
                  const Spacer(),
                  if (isActive)
                    Icon(Icons.check_circle_rounded, color: color, size: 20),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Widget Input Bintang Rating ─────────────────────────────────────────────

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
            padding: const EdgeInsets.only(right: 6),
            child: Icon(
              index < rating ? Icons.star_rounded : Icons.star_border_rounded,
              color: const Color(0xFFF59E0B),
              size: 36,
            ),
          ),
        );
      }),
    );
  }
}
