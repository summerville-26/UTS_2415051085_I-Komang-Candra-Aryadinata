import 'package:flutter/material.dart';

/// Merepresentasikan data buku dari katalog.
/// Pada Milestone 8, kelas ini akan diperluas dengan parsing JSON dari Open Library API.
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

  final String title;
  final String author;
  final String category;

  /// Warna latar kartu buku — dari data lokal atau dipilih berdasarkan kategori.
  final Color color;

  /// Ikon pengganti sampul — digunakan selama integrasi API belum tersedia.
  final IconData icon;

  final String description;

  /// Key unik dari Open Library API, contoh: '/works/OL82592W'.
  /// Diisi pada Milestone 8.
  final String? openLibraryKey;

  /// URL sampul buku dari Open Library Covers API.
  /// Diisi pada Milestone 8.
  final String? coverUrl;
}

/// Data sampel lokal — akan diganti dengan respons API pada Milestone 8.
/// Dipertahankan agar layar tetap berfungsi selama pengembangan awal.
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
