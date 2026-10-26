import 'package:flutter/material.dart';

/// Merepresentasikan data buku dari katalog Open Library.
class Book {
  const Book({
    required this.title,
    required this.author,
    required this.category,
    required this.color,
    required this.icon,
    this.description = 'Temukan wawasan dan pengalaman baru melalui buku ini.',
    this.openLibraryKey,
    this.coverUrl,
  });

  /// Mengubah data JSON dari Open Library menjadi objek Book.
  factory Book.fromOpenLibraryJson(Map<String, dynamic> json) {
    // Mengambil daftar penulis.
    final rawAuthors = json['author_name'];
    final List<String> authors = rawAuthors is List
        ? rawAuthors.whereType<String>().toList()
        : <String>[];

    // Mengambil daftar subjek atau kategori.
    final rawSubjects = json['subject'];
    final List<String> subjects = rawSubjects is List
        ? rawSubjects.whereType<String>().toList()
        : <String>[];

    final rawKey = json['key'];
    final rawTitle = json['title'];
    final rawCoverId = json['cover_i'];

    // Memastikan judul tersedia.
    final String title = rawTitle is String && rawTitle.trim().isNotEmpty
        ? rawTitle.trim()
        : 'Judul tidak tersedia';

    // Memastikan penulis tersedia.
    final String author = authors.isNotEmpty
        ? authors.join(', ')
        : 'Penulis tidak diketahui';

    // Mengambil kategori pertama jika tersedia.
    final String category = subjects.isNotEmpty ? subjects.first : 'Umum';

    // Menyimpan identitas karya Open Library.
    final String? openLibraryKey = rawKey is String && rawKey.trim().isNotEmpty
        ? rawKey.trim()
        : null;

    // Membuat URL sampul dari ID sampul Open Library.
    // URL harus berupa alamat langsung, bukan tautan Markdown.
    final String? coverUrl = rawCoverId is int
        ? 'https://covers.openlibrary.org/b/id/$rawCoverId-M.jpg'
        : null;

    return Book(
      title: title,
      author: author,
      category: category,
      color: _colorForCategory(category),
      icon: _iconForCategory(category),
      description: 'Buku "$title" oleh $author.',
      openLibraryKey: openLibraryKey,
      coverUrl: coverUrl,
    );
  }

  /// Menentukan warna kartu berdasarkan kategori buku.
  static Color _colorForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'fiction':
      case 'novel':
        return const Color(0xFFFFDCDC);

      case 'science':
      case 'technology':
        return const Color(0xFFD7E9FF);

      case 'business':
      case 'finance':
        return const Color(0xFFFFE8C7);

      case 'philosophy':
        return const Color(0xFFE9DDFC);

      default:
        return const Color(0xFFDDEAFE);
    }
  }

  /// Menentukan ikon berdasarkan kategori buku.
  static IconData _iconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'fiction':
      case 'novel':
        return Icons.menu_book;

      case 'science':
      case 'technology':
        return Icons.science_outlined;

      case 'business':
      case 'finance':
        return Icons.account_balance_wallet_outlined;

      case 'philosophy':
        return Icons.psychology_outlined;

      default:
        return Icons.auto_stories;
    }
  }

  final String title;
  final String author;
  final String category;
  final Color color;
  final IconData icon;
  final String description;
  final String? openLibraryKey;
  final String? coverUrl;
}

/// Data sampel lokal — dipertahankan untuk pengembangan awal
/// dan sebagai data alternatif jika diperlukan.
const List<Book> sampleBooks = [
  Book(
    title: 'Atomic Habits',
    author: 'James Clear',
    category: 'Pengembangan Diri',
    color: Color(0xFFDDEAFE),
    icon: Icons.auto_awesome,
    description: 'Buku tentang membangun kebiasaan kecil yang dapat membawa perubahan besar.',
  ),
  Book(
    title: 'The Psychology of Money',
    author: 'Morgan Housel',
    category: 'Keuangan',
    color: Color(0xFFFFE8C7),
    icon: Icons.account_balance_wallet_outlined,
    description:
        'Memahami hubungan antara perilaku manusia dan keputusan keuangan.',
  ),
  Book(
    title: 'Deep Work',
    author: 'Cal Newport',
    category: 'Produktivitas',
    color: Color(0xFFD8F3E7),
    icon: Icons.center_focus_strong,
    description: 'Mengenal cara bekerja dengan fokus untuk menghasilkan pekerjaan berkualitas.',
  ),
  Book(
    title: 'Filosofi Teras',
    author: 'Henry Manampiring',
    category: 'Filsafat',
    color: Color(0xFFE9DDFC),
    icon: Icons.self_improvement,
    description:
        'Pengantar filsafat Stoisisme untuk menghadapi kehidupan sehari-hari.',
  ),
  Book(
    title: 'Laskar Pelangi',
    author: 'Andrea Hirata',
    category: 'Novel',
    color: Color(0xFFFFDCDC),
    icon: Icons.menu_book,
    description:
        'Kisah perjuangan, persahabatan, dan semangat belajar di Belitung.',
  ),
  Book(
    title: 'Bumi',
    author: 'Tere Liye',
    category: 'Fantasi',
    color: Color(0xFFD7E9FF),
    icon: Icons.public,
    description: 'Petualangan fantasi yang memperkenalkan dunia dan kemampuan yang luar biasa.',
  ),
];
