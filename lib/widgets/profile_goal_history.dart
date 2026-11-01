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
        return Colors.orange;
      case ReadingGoalStatus.active:
        return primaryBlue;
      case ReadingGoalStatus.achieved:
        return Colors.green;
      case ReadingGoalStatus.notAchieved:
        return Colors.red;
    }
  }

  Future<void> _deleteGoal(BuildContext context, ReadingGoal goal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Target'),
          content: Text(
            'Apakah kamu yakin ingin menghapus target '
            '"${goal.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
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

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal menghapus target: $e')));
    }
  }

  Future<void> _editGoal(BuildContext context, ReadingGoal goal) async {
    final titleController = TextEditingController(text: goal.title);
    final targetController = TextEditingController(
      text: goal.targetBooks.toString(),
    );

    DateTime startDate = goal.startDate;
    DateTime endDate = goal.endDate;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> pickDate({required bool isStart}) async {
              final selectedDate = await showDatePicker(
                context: context,
                initialDate: isStart ? startDate : endDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
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
                    const Text('Nama Target'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        hintText: 'Masukkan nama target',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Jumlah Buku'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: targetController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        suffixText: 'buku',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Tanggal Mulai'),
                    TextButton.icon(
                      onPressed: () => pickDate(isStart: true),
                      icon: const Icon(Icons.calendar_month),
                      label: Text(_formatDate(startDate)),
                    ),
                    const Text('Tanggal Selesai'),
                    TextButton.icon(
                      onPressed: () => pickDate(isStart: false),
                      icon: const Icon(Icons.calendar_month),
                      label: Text(_formatDate(endDate)),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
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
          const SnackBar(content: Text('Target membaca berhasil diperbarui.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memperbarui target: $e')));
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
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  goal.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: darkText,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _editGoal(context, goal);
                  } else if (value == 'delete') {
                    _deleteGoal(context, goal);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Hapus', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${_formatDate(goal.startDate)} - '
            '${_formatDate(goal.endDate)}',
            style: const TextStyle(fontSize: 12, color: secondaryText),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
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
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.menu_book_rounded, size: 17, color: primaryBlue),
              const SizedBox(width: 6),
              Text(
                '${progress.completedBooks} dari '
                '${goal.targetBooks} buku selesai',
                style: const TextStyle(fontSize: 12, color: secondaryText),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            progress.remainingBooks > 0
                ? 'Masih perlu membaca ${progress.remainingBooks} buku lagi.'
                : 'Target membaca telah terpenuhi.',
            style: const TextStyle(fontSize: 12, color: secondaryText),
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

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.history_rounded,
                    color: primaryBlue,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Riwayat Target Membaca',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: darkText,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Muat ulang',
                  onPressed: provider.isLoading
                      ? null
                      : () => provider.loadGoals(),
                  icon: const Icon(Icons.refresh_rounded, color: primaryBlue),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Pantau perkembangan dan pencapaian target '
              'membacamu.',
              style: TextStyle(color: secondaryText, height: 1.5),
            ),
            const SizedBox(height: 18),

            if (provider.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (provider.errorMessage != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    provider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              )
            else if (progressList.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.flag_outlined, size: 38, color: secondaryText),
                    SizedBox(height: 10),
                    Text(
                      'Belum Ada Target Membaca',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: darkText,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Buat target membaca untuk mulai '
                      'memantau progresmu.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: secondaryText),
                    ),
                  ],
                ),
              )
            else
              ...progressList.map(
                (item) => _buildGoalCard(context, item.goal, item),
              ),
          ],
        );
      },
    );
  }
}
