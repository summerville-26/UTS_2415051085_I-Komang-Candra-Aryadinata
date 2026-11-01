import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../models/saved_book.dart';
import '../models/reading_goal.dart';
import '../providers/reading_goal_provider.dart';
import '../providers/user_profile_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.savedBooks,
    this.initialName = '',
    this.onSaveName,
    this.initialAbout = '',
    this.onSaveAbout,
    this.initialReadingGoal = 5,
    this.initialGoalPeriod = 'weekly',
    this.onSaveReadingGoal,
  });

  final List<SavedBook> savedBooks;
  final String initialName;
  final ValueChanged<String>? onSaveName;
  final String initialAbout;
  final ValueChanged<String>? onSaveAbout;
  final int initialReadingGoal;
  final String initialGoalPeriod;
  final ValueChanged<int>? onSaveReadingGoal;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _aboutController;
  late final TextEditingController _titleController;
  late final TextEditingController _targetController;

  late String _name;
  late String _about;

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 6));

  bool _isCreatingGoal = false;

  @override
  void initState() {
    super.initState();

    _name = widget.initialName;
    _about = widget.initialAbout;

    _nameController = TextEditingController(text: _name);
    _aboutController = TextEditingController(text: _about);
    _titleController = TextEditingController(text: 'Target Bacaan');
    _targetController = TextEditingController(
      text: widget.initialReadingGoal > 0
          ? widget.initialReadingGoal.toString()
          : '5',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aboutController.dispose();
    _titleController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked == null || !mounted) return;

    setState(() {
      if (isStart) {
        _startDate = DateTime(picked.year, picked.month, picked.day);
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate.add(const Duration(days: 6));
        }
      } else {
        _endDate = DateTime(picked.year, picked.month, picked.day);
      }
    });
  }

  Future<void> _editName() async {
    final profileProvider = context.read<UserProfileProvider>();

    _nameController.text = profileProvider.profile?.name ?? _name;

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Nama Pengguna'),
        content: TextField(
          controller: _nameController,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Nama pengguna',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            Navigator.pop(dialogContext, value.trim());
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext, _nameController.text.trim());
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (!mounted || result == null) return;

    if (result.isEmpty) {
      _showMessage('Nama pengguna tidak boleh kosong.');
      return;
    }

    final success = await profileProvider.saveProfile(
      name: result,
      about: profileProvider.profile?.about ?? _about,
    );

    if (!mounted) return;

    if (success) {
      setState(() => _name = result);
      widget.onSaveName?.call(result);
      _showMessage('Nama pengguna berhasil disimpan.');
    } else {
      _showMessage(
        profileProvider.errorMessage ?? 'Gagal menyimpan nama pengguna.',
      );
    }
  }

  Future<void> _editAbout() async {
    final profileProvider = context.read<UserProfileProvider>();

    _aboutController.text = profileProvider.profile?.about ?? _about;

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tentang Saya'),
        content: TextField(
          controller: _aboutController,
          autofocus: true,
          minLines: 3,
          maxLines: 5,
          maxLength: 250,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText: 'Ceritakan tentang diri dan minat membacamu...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext, _aboutController.text.trim());
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (!mounted || result == null) return;

    final success = await profileProvider.saveProfile(
      name: profileProvider.profile?.name ?? _name,
      about: result,
    );

    if (!mounted) return;

    if (success) {
      setState(() => _about = result);
      widget.onSaveAbout?.call(result);
      _showMessage('Tentang Saya berhasil disimpan.');
    } else {
      _showMessage(
        profileProvider.errorMessage ?? 'Gagal menyimpan deskripsi profil.',
      );
    }
  }

  Future<void> _createGoal() async {
    final target = int.tryParse(_targetController.text.trim());

    if (target == null || target < 1) {
      _showMessage('Target buku harus berupa angka minimal 1.');
      return;
    }

    if (_endDate.isBefore(_startDate)) {
      _showMessage('Tanggal selesai tidak boleh sebelum tanggal mulai.');
      return;
    }

    setState(() => _isCreatingGoal = true);

    try {
      final provider = context.read<ReadingGoalProvider>();

      final success = await provider.createGoal(
        title: _titleController.text.trim().isEmpty
            ? 'Target Bacaan'
            : _titleController.text.trim(),
        targetBooks: target,
        startDate: _startDate,
        endDate: _endDate,
      );

      if (!mounted) return;

      if (success) {
        _titleController.text = 'Target Bacaan';
        _showMessage('Target bacaan berhasil disimpan.');
      } else {
        _showMessage(provider.errorMessage ?? 'Target bacaan gagal disimpan.');
      }
    } catch (error) {
      if (mounted) {
        _showMessage('Terjadi kesalahan saat menyimpan target.');
      }
    } finally {
      if (mounted) {
        setState(() => _isCreatingGoal = false);
      }
    }
  }

  Future<void> _editGoal(ReadingGoal goal) async {
    final titleController = TextEditingController(text: goal.title);
    final targetController = TextEditingController(
      text: goal.targetBooks.toString(),
    );

    DateTime startDate = goal.startDate;
    DateTime endDate = goal.endDate;

    Future<DateTime?> chooseDate(
      BuildContext dialogContext,
      DateTime initialDate,
    ) {
      return showDatePicker(
        context: dialogContext,
        initialDate: initialDate,
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
      );
    }

    try {
      final result = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Edit Target Bacaan'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: 'Nama target',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: targetController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Jumlah buku',
                          suffixText: 'buku',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.calendar_today),
                        title: const Text('Tanggal mulai'),
                        subtitle: Text(_formatDate(startDate)),
                        onTap: () async {
                          final picked = await chooseDate(
                            dialogContext,
                            startDate,
                          );

                          if (picked == null) return;

                          setDialogState(() {
                            startDate = DateTime(
                              picked.year,
                              picked.month,
                              picked.day,
                            );

                            if (endDate.isBefore(startDate)) {
                              endDate = startDate;
                            }
                          });
                        },
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.event_available),
                        title: const Text('Tanggal selesai'),
                        subtitle: Text(_formatDate(endDate)),
                        onTap: () async {
                          final picked = await chooseDate(
                            dialogContext,
                            endDate,
                          );

                          if (picked == null) return;

                          setDialogState(() {
                            endDate = DateTime(
                              picked.year,
                              picked.month,
                              picked.day,
                            );
                          });
                        },
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
                    child: const Text('Simpan Perubahan'),
                  ),
                ],
              );
            },
          );
        },
      );

      if (!mounted || result != true) return;

      final target = int.tryParse(targetController.text.trim());

      if (target == null || target < 1) {
        _showMessage('Target buku harus berupa angka minimal 1.');
        return;
      }

      final provider = context.read<ReadingGoalProvider>();

      final success = await provider.updateGoal(
        id: goal.id,
        title: titleController.text,
        targetBooks: target,
        startDate: startDate,
        endDate: endDate,
      );

      if (!mounted) return;

      _showMessage(
        success
            ? 'Target bacaan berhasil diperbarui.'
            : provider.errorMessage ?? 'Gagal memperbarui target.',
      );
    } finally {
      titleController.dispose();
      targetController.dispose();
    }
  }

  Future<void> _deleteGoal(ReadingGoal goal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Target Bacaan?'),
        content: Text(
          'Target "${goal.title}" akan dihapus secara permanen. '
          'Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;

    final provider = context.read<ReadingGoalProvider>();
    final success = await provider.deleteGoal(goal.id);

    if (!mounted) return;

    _showMessage(
      success
          ? 'Target bacaan berhasil dihapus.'
          : provider.errorMessage ?? 'Gagal menghapus target.',
    );
  }

  Widget _sectionCard({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(22),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionTitle({required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFDBEAFE),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: primaryBlue, size: 23),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: darkText,
            ),
          ),
        ),
      ],
    );
  }

  Widget _datePickerTile({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(
          _formatDate(date),
          style: const TextStyle(fontWeight: FontWeight.w600, color: darkText),
        ),
      ),
    );
  }

  String _statusLabel(ReadingGoalStatus status) {
    switch (status) {
      case ReadingGoalStatus.upcoming:
        return 'Akan Datang';
      case ReadingGoalStatus.active:
        return 'Sedang Berjalan';
      case ReadingGoalStatus.achieved:
        return 'Tercapai';
      case ReadingGoalStatus.notAchieved:
        return 'Tidak Tercapai';
    }
  }

  Color _statusColor(ReadingGoalStatus status) {
    switch (status) {
      case ReadingGoalStatus.upcoming:
        return const Color(0xFF7C3AED);
      case ReadingGoalStatus.active:
        return primaryBlue;
      case ReadingGoalStatus.achieved:
        return const Color(0xFF15803D);
      case ReadingGoalStatus.notAchieved:
        return const Color(0xFFDC2626);
    }
  }

  Widget _goalHistory() {
    return Consumer<ReadingGoalProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.goals.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (provider.goals.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FB),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Icon(Icons.auto_graph_rounded, size: 36, color: secondaryText),
                SizedBox(height: 10),
                Text(
                  'Belum ada target bacaan',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: darkText,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Buat target pertama untuk mulai memantau progresmu.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: secondaryText,
                    height: 1.4,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        }

        final progressItems = provider.getProgressForBooks(widget.savedBooks);

        return Column(
          children: progressItems.map((item) {
            final goal = item.goal;
            final color = _statusColor(item.status);

            return Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(16),
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
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _statusLabel(item.status),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ),
                      PopupMenuButton<String>(
                        tooltip: 'Tindakan target',
                        icon: const Icon(
                          Icons.more_vert_rounded,
                          color: secondaryText,
                        ),
                        onSelected: (value) {
                          if (value == 'edit') {
                            _editGoal(goal);
                          } else if (value == 'delete') {
                            _deleteGoal(goal);
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined, size: 19),
                                SizedBox(width: 10),
                                Text('Edit target'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete_outline_rounded,
                                  size: 19,
                                  color: Colors.red,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Hapus target',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_formatDate(goal.startDate)} – '
                    '${_formatDate(goal.endDate)}',
                    style: const TextStyle(fontSize: 12, color: secondaryText),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${item.completedBooks} dari '
                        '${goal.targetBooks} buku',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: darkText,
                        ),
                      ),
                      Text(
                        '${(item.progress * 100).round()}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: item.progress,
                      minHeight: 9,
                      backgroundColor: const Color(0xFFE5EAF2),
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    item.status == ReadingGoalStatus.achieved
                        ? 'Target buku berhasil dicapai.'
                        : item.status == ReadingGoalStatus.notAchieved
                        ? 'Periode berakhir sebelum target tercapai.'
                        : item.status == ReadingGoalStatus.upcoming
                        ? 'Target belum memasuki periode.'
                        : 'Sisa ${item.remainingBooks} buku untuk '
                              'mencapai target.',
                    style: const TextStyle(
                      color: secondaryText,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<UserProfileProvider>();
    final profile = profileProvider.profile;
    final currentName = profile?.name ?? _name;
    final currentAbout = profile?.about ?? _about;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _sectionCard(
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 43,
                        backgroundColor: Color(0xFFDBEAFE),
                        child: Icon(
                          Icons.person_rounded,
                          color: primaryBlue,
                          size: 49,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              currentName.isEmpty
                                  ? 'Nama Pengguna'
                                  : currentName,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: darkText,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            tooltip: 'Edit nama',
                            onPressed: _editName,
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFFDBEAFE),
                              foregroundColor: primaryBlue,
                            ),
                            icon: const Icon(Icons.edit_outlined, size: 19),
                          ),
                        ],
                      ),
                      const Text(
                        'Pembaca BookNest',
                        style: TextStyle(color: secondaryText),
                      ),
                      const SizedBox(height: 24),
                      const Divider(height: 1),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Tentang Saya',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: darkText,
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _editAbout,
                            icon: const Icon(Icons.edit_outlined, size: 17),
                            label: const Text('Edit'),
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          currentAbout.isEmpty
                              ? 'Tambahkan sedikit informasi tentang diri, '
                                    'minat, atau buku favoritmu.'
                              : currentAbout,
                          style: TextStyle(
                            height: 1.5,
                            color: currentAbout.isEmpty
                                ? secondaryText
                                : darkText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // FORM PEMBUATAN TARGET
                _sectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle(
                        icon: Icons.track_changes_rounded,
                        title: 'Target Membaca',
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Buat target dengan periode tanggal yang spesifik '
                        'dan pantau progres bacaanmu.',
                        style: TextStyle(color: secondaryText, height: 1.4),
                      ),
                      const SizedBox(height: 22),
                      TextField(
                        controller: _titleController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          labelText: 'Nama target',
                          hintText: 'Contoh: Tantangan Membaca November',
                          prefixIcon: const Icon(Icons.flag_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _targetController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Target jumlah buku',
                          hintText: 'Contoh: 7',
                          suffixText: 'buku',
                          prefixIcon: const Icon(Icons.menu_book_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _datePickerTile(
                        label: 'Tanggal mulai',
                        date: _startDate,
                        icon: Icons.calendar_today_rounded,
                        onTap: () => _pickDate(isStart: true),
                      ),
                      const SizedBox(height: 14),
                      _datePickerTile(
                        label: 'Tanggal selesai',
                        date: _endDate,
                        icon: Icons.event_available_rounded,
                        onTap: () => _pickDate(isStart: false),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _isCreatingGoal ? null : _createGoal,
                          icon: _isCreatingGoal
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.add_task_rounded),
                          label: Text(
                            _isCreatingGoal ? 'Menyimpan...' : 'Buat Target',
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: primaryBlue,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // RIWAYAT DAN PROGRES TARGET
                _sectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle(
                        icon: Icons.insights_rounded,
                        title: 'Progres & Riwayat',
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Progres dihitung dari buku yang ditandai selesai '
                        'dalam rentang tanggal masing-masing target.',
                        style: TextStyle(
                          color: secondaryText,
                          height: 1.4,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _goalHistory(),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () =>
                              context.read<ReadingGoalProvider>().loadGoals(),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Muat ulang'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
