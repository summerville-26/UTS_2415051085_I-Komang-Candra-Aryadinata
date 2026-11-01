import 'package:flutter/material.dart';

import '../config/theme.dart';

/// Widget header profil pengguna.
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
      decoration: BoxDecoration(
        color: cardSurface,
        borderRadius: BorderRadius.circular(radiusLg),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: primaryPurple.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar area with purple gradient banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: spacingLg,
              bottom: spacingXl,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [primaryPurple, deepPurple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(radiusLg),
                topRight: Radius.circular(radiusLg),
              ),
            ),
            child: const Center(
              child: Text(
                'Profil Saya',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),

          // Avatar overlapping the banner
          Transform.translate(
            offset: const Offset(0, -36),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: cardSurface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryPurple.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 44,
                backgroundColor: softPurple,
                child: const Icon(
                  Icons.person_rounded,
                  color: primaryPurple,
                  size: 50,
                ),
              ),
            ),
          ),

          // Name row
          Transform.translate(
            offset: const Offset(0, -28),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: spacingMd),
              child: Column(
                children: [
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
                      const SizedBox(width: spacingSm),
                      InkWell(
                        onTap: onEditName,
                        borderRadius: BorderRadius.circular(radiusSm),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: softPurple,
                            borderRadius: BorderRadius.circular(radiusSm),
                          ),
                          child: const Icon(
                            Icons.edit_rounded,
                            color: primaryPurple,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: softPurple,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Pembaca BookNest',
                      style: TextStyle(
                        color: primaryPurple,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: spacingMd),
                  const Divider(height: 1),
                  const SizedBox(height: spacingMd),

                  // About section
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Tentang Saya',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: darkText,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: onEditAbout,
                        icon: const Icon(Icons.edit_rounded, size: 15),
                        label: const Text('Edit'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: spacingSm,
                            vertical: 4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: spacingSm),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      about.isEmpty
                          ? 'Tambahkan sedikit informasi tentang diri, '
                                'minat, atau buku favoritmu.'
                          : about,
                      style: TextStyle(
                        height: 1.6,
                        color: about.isEmpty ? secondaryText : darkText,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: spacingMd),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
