import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/reading_goal.dart';
import '../models/saved_book.dart';
import '../services/reading_goal_service.dart';

enum ReadingGoalStatus { upcoming, active, achieved, notAchieved }

class ReadingGoalProgress {
  const ReadingGoalProgress({
    required this.goal,
    required this.completedBooks,
    required this.status,
  });

  final ReadingGoal goal;
  final int completedBooks;
  final ReadingGoalStatus status;

  double get progress {
    if (goal.targetBooks <= 0) return 0;

    return (completedBooks / goal.targetBooks).clamp(0.0, 1.0).toDouble();
  }

  bool get isFinished =>
      status == ReadingGoalStatus.achieved ||
      status == ReadingGoalStatus.notAchieved;

  int get remainingBooks =>
      (goal.targetBooks - completedBooks).clamp(0, goal.targetBooks);
}

class ReadingGoalProvider extends ChangeNotifier {
  ReadingGoalProvider({required SupabaseClient client})
    : _service = ReadingGoalService(client) {
    loadGoals();
  }

  final ReadingGoalService _service;
  final List<ReadingGoal> _goals = [];

  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  List<ReadingGoal> get goals => List.unmodifiable(_goals);
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Future<void> loadGoals() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _service.fetchGoals();

      _goals
        ..clear()
        ..addAll(result);
    } catch (error, stackTrace) {
      _errorMessage = 'Gagal memuat target bacaan.';
      debugPrint('Gagal memuat target: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<ReadingGoalProgress> getProgressForBooks(
    List<SavedBook> books, {
    DateTime? today,
  }) {
    final currentDate = _dateOnly(today ?? DateTime.now());

    final results = _goals.map((goal) {
      final start = _dateOnly(goal.startDate);
      final end = _dateOnly(goal.endDate);

      final completedCount = books.where((book) {
        if (book.status != SavedBook.statusCompleted ||
            book.completedAt == null) {
          return false;
        }

        final completedDate = _dateOnly(book.completedAt!);

        return !completedDate.isBefore(start) && !completedDate.isAfter(end);
      }).length;

      late final ReadingGoalStatus status;

      if (completedCount >= goal.targetBooks) {
        status = ReadingGoalStatus.achieved;
      } else if (currentDate.isBefore(start)) {
        status = ReadingGoalStatus.upcoming;
      } else if (currentDate.isAfter(end)) {
        status = ReadingGoalStatus.notAchieved;
      } else {
        status = ReadingGoalStatus.active;
      }

      return ReadingGoalProgress(
        goal: goal,
        completedBooks: completedCount,
        status: status,
      );
    }).toList();

    results.sort((a, b) {
      if (a.isFinished != b.isFinished) {
        return a.isFinished ? 1 : -1;
      }

      return b.goal.startDate.compareTo(a.goal.startDate);
    });

    return results;
  }

  bool _hasOverlappingGoal({
    required DateTime start,
    required DateTime end,
    String? excludedGoalId,
  }) {
    final today = _dateOnly(DateTime.now());

    return _goals.any((goal) {
      // Jangan membandingkan target dengan dirinya sendiri.
      if (goal.id == excludedGoalId) return false;

      final existingStart = _dateOnly(goal.startDate);
      final existingEnd = _dateOnly(goal.endDate);

      // Target yang periodenya sudah berakhir tidak menghalangi
      // pembuatan atau perubahan target baru.
      final existingStillOpen = !existingEnd.isBefore(today);

      return existingStillOpen &&
          !end.isBefore(existingStart) &&
          !start.isAfter(existingEnd);
    });
  }

  Future<bool> createGoal({
    required String title,
    required int targetBooks,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final cleanTitle = title.trim().isEmpty ? 'Target Bacaan' : title.trim();

    final start = _dateOnly(startDate);
    final end = _dateOnly(endDate);

    if (targetBooks <= 0) {
      _errorMessage = 'Target buku harus lebih dari 0.';
      notifyListeners();
      return false;
    }

    if (end.isBefore(start)) {
      _errorMessage = 'Tanggal selesai tidak boleh sebelum tanggal mulai.';
      notifyListeners();
      return false;
    }

    if (_hasOverlappingGoal(start: start, end: end)) {
      _errorMessage = 'Periode target bertumpang tindih dengan target lain yang masih berjalan atau akan datang.';
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final created = await _service.createGoal(
        ReadingGoal(
          id: '',
          title: cleanTitle,
          targetBooks: targetBooks,
          startDate: start,
          endDate: end,
          createdAt: DateTime.now(),
        ),
      );

      _goals.add(created);
      _errorMessage = null;
      return true;
    } catch (error, stackTrace) {
      _errorMessage = 'Gagal menyimpan target bacaan.';
      debugPrint('Gagal membuat target: $error');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> updateGoal({
    required String id,
    required String title,
    required int targetBooks,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final index = _goals.indexWhere((goal) => goal.id == id);

    if (index == -1) {
      _errorMessage = 'Target bacaan tidak ditemukan.';
      notifyListeners();
      return false;
    }

    final cleanTitle = title.trim().isEmpty ? 'Target Bacaan' : title.trim();

    final start = _dateOnly(startDate);
    final end = _dateOnly(endDate);

    if (targetBooks <= 0) {
      _errorMessage = 'Target buku harus lebih dari 0.';
      notifyListeners();
      return false;
    }

    if (end.isBefore(start)) {
      _errorMessage = 'Tanggal selesai tidak boleh sebelum tanggal mulai.';
      notifyListeners();
      return false;
    }

    if (_hasOverlappingGoal(start: start, end: end, excludedGoalId: id)) {
      _errorMessage = 'Periode target bertumpang tindih dengan target lain yang masih berjalan atau akan datang.';
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final oldGoal = _goals[index];

      final updated = await _service.updateGoal(
        ReadingGoal(
          id: id,
          title: cleanTitle,
          targetBooks: targetBooks,
          startDate: start,
          endDate: end,
          createdAt: oldGoal.createdAt,
        ),
      );

      _goals[index] = updated;
      _errorMessage = null;
      return true;
    } catch (error, stackTrace) {
      _errorMessage = 'Gagal memperbarui target bacaan.';
      debugPrint('Gagal memperbarui target: $error');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> deleteGoal(String id) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.deleteGoal(id);

      _goals.removeWhere((goal) => goal.id == id);
      _errorMessage = null;
      return true;
    } catch (error, stackTrace) {
      _errorMessage = 'Gagal menghapus target bacaan.';
      debugPrint('Gagal menghapus target: $error');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
