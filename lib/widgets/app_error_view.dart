import 'package:flutter/material.dart';

import '../config/theme.dart';

/// Widget untuk kondisi kosong (empty state).
class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    this.title = 'Buku tidak ditemukan',
    this.message = 'Coba kata kunci yang berbeda.',
    this.icon = Icons.menu_book_rounded,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: spacingLg, vertical: 48),
      decoration: BoxDecoration(
        color: lightLavender,
        borderRadius: BorderRadius.circular(radiusLg),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(spacingMd),
            decoration: BoxDecoration(
              color: softPurple,
              borderRadius: BorderRadius.circular(radiusMd),
            ),
            child: Icon(icon, size: 40, color: primaryPurple),
          ),
          const SizedBox(height: spacingMd),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: darkText,
            ),
          ),
          const SizedBox(height: spacingSm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: secondaryText,
              height: 1.5,
              fontSize: 13,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: spacingMd),
            FilledButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

/// Widget untuk kondisi error jaringan atau API.
class AppErrorView extends StatelessWidget {
  const AppErrorView({
    super.key,
    this.message = 'Gagal memuat data. Periksa koneksi internet kamu.',
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: spacingLg, vertical: 48),
      decoration: BoxDecoration(
        color: errorColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(radiusLg),
        border: Border.all(color: errorColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(spacingMd),
            decoration: BoxDecoration(
              color: errorColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(radiusMd),
            ),
            child: Icon(
              Icons.wifi_off_rounded,
              size: 40,
              color: errorColor,
            ),
          ),
          const SizedBox(height: spacingMd),
          const Text(
            'Terjadi Kesalahan',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: darkText,
            ),
          ),
          const SizedBox(height: spacingSm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: secondaryText,
              height: 1.5,
              fontSize: 13,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: spacingMd),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba lagi'),
            ),
          ],
        ],
      ),
    );
  }
}
