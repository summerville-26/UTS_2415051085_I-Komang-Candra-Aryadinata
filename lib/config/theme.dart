import 'package:flutter/material.dart';

// ─── Palet Warna BookNest ───────────────────────────────────────────────────
const Color primaryBlue = Color(0xFF2563EB);
const Color lightBlue = Color(0xFFEFF6FF);
const Color pageBackground = Color(0xFFF8FAFC);
const Color darkText = Color(0xFF172554);
const Color secondaryText = Color(0xFF64748B);

// ─── ThemeData Aplikasi ─────────────────────────────────────────────────────
ThemeData buildBookNestTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: pageBackground,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      primary: primaryBlue,
      surface: Colors.white,
    ),
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: pageBackground,
      foregroundColor: darkText,
      elevation: 0,
      centerTitle: false,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryBlue, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
    ),
  );
}
