class ReadingGoal {
  const ReadingGoal({
    required this.id,
    required this.title,
    required this.targetBooks,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
  });

  final String id;
  final String title;
  final int targetBooks;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;

  factory ReadingGoal.fromJson(Map<String, dynamic> json) {
    return ReadingGoal(
      id: json['id'].toString(),
      title: json['title'] as String? ?? 'Target Bacaan',
      targetBooks: (json['target_books'] as num).toInt(),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }

  Map<String, dynamic> toInsertJson(String userId) {
    return {
      'user_id': userId,
      'title': title,
      'target_books': targetBooks,
      'start_date': _dateOnly(startDate),
      'end_date': _dateOnly(endDate),
    };
  }

  static String _dateOnly(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}
