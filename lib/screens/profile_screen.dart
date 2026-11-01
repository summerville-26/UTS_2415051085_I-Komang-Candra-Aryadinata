import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../models/saved_book.dart';
import '../providers/user_profile_provider.dart';
import '../providers/reading_goal_provider.dart';

import '../widgets/profile_header.dart';
import '../widgets/profile_goal_form.dart';
import '../widgets/profile_goal_history.dart';

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

  late String _name;
  late String _about;

  @override
  void initState() {
    super.initState();

    _name = widget.initialName;
    _about = widget.initialAbout;

    _nameController = TextEditingController(text: _name);

    _aboutController = TextEditingController(text: _about);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aboutController.dispose();

    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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
            onPressed: () {
              Navigator.pop(dialogContext);
            },
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
      setState(() {
        _name = result;
      });

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
            onPressed: () {
              Navigator.pop(dialogContext);
            },
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
      setState(() {
        _about = result;
      });

      widget.onSaveAbout?.call(result);

      _showMessage('Tentang Saya berhasil disimpan.');
    } else {
      _showMessage(
        profileProvider.errorMessage ?? 'Gagal menyimpan deskripsi profil.',
      );
    }
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
                // INFORMASI PROFIL
                ProfileHeader(
                  name: currentName,
                  about: currentAbout,
                  onEditName: _editName,
                  onEditAbout: _editAbout,
                ),

                const SizedBox(height: 18),

                // FORM PEMBUATAN TARGET
                _sectionCard(
                  child: ProfileGoalForm(
                    initialReadingGoal: widget.initialReadingGoal,
                  ),
                ),

                const SizedBox(height: 18),

                // RIWAYAT DAN PROGRES TARGET
                _sectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDBEAFE),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.insights_rounded,
                              color: primaryBlue,
                              size: 23,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Progres & Riwayat',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: darkText,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Progres dihitung dari buku yang '
                        'ditandai selesai dalam rentang tanggal '
                        'masing-masing target.',
                        style: TextStyle(
                          color: secondaryText,
                          height: 1.4,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 10),

                      ProfileGoalHistory(savedBooks: widget.savedBooks),

                      const SizedBox(height: 8),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () {
                            context.read<ReadingGoalProvider>().loadGoals();
                          },
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
