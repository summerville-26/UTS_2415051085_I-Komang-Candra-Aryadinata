import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../models/saved_book.dart';

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
  late final TextEditingController _goalController;

  late int _readingGoal;
  late String _goalPeriod;

  String _name = '';
  String _about = '';

  // Catatan: model SavedBook saat ini belum tentu menyimpan
  // tanggal buku selesai. Untuk sementara, progres memakai
  // jumlah buku dengan status completed.
  int get _completedBooks => widget.savedBooks
      .where((book) => book.status == SavedBook.statusCompleted)
      .length;

  double get _progress {
    if (_readingGoal <= 0) return 0;
    return (_completedBooks / _readingGoal).clamp(0.0, 1.0);
  }

  int get _remaining => (_readingGoal - _completedBooks).clamp(0, _readingGoal);

  String get _periodLabel =>
      _goalPeriod == 'weekly' ? 'minggu ini' : 'bulan ini';

  @override
  void initState() {
    super.initState();

    _name = widget.initialName;
    _about = widget.initialAbout;
    _nameController = TextEditingController(text: _name);
    _aboutController = TextEditingController(text: _about);

    _readingGoal = widget.initialReadingGoal > 0
        ? widget.initialReadingGoal
        : 5;
    _goalController = TextEditingController(text: _readingGoal.toString());

    _goalPeriod = widget.initialGoalPeriod == 'monthly' ? 'monthly' : 'weekly';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aboutController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _editName() async {
    _nameController.text = _name;

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
            hintText: 'Masukkan nama',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) => Navigator.pop(dialogContext, value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, _nameController.text.trim()),
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

    setState(() => _name = result);
    widget.onSaveName?.call(result);
    _showMessage('Nama pengguna berhasil diperbarui.');
  }

  Future<void> _editAbout() async {
    _aboutController.text = _about;

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
            onPressed: () =>
                Navigator.pop(dialogContext, _aboutController.text.trim()),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (!mounted || result == null) return;

    setState(() => _about = result);
    widget.onSaveAbout?.call(result);
    _showMessage('Tentang Saya berhasil diperbarui.');
  }

  void _saveGoal() {
    final goal = int.tryParse(_goalController.text.trim());

    if (goal == null || goal < 1) {
      _showMessage('Target harus berupa angka minimal 1.');
      return;
    }

    setState(() => _readingGoal = goal);
    widget.onSaveReadingGoal?.call(goal);
    FocusScope.of(context).unfocus();
    _showMessage('Target membaca berhasil diperbarui.');
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

  @override
  Widget build(BuildContext context) {
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
                // PROFIL PENGGUNA
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
                              _name.isEmpty ? 'Nama Pengguna' : _name,
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
                          _about.isEmpty
                              ? 'Tambahkan sedikit informasi tentang diri, '
                                    'minat, atau buku favoritmu.'
                              : _about,
                          style: TextStyle(
                            height: 1.5,
                            color: _about.isEmpty ? secondaryText : darkText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // TARGET MEMBACA
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
                        'Tentukan target buku yang ingin kamu selesaikan.',
                        style: TextStyle(color: secondaryText, height: 1.4),
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'Periode target',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: darkText,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment<String>(
                            value: 'weekly',
                            label: Text('Mingguan'),
                            icon: Icon(Icons.date_range_rounded),
                          ),
                          ButtonSegment<String>(
                            value: 'monthly',
                            label: Text('Bulanan'),
                            icon: Icon(Icons.calendar_month_rounded),
                          ),
                        ],
                        selected: {_goalPeriod},
                        onSelectionChanged: (selection) {
                          setState(() => _goalPeriod = selection.first);
                        },
                        showSelectedIcon: false,
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _goalController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Target jumlah buku',
                          hintText: 'Contoh: 5',
                          suffixText: 'buku',
                          prefixIcon: const Icon(Icons.menu_book_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onSubmitted: (_) => _saveGoal(),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _saveGoal,
                          icon: const Icon(Icons.save_outlined),
                          label: const Text('Simpan Target'),
                          style: FilledButton.styleFrom(
                            backgroundColor: primaryBlue,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 26),
                      const Divider(),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Progres Pencapaian',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: darkText,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDBEAFE),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _goalPeriod == 'weekly' ? 'Mingguan' : 'Bulanan',
                              style: const TextStyle(
                                color: primaryBlue,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$_completedBooks dari $_readingGoal buku',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: darkText,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _remaining == 0
                                      ? 'Target membaca tercapai!'
                                      : '$_remaining buku lagi untuk mencapai target $_periodLabel.',
                                  style: const TextStyle(
                                    color: secondaryText,
                                    fontSize: 12,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${(_progress * 100).round()}%',
                            style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: _progress,
                          minHeight: 12,
                          backgroundColor: const Color(0xFFE5EAF2),
                          color: primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Total buku berstatus selesai: $_completedBooks',
                        style: const TextStyle(
                          color: secondaryText,
                          fontSize: 12,
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
