import 'package:flutter/material.dart';

/// Merepresentasikan buku yang disimpan pengguna ke daftar bacaan pribadi.
///
/// ID menggunakan timestamp sementara — akan diganti UUID dari Supabase pada Milestone 9.
/// Field [color] dan [icon] dari data lokal; akan digantikan [coverUrl] setelah API aktif.
class SavedBook {
  SavedBook({
    required this.id,
    required this.title,
    required this.author,
    this.coverUrl,
    this.openLibraryKey,
    this.category,
    this.color,
    this.icon,
    required this.status,
    this.rating,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// ID unik. Saat ini berupa timestamp string; akan berupa UUID Supabase pada Milestone 9.
  final String id;

  final String title;
  final String author;

  /// URL sampul dari Open Library — diisi pada Milestone 8.
  final String? coverUrl;

  /// Key buku dari Open Library API — diisi pada Milestone 8.
  final String? openLibraryKey;

  final String? category;

  /// Warna kartu dari data lokal. Dipertahankan untuk tampilan library.
  final Color? color;

  /// Ikon dari data lokal. Dipertahankan untuk tampilan library.
  final IconData? icon;

  /// Status membaca. Salah satu dari [statusWantToRead], [statusReading], [statusCompleted].
  final String status;

  /// Rating 1.0–5.0, atau null jika belum dirating.
  final double? rating;

  /// Catatan pribadi pengguna.
  final String? notes;

  /// Waktu pertama kali buku disimpan.
  final DateTime createdAt;

  // ─── Konstanta Status ─────────────────────────────────────────────────────
  static const String statusWantToRead = 'want_to_read';
  static const String statusReading = 'reading';
  static const String statusCompleted = 'completed';

  static const List<String> allStatuses = [
    statusWantToRead,
    statusReading,
    statusCompleted,
  ];

  /// Label ramah pengguna untuk setiap status.
  static String statusLabel(String status) {
    switch (status) {
      case statusReading:
        return 'Sedang Dibaca';
      case statusCompleted:
        return 'Selesai Dibaca';
      default:
        return 'Ingin Dibaca';
    }
  }

  /// Warna badge untuk setiap status.
  static Color statusColor(String status) {
    switch (status) {
      case statusReading:
        return const Color(0xFF2563EB);
      case statusCompleted:
        return const Color(0xFF16A34A);
      default:
        return const Color(0xFF9333EA);
    }
  }

  /// Ikon badge untuk setiap status.
  static IconData statusIcon(String status) {
    switch (status) {
      case statusReading:
        return Icons.menu_book_rounded;
      case statusCompleted:
        return Icons.check_circle_outline_rounded;
      default:
        return Icons.bookmark_border_rounded;
    }
  }

  /// Mengembalikan salinan objek dengan status, rating, dan catatan yang diperbarui.
  SavedBook copyWithUpdated({
    required String status,
    double? rating,
    String? notes,
  }) {
    return SavedBook(
      id: id,
      title: title,
      author: author,
      coverUrl: coverUrl,
      openLibraryKey: openLibraryKey,
      category: category,
      color: color,
      icon: icon,
      status: status,
      rating: rating,
      notes: notes,
      createdAt: createdAt,
    );
  }
}
