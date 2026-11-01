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
            prefixIcon: Icon(Icons.person_rounded),
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
            alignLabelWithHint: true,
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

  Widget _sectionCard({required Widget child, String? title}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardSurface,
        borderRadius: BorderRadius.circular(radiusLg),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: primaryPurple.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(spacingMd, spacingMd, spacingMd, 0),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: darkText,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(spacingMd),
            child: child,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<UserProfileProvider>();
    final profile = profileProvider.profile;

    final currentName = profile?.name ?? _name;
    final currentAbout = profile?.about ?? _about;

    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(spacingMd),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile Header
                ProfileHeader(
                  name: currentName,
                  about: currentAbout,
                  onEditName: _editName,
                  onEditAbout: _editAbout,
                ),
                const SizedBox(height: spacingMd),

                // Reading Stats
                _buildReadingStats(),
                const SizedBox(height: spacingMd),

                // Goal Form
                _sectionCard(child: ProfileGoalForm(
                  initialReadingGoal: widget.initialReadingGoal,
                )),
                const SizedBox(height: spacingMd),

                // Goal History
                _sectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: softPurple,
                              borderRadius: BorderRadius.circular(radiusSm),
                            ),
                            child: const Icon(
                              Icons.insights_rounded,
                              color: primaryPurple,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Progres & Riwayat',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: darkText,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: spacingMd),
                      ProfileGoalHistory(savedBooks: widget.savedBooks),
                      const SizedBox(height: spacingSm),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () =>
                              context.read<ReadingGoalProvider>().loadGoals(),
                          icon: const Icon(Icons.refresh_rounded, size: 16),
                          label: const Text('Muat ulang'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: spacingLg),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReadingStats() {
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

    return Container(
      padding: const EdgeInsets.all(spacingMd),
      decoration: BoxDecoration(
        color: cardSurface,
        borderRadius: BorderRadius.circular(radiusLg),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: primaryPurple.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistik Bacaan',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: darkText,
            ),
          ),
          const SizedBox(height: spacingMd),
          Row(
            children: [
              _buildStatItem(
                icon: Icons.auto_stories_rounded,
                value: '$total',
                label: 'Total',
                color: primaryPurple,
              ),
              _buildStatItem(
                icon: Icons.menu_book_rounded,
                value: '$reading',
                label: 'Dibaca',
                color: warningColor,
              ),
              _buildStatItem(
                icon: Icons.check_circle_rounded,
                value: '$completed',
                label: 'Selesai',
                color: successColor,
              ),
              _buildStatItem(
                icon: Icons.bookmark_rounded,
                value: '$wantToRead',
                label: 'Wishlist',
                color: deepPurple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(radiusSm),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: secondaryText),
          ),
        ],
      ),
    );
  }
}
