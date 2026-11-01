import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../providers/reading_goal_provider.dart';

class ProfileGoalForm extends StatefulWidget {
  const ProfileGoalForm({super.key, this.initialReadingGoal = 5});

  final int initialReadingGoal;

  @override
  State<ProfileGoalForm> createState() => _ProfileGoalFormState();
}

class _ProfileGoalFormState extends State<ProfileGoalForm> {
  late final TextEditingController _titleController;
  late final TextEditingController _targetController;

  late DateTime _startDate;
  late DateTime _endDate;

  bool _isCreatingGoal = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _targetController = TextEditingController(
      text: widget.initialReadingGoal.toString(),
    );
    _startDate = DateTime.now();
    _endDate = DateTime.now().add(const Duration(days: 6));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _pickDate({required bool isStart}) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: primaryPurple,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate == null) return;

    setState(() {
      if (isStart) {
        _startDate = selectedDate;
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate.add(const Duration(days: 6));
        }
      } else {
        _endDate = selectedDate;
      }
    });
  }

  Future<void> _createGoal() async {
    final title = _titleController.text.trim();
    final target = int.tryParse(_targetController.text.trim());

    if (title.isEmpty) {
      _showMessage('Silakan masukkan judul target membaca.');
      return;
    }
    if (target == null || target < 1) {
      _showMessage('Jumlah buku harus berupa angka minimal 1.');
      return;
    }
    if (_endDate.isBefore(_startDate)) {
      _showMessage('Tanggal selesai tidak boleh sebelum tanggal mulai.');
      return;
    }

    setState(() => _isCreatingGoal = true);

    try {
      await context.read<ReadingGoalProvider>().createGoal(
        title: title,
        targetBooks: target,
        startDate: _startDate,
        endDate: _endDate,
      );

      if (!mounted) return;

      _titleController.clear();
      _targetController.text = widget.initialReadingGoal.toString();
      setState(() {
        _startDate = DateTime.now();
        _endDate = DateTime.now().add(const Duration(days: 6));
      });

      _showMessage('Target membaca berhasil dibuat.');
    } catch (e) {
      if (!mounted) return;
      _showMessage('Gagal membuat target membaca: $e');
    } finally {
      if (mounted) setState(() => _isCreatingGoal = false);
    }
  }

  Widget _datePickerTile({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radiusMd),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: lightLavender,
            borderRadius: BorderRadius.circular(radiusMd),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: secondaryText),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_month_rounded,
                    size: 16,
                    color: primaryPurple,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _formatDate(date),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: darkText,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: softPurple,
                borderRadius: BorderRadius.circular(radiusSm),
              ),
              child: const Icon(
                Icons.flag_rounded,
                color: primaryPurple,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Target Membaca',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: darkText,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Buat target agar aktivitas membaca lebih terarah.',
                    style: TextStyle(color: secondaryText, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: spacingMd),

        // Name field
        _fieldLabel('Nama Target'),
        const SizedBox(height: spacingSm),
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            hintText: 'Contoh: Tantangan Membaca Mingguan',
            prefixIcon: Icon(Icons.label_rounded, size: 18),
          ),
        ),
        const SizedBox(height: spacingMd),

        // Target count field
        _fieldLabel('Target Jumlah Buku'),
        const SizedBox(height: spacingSm),
        TextField(
          controller: _targetController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Masukkan jumlah buku',
            suffixText: 'buku',
            prefixIcon: Icon(Icons.menu_book_rounded, size: 18),
          ),
        ),
        const SizedBox(height: spacingMd),

        // Date range
        _fieldLabel('Periode Membaca'),
        const SizedBox(height: spacingSm),
        Row(
          children: [
            _datePickerTile(
              label: 'Tanggal Mulai',
              date: _startDate,
              onTap: () => _pickDate(isStart: true),
            ),
            const SizedBox(width: spacingSm),
            _datePickerTile(
              label: 'Tanggal Selesai',
              date: _endDate,
              onTap: () => _pickDate(isStart: false),
            ),
          ],
        ),
        const SizedBox(height: spacingMd),

        // Submit button
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
                : const Icon(Icons.add_rounded),
            label: Text(
              _isCreatingGoal ? 'Menyimpan...' : 'Buat Target Membaca',
            ),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
      ],
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        color: darkText,
        fontSize: 13,
      ),
    );
  }
}
