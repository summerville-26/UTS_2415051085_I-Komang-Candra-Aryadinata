import 'package:flutter/material.dart';

// ─── BookNest Purple & White Design System ────────────────────────────────────

// Core palette
const Color primaryPurple = Color(0xFF6C4AB6);
const Color deepPurple = Color.fromARGB(255, 99, 61, 170);
const Color softPurple = Color.fromARGB(255, 180, 146, 248);
const Color lightLavender = Color.fromARGB(255, 223, 204, 255);
const Color pageBackground = Color(0xFFFAF9FC);
const Color cardSurface = Color(0xFFFFFFFF);

// Text colors
const Color darkText = Color(0xFF252238);
const Color secondaryText = Color(0xFF817C91);

// Border / divider
const Color borderColor = Color(0xFFEAE6F0);

// Semantic colors
const Color successColor = Color(0xFF299D70);
const Color warningColor = Color(0xFFE6A23C);
const Color errorColor = Color(0xFFD95767);

// ─── Design Tokens ────────────────────────────────────────────────────────────
const double radiusSm = 10.0;
const double radiusMd = 16.0;
const double radiusLg = 22.0;
const double radiusXl = 28.0;

const double spacingSm = 8.0;
const double spacingMd = 16.0;
const double spacingLg = 24.0;
const double spacingXl = 32.0;

// ─── ThemeData ────────────────────────────────────────────────────────────────
ThemeData buildBookNestTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: pageBackground,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 173, 135, 255),
      primary: const Color.fromARGB(255, 172, 137, 247),
      secondary: deepPurple,
      surface: cardSurface,
      error: errorColor,
      brightness: Brightness.light,
    ).copyWith(primaryContainer: softPurple, secondaryContainer: lightLavender),
    fontFamily: 'Roboto',

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: pageBackground,
      foregroundColor: darkText,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: darkText,
        fontFamily: 'Roboto',
      ),
    ),

    // Input fields
    inputDecorationTheme: InputDecorationTheme(
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: errorColor, width: 1.5),
      ),
      hintStyle: const TextStyle(color: secondaryText, fontSize: 14),
      prefixIconColor: secondaryText,
    ),

    // Filled buttons
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: spacingMd,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),

    // Outlined buttons
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryPurple,
        side: const BorderSide(color: primaryPurple),
        padding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: spacingMd,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),

    // Text buttons
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryPurple,
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
    ),

    // Cards
    cardTheme: CardThemeData(
      color: cardSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        side: const BorderSide(color: borderColor),
      ),
    ),

    // Chips
    chipTheme: ChipThemeData(
      backgroundColor: softPurple,
      labelStyle: const TextStyle(color: primaryPurple, fontSize: 12),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusSm),
      ),
    ),

    // Navigation Bar
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: cardSurface,
      indicatorColor: softPurple,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            color: primaryPurple,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          );
        }
        return const TextStyle(
          color: secondaryText,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: primaryPurple, size: 22);
        }
        return const IconThemeData(color: secondaryText, size: 22);
      }),
      elevation: 0,
      height: 66,
    ),

    // Dialogs
    dialogTheme: DialogThemeData(
      backgroundColor: cardSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLg),
      ),
      titleTextStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: darkText,
        fontFamily: 'Roboto',
      ),
    ),

    // SnackBar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: deepPurple,
      contentTextStyle: const TextStyle(color: Colors.white, fontSize: 13),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMd),
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 4,
    ),

    // Progress indicator
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryPurple,
      linearTrackColor: softPurple,
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: borderColor,
      thickness: 1,
      space: 1,
    ),
  );
}

// ─── Reusable card decorations ────────────────────────────────────────────────
BoxDecoration get bookNestCardDecoration => BoxDecoration(
  color: cardSurface,
  borderRadius: BorderRadius.circular(radiusLg),
  border: Border.all(color: borderColor),
  boxShadow: [
    BoxShadow(
      color: const Color(0xFF6C4AB6).withValues(alpha: 0.04),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ],
);

BoxDecoration get bookNestSoftCardDecoration => BoxDecoration(
  color: lightLavender,
  borderRadius: BorderRadius.circular(radiusMd),
  border: Border.all(color: borderColor),
);

// ─── Legacy aliases (backward compat for screens referencing old color names)
const Color primaryBlue = primaryPurple;
const Color lightBlue = softPurple;
