import 'package:flutter/material.dart';

/// Merepresentasikan buku yang disimpan pengguna.
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
    this.completedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String title;
  final String author;
  final String? coverUrl;
  final String? openLibraryKey;
  final String? category;
  final Color? color;
  final IconData? icon;
  final String status;
  final double? rating;
  final String? notes;
  final DateTime createdAt;
  final DateTime? completedAt;

  static const String statusWantToRead = 'want_to_read';
  static const String statusReading = 'reading';
  static const String statusCompleted = 'completed';

  static const List<String> allStatuses = [
    statusWantToRead,
    statusReading,
    statusCompleted,
  ];

  /// Membaca data buku dari baris Supabase.
  factory SavedBook.fromJson(Map<String, dynamic> json) {
    return SavedBook(
      id: json['id'].toString(),
      title: json['title'] as String? ?? '',
      author: json['author'] as String? ?? '',
      coverUrl: json['cover_url'] as String?,
      openLibraryKey: json['open_library_key'] as String?,
      category: json['category'] as String?,
      status: json['status'] as String? ?? statusWantToRead,
      rating: json['rating'] == null
          ? null
          : (json['rating'] as num).toDouble(),
      notes: json['notes'] as String?,
      createdAt: json['created_at'] == null
          ? DateTime.now()
          : DateTime.parse(json['created_at'] as String).toLocal(),
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String).toLocal(),
    );
  }

  /// Data untuk INSERT. ID dibuat oleh Supabase.
  Map<String, dynamic> toInsertJson(String userId) {
    return {
      'user_id': userId,
      'title': title,
      'author': author,
      'cover_url': coverUrl,
      'open_library_key': openLibraryKey,
      'category': category,
      'status': status,
      'rating': rating,
      'notes': notes,
      'completed_at': completedAt?.toUtc().toIso8601String(),
    };
  }

  /// Data yang dapat diperbarui pada baris buku.
  Map<String, dynamic> toUpdateJson() {
    return {
      'title': title,
      'author': author,
      'cover_url': coverUrl,
      'open_library_key': openLibraryKey,
      'category': category,
      'status': status,
      'rating': rating,
      'notes': notes,
      'completed_at': completedAt?.toUtc().toIso8601String(),
    };
  }

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

  SavedBook copyWithUpdated({
    required String status,
    double? rating,
    String? notes,
  }) {
    final nowCompleted = status == statusCompleted;

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
      rating: rating ?? this.rating,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      completedAt: nowCompleted
          ? (this.status == statusCompleted ? completedAt : DateTime.now())
          : null,
    );
  }
}
