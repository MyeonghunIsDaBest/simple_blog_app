// lib/config/app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  // ─── Brand Colors ───
  static const Color _seed = Color(0xFF78716C); // Warm stone grey (pearl)

  // ═══════════════════════════════════════════
  //  LIGHT THEME (Grey-White Pearl)
  // ═══════════════════════════════════════════
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.light,
      primary: const Color(0xFF6B6B6B),
      onPrimary: Colors.white,
      surface: const Color(0xFFFCFCFC),
      onSurface: const Color(0xFF2C2C2C),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF7F7F8),
      fontFamily: 'Roboto',

      // ── AppBar ──
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        backgroundColor: const Color(0xFFFCFCFC),
        foregroundColor: const Color(0xFF2C2C2C),
        surfaceTintColor: Colors.transparent,
        titleTextStyle: const TextStyle(
          color: Color(0xFF2C2C2C),
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(
          color: colorScheme.onSurface.withOpacity(0.65),
          size: 22,
        ),
      ),

      // ── Card ──
      cardTheme: CardTheme(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE8E8EA), width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Input ──
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF3F3F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE0E0E3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        hintStyle: TextStyle(
          color: const Color(0xFF2C2C2C).withOpacity(0.3),
          fontWeight: FontWeight.w400,
        ),
        labelStyle: TextStyle(
          color: const Color(0xFF2C2C2C).withOpacity(0.55),
          fontWeight: FontWeight.w500,
        ),
      ),

      // ── Buttons ──
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4A4A4A),
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary.withOpacity(0.4)),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── FAB ──
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: const Color(0xFF4A4A4A),
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // ── Divider ──
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE8E8EA),
        thickness: 1,
        space: 1,
      ),

      // ── BottomSheet ──
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        showDragHandle: true,
      ),

      // ── Dialog ──
      dialogTheme: DialogTheme(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF2C2C2C),
        ),
      ),

      // ── SnackBar ──
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),

      // ── Chip ──
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.primary.withOpacity(0.08),
        labelStyle: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: BorderSide.none,
      ),
    );
  }

  // ═══════════════════════════════════════════
  //  DARK THEME (Warm Darkish Pearl)
  // ═══════════════════════════════════════════
  static ThemeData get darkTheme {
    // Warm color palette with better contrast
    const Color backgroundDark = Color(0xFF1A1816);      // Warm charcoal
    const Color surfaceDark = Color(0xFF262320);         // Warm dark gray-brown
    const Color surfaceVariant = Color(0xFF2D2926);      // Lighter warm gray
    const Color primaryWarm = Color(0xFFC9A687);         // Warm caramel/tan
    const Color primaryVariant = Color(0xFFB89775);      // Darker warm tan
    const Color accentWarm = Color(0xFFD4A574);          // Warm gold
    const Color borderWarm = Color(0xFF3A3632);          // Warm border
    const Color textPrimary = Color(0xFFE8E3DC);         // Warm off-white
    const Color textSecondary = Color(0xFFB8AFA5);       // Warm muted text

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryWarm,
      brightness: Brightness.dark,
      primary: primaryWarm,
      onPrimary: backgroundDark,
      surface: surfaceDark,
      onSurface: textPrimary,
      secondary: accentWarm,
      onSecondary: backgroundDark,
      tertiary: primaryVariant,
      error: const Color(0xFFFF6B6B),  // Softer red for dark mode
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundDark,
      fontFamily: 'Roboto',

      // ── AppBar ──
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        backgroundColor: surfaceDark,
        foregroundColor: textPrimary,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: const TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(
          color: textPrimary.withOpacity(0.75),
          size: 22,
        ),
      ),

      // ── Card ──
      cardTheme: CardTheme(
        color: surfaceDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderWarm, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Input ──
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderWarm, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryWarm, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        hintStyle: TextStyle(
          color: textSecondary.withOpacity(0.5),
          fontWeight: FontWeight.w400,
        ),
        labelStyle: const TextStyle(
          color: textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),

      // ── Buttons ──
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryWarm,
          foregroundColor: backgroundDark,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryWarm,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryWarm,
          side: const BorderSide(color: primaryWarm, width: 1.5),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── FAB ──
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryWarm,
        foregroundColor: backgroundDark,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // ── Divider ──
      dividerTheme: const DividerThemeData(
        color: borderWarm,
        thickness: 1,
        space: 1,
      ),

      // ── BottomSheet ──
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceDark,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        showDragHandle: true,
      ),

      // ── Dialog ──
      dialogTheme: DialogTheme(
        backgroundColor: surfaceDark,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
      ),

      // ── SnackBar ──
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: surfaceVariant,
        contentTextStyle: const TextStyle(color: textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
      ),

      // ── Chip ──
      chipTheme: ChipThemeData(
        backgroundColor: primaryWarm.withOpacity(0.15),
        labelStyle: const TextStyle(
          color: primaryWarm,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: BorderSide.none,
      ),

      // ── Icon Theme ──
      iconTheme: IconThemeData(
        color: textPrimary.withOpacity(0.75),
      ),

      // ── Text Theme ──
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
        displayMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
        displaySmall: TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
        headlineLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
        headlineMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: textPrimary, height: 1.6),
        bodyMedium: TextStyle(color: textPrimary, height: 1.5),
        bodySmall: TextStyle(color: textSecondary),
        labelLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
        labelMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
        labelSmall: TextStyle(color: textSecondary),
      ),
    );
  }
}
