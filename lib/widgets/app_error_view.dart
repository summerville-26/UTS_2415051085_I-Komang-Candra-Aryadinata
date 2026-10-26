import 'package:flutter/material.dart';

import '../config/theme.dart';

/// Widget untuk kondisi kosong (empty state) — digunakan di katalog dan perpustakaan.
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

  /// Jika diisi, menampilkan tombol aksi di bawah pesan.
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 42),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: secondaryText),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: darkText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: secondaryText, height: 1.5),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 20),
            FilledButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

/// Widget untuk kondisi error jaringan atau API — digunakan saat request gagal.
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 42),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 48, color: secondaryText),
          const SizedBox(height: 12),
          const Text(
            'Terjadi Kesalahan',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: darkText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: secondaryText, height: 1.5),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 20),
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
