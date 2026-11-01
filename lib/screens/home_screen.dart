import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../models/book.dart';
import '../models/saved_book.dart';
import '../providers/book_api_provider.dart';
import '../providers/reading_goal_provider.dart';
import '../widgets/book_grid.dart';
import '../widgets/app_error_view.dart';
import 'book_detail_screen.dart';
import 'profile_screen.dart';

/// Layar beranda BookNest.
class HomeScreen extends StatefulWidget {
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

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _initialFetchStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialFetchStarted) {
      _initialFetchStarted = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        final provider = context.read<BookApiProvider>();

        if (provider.books.isEmpty &&
            !provider.isLoading &&
            provider.errorMessage == null) {
          provider.fetchBooks(query: 'fiction');
        }
      });
    }
  }

  void _openDetail(Book book) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BookDetailScreen(
          book: book,
          savedBooks: widget.savedBooks,
          onAddBook: widget.onAddBook,
          onDeleteBook: widget.onDeleteBook,
          onQuickSave: widget.onQuickSave,
        ),
      ),
    );
  }

  void _openProfile() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProfileScreen(savedBooks: widget.savedBooks),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  ReadingGoalProgress? _getCurrentGoal(List<ReadingGoalProgress> progressList) {
    if (progressList.isEmpty) return null;

    // Prioritaskan target yang sedang berjalan.
    for (final item in progressList) {
      if (item.status == ReadingGoalStatus.active) {
        return item;
      }
    }

    // Jika belum ada target aktif, tampilkan target mendatang.
    for (final item in progressList) {
      if (item.status == ReadingGoalStatus.upcoming) {
        return item;
      }
    }

    // Jika semua target selesai, tampilkan target terbaru.
    return progressList.first;
  }

  Widget _buildReadingGoal() {
    final provider = context.watch<ReadingGoalProvider>();

    final progressList = provider.getProgressForBooks(widget.savedBooks);

    final currentGoal = _getCurrentGoal(progressList);

    if (provider.isLoading && currentGoal == null) {
      return _buildGoalLoading();
    }

    if (provider.errorMessage != null && currentGoal == null) {
      return _buildGoalError(provider.errorMessage!);
    }

    if (currentGoal == null) {
      return _buildNoGoal();
    }

    final goal = currentGoal.goal;
    final percentage = (currentGoal.progress * 100).round();

    final statusText = switch (currentGoal.status) {
      ReadingGoalStatus.upcoming => 'Belum Dimulai',
      ReadingGoalStatus.active => 'Sedang Berjalan',
      ReadingGoalStatus.achieved => 'Target Tercapai',
      ReadingGoalStatus.notAchieved => 'Target Berakhir',
    };

    final statusColor = switch (currentGoal.status) {
      ReadingGoalStatus.upcoming => const Color(0xFF64748B),
      ReadingGoalStatus.active => primaryBlue,
      ReadingGoalStatus.achieved => const Color(0xFF16A34A),
      ReadingGoalStatus.notAchieved => const Color(0xFFEA580C),
    };

    final message = switch (currentGoal.status) {
      ReadingGoalStatus.upcoming =>
        'Persiapkan dirimu untuk memulai target membaca!',
      ReadingGoalStatus.active =>
        currentGoal.remainingBooks == 0
            ? 'Hebat! Target membaca sudah tercapai.'
            : 'Tinggal ${currentGoal.remainingBooks} buku lagi. '
                  'Terus tingkatkan semangat membacamu!',
      ReadingGoalStatus.achieved =>
        'Hebat! Kamu berhasil mencapai target membaca. 🎉',
      ReadingGoalStatus.notAchieved =>
        'Periode target telah berakhir. '
            'Yuk, buat target baru dan coba lagi!',
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(Icons.flag_rounded, color: primaryBlue),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Target Bacaan',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: darkText,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Pantau perkembangan membacamu',
                      style: TextStyle(fontSize: 11, color: secondaryText),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          Text(
            goal.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: darkText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$percentage% tercapai',
            style: const TextStyle(
              color: primaryBlue,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 12),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: currentGoal.progress),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 11,
                  backgroundColor: const Color(0xFFEFF3F8),
                  valueColor: const AlwaysStoppedAnimation<Color>(primaryBlue),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildGoalStatistic(
                  icon: Icons.check_circle_outline_rounded,
                  label: 'Selesai',
                  value: '${currentGoal.completedBooks} buku',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGoalStatistic(
                  icon: Icons.menu_book_rounded,
                  label: 'Target',
                  value: '${goal.targetBooks} buku',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F6FF),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: primaryBlue,
                  size: 19,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: darkText,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: Text(
                  '${_formatDate(goal.startDate)} - '
                  '${_formatDate(goal.endDate)}',
                  style: const TextStyle(fontSize: 11, color: secondaryText),
                ),
              ),
              TextButton(
                onPressed: _openProfile,
                child: const Text('Kelola Target'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalStatistic({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: primaryBlue, size: 19),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: secondaryText, fontSize: 11),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  color: darkText,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGoalLoading() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 14),
          Text(
            'Memuat target bacaan...',
            style: TextStyle(color: secondaryText),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalError(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Target Bacaan',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: darkText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(color: secondaryText, fontSize: 12),
          ),
          TextButton.icon(
            onPressed: () {
              context.read<ReadingGoalProvider>().loadGoals();
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Coba lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoGoal() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.flag_outlined,
              color: primaryBlue,
              size: 27,
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Buat Target Bacaan',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: darkText,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Tentukan target dan mulai perjalanan membacamu.',
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _openProfile,
            icon: const Icon(Icons.arrow_forward_rounded, color: primaryBlue),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations() {
    final provider = context.watch<BookApiProvider>();
    final books = provider.books;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              onPressed: widget.onOpenCatalog,
              child: const Text('Lihat semua'),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (provider.isLoading && books.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          )
        else if (provider.errorMessage != null && books.isEmpty)
          AppErrorView(
            message: provider.errorMessage!,
            onRetry: () {
              provider.fetchBooks(query: 'fiction');
            },
          )
        else if (books.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              'Belum ada rekomendasi buku.',
              textAlign: TextAlign.center,
              style: TextStyle(color: secondaryText),
            ),
          )
        else
          BookGrid(
            books: books.take(4).toList(),
            savedBooks: widget.savedBooks,
            onQuickSave: widget.onQuickSave,
            onCardTap: _openDetail,
          ),
      ],
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
                      IconButton(
                        tooltip: 'Profil',
                        onPressed: _openProfile,
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
                                onPressed: widget.onOpenCatalog,
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

                  // Target Bacaan
                  _buildReadingGoal(),
                  const SizedBox(height: 28),

                  // Rekomendasi dari API
                  _buildRecommendations(),
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
                                '${widget.savedBooks.length} buku tersimpan',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: widget.onOpenLibrary,
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
