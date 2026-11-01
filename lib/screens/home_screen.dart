import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../models/book.dart';
import '../models/saved_book.dart';
import '../providers/book_api_provider.dart';
import '../providers/reading_goal_provider.dart';
import '../providers/user_profile_provider.dart';
import '../widgets/book_grid.dart';
import '../widgets/app_error_view.dart';
import 'book_detail_screen.dart';
import 'profile_screen.dart';

/// Layar beranda BookNest – desain modern dengan palet ungu & putih.
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
    for (final item in progressList) {
      if (item.status == ReadingGoalStatus.active) return item;
    }
    for (final item in progressList) {
      if (item.status == ReadingGoalStatus.upcoming) return item;
    }
    return progressList.first;
  }

  // ─── Reading Stats Summary ────────────────────────────────────────────────
  Widget _buildStatsSummary() {
    final total = widget.savedBooks.length;
    final reading = widget.savedBooks
        .where((b) => b.status == SavedBook.statusReading)
        .length;
    final completed = widget.savedBooks
        .where((b) => b.status == SavedBook.statusCompleted)
        .length;
    final wantToRead = widget.savedBooks
        .where((b) => b.status == SavedBook.statusWantToRead)
        .length;

    return Row(
      children: [
        _buildStatCard(
          icon: Icons.auto_stories_rounded,
          value: '$total',
          label: 'Total',
          color: primaryPurple,
        ),
        const SizedBox(width: spacingSm),
        _buildStatCard(
          icon: Icons.menu_book_rounded,
          value: '$reading',
          label: 'Dibaca',
          color: warningColor,
        ),
        const SizedBox(width: spacingSm),
        _buildStatCard(
          icon: Icons.check_circle_rounded,
          value: '$completed',
          label: 'Selesai',
          color: successColor,
        ),
        const SizedBox(width: spacingSm),
        _buildStatCard(
          icon: Icons.bookmark_rounded,
          value: '$wantToRead',
          label: 'Wishlist',
          color: deepPurple,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(radiusMd),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Reading Goal ─────────────────────────────────────────────────────────
  Widget _buildReadingGoal() {
    ReadingGoalProvider? provider;
    try {
      provider = context.watch<ReadingGoalProvider>();
    } catch (_) {
      provider = null;
    }

    if (provider == null) {
      return _buildNoGoal();
    }

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
      ReadingGoalStatus.upcoming => 'Akan Dimulai',
      ReadingGoalStatus.active => 'Sedang Berjalan',
      ReadingGoalStatus.achieved => 'Tercapai 🎉',
      ReadingGoalStatus.notAchieved => 'Sudah Berakhir',
    };

    final statusColor = switch (currentGoal.status) {
      ReadingGoalStatus.upcoming => warningColor,
      ReadingGoalStatus.active => primaryPurple,
      ReadingGoalStatus.achieved => successColor,
      ReadingGoalStatus.notAchieved => errorColor,
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
      padding: const EdgeInsets.all(spacingMd),
      decoration: BoxDecoration(
        color: cardSurface,
        borderRadius: BorderRadius.circular(radiusLg),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: primaryPurple.withValues(alpha: 0.04),
            blurRadius: 16,
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
                  gradient: const LinearGradient(
                    colors: [primaryPurple, deepPurple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(radiusSm + 2),
                ),
                child: const Icon(
                  Icons.flag_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Target Bacaan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: darkText,
                      ),
                    ),
                    SizedBox(height: 2),
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
                  vertical: 5,
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
          const SizedBox(height: spacingMd),

          Text(
            goal.title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: darkText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$percentage% tercapai',
            style: const TextStyle(
              color: primaryPurple,
              fontWeight: FontWeight.bold,
              fontSize: 26,
            ),
          ),
          const SizedBox(height: 10),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: currentGoal.progress),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 10,
                  backgroundColor: softPurple,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    primaryPurple,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: spacingMd),

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
          const SizedBox(height: 12),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: lightLavender,
              borderRadius: BorderRadius.circular(radiusSm),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: primaryPurple,
                  size: 18,
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
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: Text(
                  '${_formatDate(goal.startDate)} – '
                  '${_formatDate(goal.endDate)}',
                  style: const TextStyle(fontSize: 11, color: secondaryText),
                ),
              ),
              TextButton(
                onPressed: _openProfile,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: spacingSm,
                    vertical: 4,
                  ),
                ),
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
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: softPurple,
        borderRadius: BorderRadius.circular(radiusSm),
      ),
      child: Row(
        children: [
          Icon(icon, color: primaryPurple, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: secondaryText, fontSize: 10),
                ),
                const SizedBox(height: 2),
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
      ),
    );
  }

  Widget _buildGoalLoading() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(spacingMd),
      decoration: BoxDecoration(
        color: cardSurface,
        borderRadius: BorderRadius.circular(radiusLg),
        border: Border.all(color: borderColor),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: primaryPurple,
            ),
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
      padding: const EdgeInsets.all(spacingMd),
      decoration: BoxDecoration(
        color: cardSurface,
        borderRadius: BorderRadius.circular(radiusLg),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Target Bacaan',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: darkText,
            ),
          ),
          const SizedBox(height: spacingSm),
          Text(
            message,
            style: const TextStyle(color: secondaryText, fontSize: 12),
          ),
          TextButton.icon(
            onPressed: () => context.read<ReadingGoalProvider>().loadGoals(),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Coba lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoGoal() {
    return InkWell(
      onTap: _openProfile,
      borderRadius: BorderRadius.circular(radiusLg),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(spacingMd),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [softPurple, lightLavender],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(radiusLg),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: primaryPurple,
                borderRadius: BorderRadius.circular(radiusMd),
              ),
              child: const Icon(
                Icons.flag_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
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
                  SizedBox(height: 4),
                  Text(
                    'Tentukan target dan mulai perjalanan membacamu.',
                    style: TextStyle(
                      color: secondaryText,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: primaryPurple,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Recommendations ──────────────────────────────────────────────────────
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
              'Rekomendasi Buku',
              style: TextStyle(
                fontSize: 18,
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(spacingLg),
            decoration: BoxDecoration(
              color: lightLavender,
              borderRadius: BorderRadius.circular(radiusLg),
            ),
            child: const Column(
              children: [
                CircularProgressIndicator(color: primaryPurple),
                SizedBox(height: 12),
                Text(
                  'Memuat rekomendasi...',
                  style: TextStyle(color: secondaryText, fontSize: 13),
                ),
              ],
            ),
          )
        else if (provider.errorMessage != null && books.isEmpty)
          AppErrorView(
            message: provider.errorMessage!,
            onRetry: () => provider.fetchBooks(query: 'fiction'),
          )
        else if (books.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(spacingLg),
            decoration: BoxDecoration(
              color: lightLavender,
              borderRadius: BorderRadius.circular(radiusLg),
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
    UserProfileProvider? userProfileProvider;
    try {
      userProfileProvider = context.watch<UserProfileProvider>();
    } catch (_) {
      userProfileProvider = null;
    }
    final userProfile = userProfileProvider?.profile;
    final hasCustomName =
        userProfile?.name != null && userProfile!.name.trim().isNotEmpty;
    final greeting = hasCustomName
        ? 'Halo, ${userProfile.name.trim()}!'
        : 'Halo, pembaca!';

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
                  // ─── Header ──────────────────────────────────────────────
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [primaryPurple, deepPurple],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(radiusMd),
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
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: darkText,
                              ),
                            ),
                            Text(
                              'Ruang membaca pribadi Kamu',
                              style: TextStyle(
                                fontSize: 12,
                                color: secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: _openProfile,
                        borderRadius: BorderRadius.circular(radiusSm),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: softPurple,
                            borderRadius: BorderRadius.circular(radiusSm),
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: primaryPurple,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: spacingLg),

                  // ─── Greeting Banner ──────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(spacingMd + 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [primaryPurple, deepPurple],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(radiusLg),
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
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'RUANG BACA KAMU',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                greeting,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Perjalanan menuju masa depan mulai dari satu buku.\nMulai perjalananmu hari ini.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 14),
                              FilledButton(
                                onPressed: widget.onOpenCatalog,
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: primaryPurple,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: spacingMd,
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      radiusMd,
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  'Jelajahi Buku',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: spacingSm),
                        Icon(
                          Icons.auto_stories_rounded,
                          color: Colors.white.withValues(alpha: 0.25),
                          size: 80,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: spacingMd),

                  // ─── Stats Summary ────────────────────────────────────────
                  _buildStatsSummary(),
                  const SizedBox(height: spacingMd),

                  // ─── Reading Goal ─────────────────────────────────────────
                  const Text(
                    'Target Bacaan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: darkText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildReadingGoal(),
                  const SizedBox(height: spacingMd),

                  // ─── Recommendations ──────────────────────────────────────
                  _buildRecommendations(),
                  const SizedBox(height: spacingMd),

                  // ─── Library Shortcut ─────────────────────────────────────
                  _buildLibraryShortcut(),
                  const SizedBox(height: spacingMd),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLibraryShortcut() {
    final count = widget.savedBooks.length;
    return InkWell(
      onTap: widget.onOpenLibrary,
      borderRadius: BorderRadius.circular(radiusLg),
      child: Container(
        padding: const EdgeInsets.all(spacingMd),
        decoration: BoxDecoration(
          color: cardSurface,
          borderRadius: BorderRadius.circular(radiusLg),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: primaryPurple.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: softPurple,
                borderRadius: BorderRadius.circular(radiusSm + 2),
              ),
              child: const Icon(
                Icons.collections_bookmark_rounded,
                color: primaryPurple,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Koleksi Bacaanmu',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: darkText,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    count == 0
                        ? 'Belum ada buku tersimpan'
                        : '$count buku tersimpan',
                    style: const TextStyle(fontSize: 12, color: secondaryText),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: primaryPurple,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
