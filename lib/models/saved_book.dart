class SavedBook {
  final String id;
  final String bookId;
  final DateTime savedAt;

  const SavedBook({
    required this.id,
    required this.bookId,
    required this.savedAt,
  });

  factory SavedBook.fromJson(Map<String, dynamic> json) {
    return SavedBook(
      id: json['id']?.toString() ?? '',
      bookId: json['bookId']?.toString() ?? '',
      savedAt:
          DateTime.tryParse(json['savedAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'bookId': bookId, 'savedAt': savedAt.toIso8601String()};
  }
}
