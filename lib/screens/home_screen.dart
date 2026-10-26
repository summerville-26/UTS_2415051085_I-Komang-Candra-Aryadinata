import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../models/book.dart';
import '../models/saved_book.dart';
import '../widgets/book_grid.dart';
import 'book_detail_screen.dart';
import 'profile_screen.dart';

// Layar beranda BookNest.
// Menampilkan sambutan, ringkasan koleksi, kategori pilihan,
// grid rekomendasi buku, dan akses ke halaman profil.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.savedBooks,
    required this.onOpenCatalog,
    required this.onOpenLibrary,
    required this.onQuickSave,
    required this.onAddBook,
    required this.onDeleteBook,
  });

  final List<SavedBook> savedBooks;
  final VoidCallback onOpenCatalog;
  final VoidCallback onOpenLibrary;
  final void Function(Book book) onQuickSave;
  final void Function(SavedBook book) onAddBook;
  final void Function(String id) onDeleteBook;

  void _openDetail(BuildContext context, Book book) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BookDetailScreen(
          book: book,
          savedBooks: savedBooks,
          onAddBook: onAddBook,
          onDeleteBook: onDeleteBook,
          onQuickSave: onQuickSave,
        ),
      ),
    );
  }

  void _openProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProfileScreen(savedBooks: savedBooks),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 700;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: wide ? 32 : 20,
            vertical: 20,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: primaryBlue,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.auto_stories_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'BookNest',
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                                color: darkText,
                              ),
                            ),
                            Text(
                              'Your personal reading space',
                              style: TextStyle(
                                fontSize: 12,
                                color: secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Tombol untuk membuka halaman profil
                      IconButton(
                        tooltip: 'Profil',
                        onPressed: () => _openProfile(context),
                        icon: const Icon(
                          Icons.account_circle_outlined,
                          color: primaryBlue,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Sambutan
                  const Text(
                    'Halo, pembaca! 👋',
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      color: darkText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Buku baru, wawasan baru. Mulai perjalananmu hari ini.',
                    style: TextStyle(
                      fontSize: 14,
                      color: secondaryText,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Banner utama
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF60A5FA)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'RUANG BACA KAMU',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                'Satu buku,\nbanyak kemungkinan.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 23,
                                  height: 1.25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Temukan bacaan yang sesuai dengan minatmu.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                              FilledButton(
                                onPressed: onOpenCatalog,
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: primaryBlue,
                                ),
                                child: const Text('Jelajahi Buku'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.auto_stories_rounded,
                          color: Color(0xFFDCEBFF),
                          size: 76,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Rekomendasi buku
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Rekomendasi buku',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: darkText,
                        ),
                      ),
                      TextButton(
                        onPressed: onOpenCatalog,
                        child: const Text('Lihat semua'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  BookGrid(
                    books: sampleBooks.take(4).toList(),
                    savedBooks: savedBooks,
                    onQuickSave: onQuickSave,
                    onCardTap: (book) => _openDetail(context, book),
                  ),
                  const SizedBox(height: 24),

                  // Ringkasan koleksi
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.bookmark_added_rounded,
                          color: primaryBlue,
                          size: 30,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Koleksi bacaanmu',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: darkText,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${savedBooks.length} buku tersimpan',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: onOpenLibrary,
                          icon: const Icon(Icons.arrow_forward_rounded),
                        ),
                      ],
                    ),
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
