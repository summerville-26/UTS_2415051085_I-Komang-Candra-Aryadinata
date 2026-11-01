import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/reading_goal.dart';
import '../../models/saved_book.dart';
import '../../providers/reading_goal_provider.dart';

class ProfileGoalHistory extends StatelessWidget {
  const ProfileGoalHistory({super.key, required this.savedBooks});

  final List<SavedBook> savedBooks;

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _statusLabel(ReadingGoalStatus status) {
    switch (status) {
      case ReadingGoalStatus.upcoming:
        return 'Akan Datang';
      case ReadingGoalStatus.active:
        return 'Sedang Berlangsung';
      case ReadingGoalStatus.achieved:
        return 'Tercapai';
      case ReadingGoalStatus.notAchieved:
        return 'Tidak Tercapai';
    }
  }

  Color _statusColor(ReadingGoalStatus status) {
    switch (status) {
      case ReadingGoalStatus.upcoming:
        return warningColor;
      case ReadingGoalStatus.active:
        return primaryPurple;
      case ReadingGoalStatus.achieved:
        return successColor;
      case ReadingGoalStatus.notAchieved:
        return errorColor;
    }
  }

  IconData _statusIcon(ReadingGoalStatus status) {
    switch (status) {
      case ReadingGoalStatus.upcoming:
        return Icons.schedule_rounded;
      case ReadingGoalStatus.active:
        return Icons.play_circle_rounded;
      case ReadingGoalStatus.achieved:
        return Icons.emoji_events_rounded;
      case ReadingGoalStatus.notAchieved:
        return Icons.cancel_rounded;
    }
  }

  Future<void> _deleteGoal(BuildContext context, ReadingGoal goal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Target'),
        content: Text(
          'Apakah kamu yakin ingin menghapus target "${goal.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: errorColor),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await context.read<ReadingGoalProvider>().deleteGoal(goal.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Target membaca berhasil dihapus.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus target: $e')),
      );
    }
  }

  Future<void> _editGoal(BuildContext context, ReadingGoal goal) async {
    final titleController = TextEditingController(text: goal.title);
    final targetController = TextEditingController(
      text: goal.targetBooks.toString(),
    );

    DateTime startDate = goal.startDate;
    DateTime endDate = goal.endDate;

    String formatDate(DateTime date) {
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          Future<void> pickDate({required bool isStart}) async {
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: isStart ? startDate : endDate,
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
              builder: (context, child) => Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: primaryPurple,
                  ),
                ),
                child: child!,
              ),
            );
            if (selectedDate == null) return;
            setDialogState(() {
              if (isStart) {
                startDate = selectedDate;
                if (endDate.isBefore(startDate)) {
                  endDate = startDate.add(const Duration(days: 6));
                }
              } else {
                endDate = selectedDate;
              }
            });
          }

          return AlertDialog(
            title: const Text('Edit Target Membaca'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nama Target',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      hintText: 'Masukkan nama target',
                    ),
                  ),
                  const SizedBox(height: spacingMd),
                  const Text(
                    'Jumlah Buku',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: targetController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(suffixText: 'buku'),
                  ),
                  const SizedBox(height: spacingMd),
                  const Text(
                    'Periode',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => pickDate(isStart: true),
                          borderRadius: BorderRadius.circular(radiusSm),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: lightLavender,
                              borderRadius: BorderRadius.circular(radiusSm),
                              border: Border.all(color: borderColor),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_month_rounded,
                                  size: 15,
                                  color: primaryPurple,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  formatDate(startDate),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Text('–', style: TextStyle(color: secondaryText)),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () => pickDate(isStart: false),
                          borderRadius: BorderRadius.circular(radiusSm),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: lightLavender,
                              borderRadius: BorderRadius.circular(radiusSm),
                              border: Border.all(color: borderColor),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_month_rounded,
                                  size: 15,
                                  color: primaryPurple,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  formatDate(endDate),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Simpan'),
              ),
            ],
          );
        },
      ),
    );

    if (result != true || !context.mounted) {
      titleController.dispose();
      targetController.dispose();
      return;
    }

    final title = titleController.text.trim();
    final target = int.tryParse(targetController.text.trim());

    if (title.isEmpty || target == null || target < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama dan jumlah buku harus diisi dengan benar.'),
        ),
      );
      titleController.dispose();
      targetController.dispose();
      return;
    }

    if (endDate.isBefore(startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tanggal selesai tidak boleh sebelum tanggal mulai.'),
        ),
      );
      titleController.dispose();
      targetController.dispose();
      return;
    }

    try {
      await context.read<ReadingGoalProvider>().updateGoal(
        id: goal.id,
        title: title,
        targetBooks: target,
        startDate: startDate,
        endDate: endDate,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Target membaca berhasil diperbarui.'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui target: $e')),
        );
      }
    } finally {
      titleController.dispose();
      targetController.dispose();
    }
  }

  Widget _buildGoalCard(
    BuildContext context,
    ReadingGoal goal,
    ReadingGoalProgress progress,
  ) {
    final statusColor = _statusColor(progress.status);
    final percentage = progress.progress.clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: spacingMd),
      padding: const EdgeInsets.all(spacingMd),
      decoration: BoxDecoration(
        color: cardSurface,
        borderRadius: BorderRadius.circular(radiusMd),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: primaryPurple.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(radiusSm),
                ),
                child: Icon(_statusIcon(progress.status), color: statusColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_formatDate(goal.startDate)} – ${_formatDate(goal.endDate)}',
                      style: const TextStyle(fontSize: 11, color: secondaryText),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') _editGoal(context, goal);
                  if (value == 'delete') _deleteGoal(context, goal);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(radiusMd),
                ),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_rounded, size: 17, color: primaryPurple),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_rounded, size: 17, color: errorColor),
                        const SizedBox(width: 8),
                        Text(
                          'Hapus',
                          style: TextStyle(color: errorColor),
                        ),
                      ],
                    ),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: lightLavender,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.more_horiz_rounded,
                    size: 18,
                    color: secondaryText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Status badge + percentage
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _statusLabel(progress.status),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${(percentage * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: darkText,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Progress bar
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: percentage),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 8,
                backgroundColor: softPurple,
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Book count detail
          Row(
            children: [
              const Icon(Icons.menu_book_rounded, size: 15, color: primaryPurple),
              const SizedBox(width: 6),
              Text(
                '${progress.completedBooks} dari ${goal.targetBooks} buku selesai',
                style: const TextStyle(fontSize: 12, color: secondaryText),
              ),
              const Spacer(),
              if (progress.remainingBooks > 0)
                Text(
                  '${progress.remainingBooks} tersisa',
                  style: const TextStyle(
                    fontSize: 11,
                    color: primaryPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReadingGoalProvider>(
      builder: (context, provider, child) {
        final progressList = provider.getProgressForBooks(savedBooks);

        if (provider.isLoading) {
          return Container(
            padding: const EdgeInsets.all(spacingLg),
            decoration: BoxDecoration(
              color: lightLavender,
              borderRadius: BorderRadius.circular(radiusMd),
            ),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: primaryPurple),
                  SizedBox(height: 12),
                  Text(
                    'Memuat riwayat target...',
                    style: TextStyle(color: secondaryText, fontSize: 13),
                  ),
                ],
              ),
            ),
          );
        }

        if (provider.errorMessage != null) {
          return Container(
            padding: const EdgeInsets.all(spacingMd),
            decoration: BoxDecoration(
              color: errorColor.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(radiusMd),
              border: Border.all(color: errorColor.withValues(alpha: 0.2)),
            ),
            child: Text(
              provider.errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: errorColor, fontSize: 13),
            ),
          );
        }

        if (progressList.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(spacingLg),
            decoration: BoxDecoration(
              color: lightLavender,
              borderRadius: BorderRadius.circular(radiusMd),
              border: Border.all(color: borderColor),
            ),
            child: const Column(
              children: [
                Icon(Icons.flag_outlined, size: 36, color: secondaryText),
                SizedBox(height: spacingSm),
                Text(
                  'Belum Ada Target Membaca',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: darkText,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Buat target membaca untuk mulai memantau progresmu.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: secondaryText, height: 1.5),
                ),
              ],
            ),
          );
        }

        return Column(
          children: progressList
              .map((item) => _buildGoalCard(context, item.goal, item))
              .toList(),
        );
      },
    );
  }
}
