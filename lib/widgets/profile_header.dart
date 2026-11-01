import 'package:flutter/material.dart';

import '../../config/theme.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.name,
    required this.about,
    required this.onEditName,
    required this.onEditAbout,
  });

  final String name;
  final String about;
  final VoidCallback onEditName;
  final VoidCallback onEditAbout;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
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
      child: Column(
        children: [
          const CircleAvatar(
            radius: 43,
            backgroundColor: Color(0xFFDBEAFE),
            child: Icon(Icons.person_rounded, color: primaryBlue, size: 49),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  name.isEmpty ? 'Nama Pengguna' : name,
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
                onPressed: onEditName,
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
                onPressed: onEditAbout,
                icon: const Icon(Icons.edit_outlined, size: 17),
                label: const Text('Edit'),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              about.isEmpty
                  ? 'Tambahkan sedikit informasi tentang diri, '
                        'minat, atau buku favoritmu.'
                  : about,
              style: TextStyle(
                height: 1.5,
                color: about.isEmpty ? secondaryText : darkText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
