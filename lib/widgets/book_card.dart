import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../models/book.dart';

/// Kartu buku responsif untuk grid katalog.
/// Menampilkan sampul, judul, penulis, kategori, dan tombol bookmark.
class BookCard extends StatelessWidget {
  const BookCard({
    super.key,
    required this.book,
    required this.isSaved,
    required this.onToggleSaved,
    required this.onOpen,
  });

  final Book book;
  final bool isSaved;
  final VoidCallback onToggleSaved;
  final VoidCallback onOpen;

  Widget _buildCoverFallback() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            book.color.withValues(alpha: 0.8),
            book.color,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(radiusMd),
      ),
      child: Icon(
        book.icon,
        color: primaryPurple.withValues(alpha: 0.7),
        size: 40,
      ),
    );
  }

  Widget _buildBookCover() {
    final coverUrl = book.coverUrl;
    if (coverUrl == null || coverUrl.trim().isEmpty) {
      return _buildCoverFallback();
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(radiusMd),
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Image.network(
          coverUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: book.color,
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: primaryPurple,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => _buildCoverFallback(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(radiusMd),
        splashColor: primaryPurple.withValues(alpha: 0.08),
        highlightColor: primaryPurple.withValues(alpha: 0.04),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: cardSurface,
            borderRadius: BorderRadius.circular(radiusMd),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: primaryPurple.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sampul dengan tombol bookmark
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(child: _buildBookCover()),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: onToggleSaved,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isSaved
                                ? primaryPurple
                                : Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(radiusSm),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            isSaved
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            color: isSaved ? Colors.white : primaryPurple,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Informasi buku
              Text(
                book.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: darkText,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                book.author,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: secondaryText),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: softPurple,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  book.category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 9,
                    color: primaryPurple,
                    fontWeight: FontWeight.w600,
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
