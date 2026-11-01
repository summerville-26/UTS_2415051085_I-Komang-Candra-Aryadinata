import 'package:flutter/material.dart';

import '../config/theme.dart';

/// Chip kategori yang dapat diklik dengan visual identity purple & white.
class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.label,
    required this.icon,
    this.onTap,
    this.isSelected = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  /// Jika true, tampilkan chip dengan latar ungu untuk menandakan filter aktif.
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radiusMd),
        splashColor: primaryPurple.withValues(alpha: 0.1),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? primaryPurple : cardSurface,
            borderRadius: BorderRadius.circular(radiusMd),
            border: Border.all(
              color: isSelected ? primaryPurple : borderColor,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? primaryPurple.withValues(alpha: 0.2)
                    : primaryPurple.withValues(alpha: 0.03),
                blurRadius: isSelected ? 8 : 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : primaryPurple,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : darkText,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
