import 'package:flutter/material.dart';

/// Widget input pencarian yang dapat digunakan di berbagai layar.
///
/// Gunakan [readOnly] + [onTap] untuk mode "tap to navigate" (seperti di HomeScreen).
/// Gunakan [onChanged] untuk mode pencarian aktif (seperti di CatalogScreen).
class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.hintText,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.controller,
    this.autofocus = false,
  });

  final String hintText;
  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: onChanged,
      autofocus: autofocus,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: readOnly ? const Icon(Icons.tune_rounded) : null,
      ),
    );
  }
}
