import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../models/book.dart';

/// Kartu buku yang digunakan di grid katalog.
/// Menampilkan ikon buku, judul, penulis, dan kategori.
class BookCard extends StatelessWidget {
  const BookCard({
    super.key,
    required this.book,
    required this.isSaved,
    required this.onToggleSaved,
    required this.onOpen,
  });

  final Book book;

  /// True jika buku sudah ada di daftar bacaan pengguna.
  final bool isSaved;

  /// Dipanggil saat ikon bookmark ditekan (quick save/unsave).
  final VoidCallback onToggleSaved;

  /// Dipanggil saat kartu ditekan (membuka BookDetailScreen).
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE8EDF5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Area sampul buku ────────────────────────────────────────────
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: book.color,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(book.icon, color: primaryBlue, size: 43),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // ─── Info buku ───────────────────────────────────────────────────
            Text(
              book.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: darkText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              book.author,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: secondaryText),
            ),
            const SizedBox(height: 5),
            Text(
              book.category,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, color: primaryBlue),
            ),
          ],
        ),
      ),
    );
  }
}
