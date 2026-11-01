import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/reading_goal.dart';

class ReadingGoalService {
  ReadingGoalService(this._client);

  final SupabaseClient _client;

  String get _userId {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw StateError('Sesi pengguna belum tersedia.');
    }

    return user.id;
  }

  Future<List<ReadingGoal>> fetchGoals() async {
    final rows = await _client
        .from('reading_goals')
        .select()
        .eq('user_id', _userId)
        .order('start_date', ascending: false);

    return (rows as List)
        .map(
          (row) => ReadingGoal.fromJson(Map<String, dynamic>.from(row as Map)),
        )
        .toList();
  }

  Future<ReadingGoal> createGoal(ReadingGoal goal) async {
    final row = await _client
        .from('reading_goals')
        .insert(goal.toInsertJson(_userId))
        .select()
        .single();

    return ReadingGoal.fromJson(Map<String, dynamic>.from(row));
  }

  Future<ReadingGoal> updateGoal(ReadingGoal goal) async {
    final row = await _client
        .from('reading_goals')
        .update({
          'title': goal.title,
          'target_books': goal.targetBooks,
          'start_date': _dateOnly(goal.startDate),
          'end_date': _dateOnly(goal.endDate),
        })
        .eq('id', goal.id)
        .eq('user_id', _userId)
        .select()
        .maybeSingle();

    if (row == null) {
      throw StateError('Target bacaan tidak ditemukan.');
    }

    return ReadingGoal.fromJson(Map<String, dynamic>.from(row));
  }

  Future<void> deleteGoal(String id) async {
    await _client
        .from('reading_goals')
        .delete()
        .eq('id', id)
        .eq('user_id', _userId);
  }

  String _dateOnly(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}
