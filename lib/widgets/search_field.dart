import 'package:flutter/material.dart';

import '../config/theme.dart';

/// Widget input pencarian modern dengan animasi fokus.
class SearchField extends StatefulWidget {
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
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final TextEditingController _internalController;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _internalController = TextEditingController();
      _internalController.addListener(() {
        final has = _internalController.text.isNotEmpty;
        if (has != _hasText) setState(() => _hasText = has);
      });
    } else {
      _internalController = widget.controller!;
      _internalController.addListener(() {
        final has = _internalController.text.isNotEmpty;
        if (has != _hasText) setState(() => _hasText = has);
      });
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _internalController.dispose();
    }
    super.dispose();
  }

  void _clearSearch() {
    _internalController.clear();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _internalController,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      onChanged: widget.onChanged,
      autofocus: widget.autofocus,
      style: const TextStyle(color: darkText, fontSize: 14),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: const TextStyle(color: secondaryText, fontSize: 14),
        prefixIcon: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Icon(Icons.search_rounded, color: secondaryText, size: 20),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 48),
        suffixIcon: !widget.readOnly && _hasText
            ? IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                color: secondaryText,
                onPressed: _clearSearch,
                tooltip: 'Hapus pencarian',
              )
            : widget.readOnly
            ? const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Icon(
                  Icons.tune_rounded,
                  color: secondaryText,
                  size: 20,
                ),
              )
            : null,
        filled: true,
        fillColor: cardSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: primaryPurple, width: 1.5),
        ),
      ),
    );
  }
}
