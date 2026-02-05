import 'package:flutter/material.dart';

// ============================================================================
// APP THEME - Light & Dark Mode Configuration
// ============================================================================
//
// WHAT IS A THEME?
// -----------------
// A theme is like a "style guide" for your entire app. Instead of setting
// colors, fonts, and sizes on every single widget, you define them ONCE here,
// and Flutter applies them everywhere automatically.
//
// React/CSS Equivalent:
// - CSS Variables (--primary-color: #6200EE)
// - styled-components ThemeProvider
// - Tailwind's theme configuration
//
// WHY USE THEMES?
// ----------------
// 1. Consistency - Same colors/fonts everywhere
// 2. Easy to change - Update once, changes everywhere
// 3. Dark mode - Switch themes with one line of code
// 4. Less code - Don't repeat color values in every widget
//
// ============================================================================

// ----------------------------------------------------------------------------
// COLOR SCHEME
// ----------------------------------------------------------------------------
// ColorScheme defines ALL the colors your app will use.
// Material 3 has specific color "roles" - each color has a purpose.
//
// Think of it like a paint palette with labeled colors:
// - primary     = Your brand color (buttons, links, highlights)
// - secondary   = Accent color (FABs, selection controls)
// - surface     = Background of cards, sheets, menus
// - background  = Screen background
// - error       = Error messages, destructive actions
//
// Each color has an "on" variant for text/icons ON TOP of that color:
// - onPrimary   = Text color on primary colored buttons
// - onSurface   = Text color on cards/surfaces
// ----------------------------------------------------------------------------

class AppTheme {
  // Private constructor - prevents creating instances of this class
  // We only use the static methods: lightTheme and darkTheme
  AppTheme._();

  // ==========================================================================
  // SHARED COLORS (used in both light and dark themes)
  // ==========================================================================

  // Primary color - Your main brand color
  // This appears on: buttons, app bar, links, active states
  static const Color primaryColor = Color(0xFF6366F1);  // Indigo

  // Secondary color - Accent for less prominent elements
  // This appears on: FABs, chips, switches, sliders
  static const Color secondaryColor = Color(0xFF8B5CF6);  // Purple

  // Error color - For errors and destructive actions
  // This appears on: error messages, delete buttons, validation errors
  static const Color errorColor = Color(0xFFEF4444);  // Red

  // ==========================================================================
  // LIGHT THEME
  // ==========================================================================
  //
  // Light theme = dark text on light backgrounds
  // Used when: User prefers light mode, or during daytime
  //
  // ==========================================================================

  static ThemeData lightTheme = ThemeData(
    // --- BRIGHTNESS ---
    // Tells Flutter this is a LIGHT theme
    // Affects default text colors, icon colors, etc.
    brightness: Brightness.light,

    // --- USE MATERIAL 3 ---
    // Material 3 (Material You) is Google's latest design system
    // Features: more rounded corners, dynamic colors, updated components
    // Set to false for Material 2 (older, more square design)
    useMaterial3: true,

    // --- COLOR SCHEME ---
    // The complete color palette for this theme
    colorScheme: const ColorScheme.light(
      // Primary - main brand color
      primary: primaryColor,
      onPrimary: Colors.white,  // Text ON primary buttons = white

      // Secondary - accent color
      secondary: secondaryColor,
      onSecondary: Colors.white,

      // Surface - cards, dialogs, sheets background
      surface: Colors.white,
      onSurface: Color(0xFF1F2937),  // Dark gray text

      // Background - scaffold/screen background
      // In Material 3, 'background' is being replaced by 'surface'
      // but we set both for compatibility

      // Error - error states
      error: errorColor,
      onError: Colors.white,

      // Outline - borders, dividers
      outline: Color(0xFFE5E7EB),
    ),

    // --- SCAFFOLD BACKGROUND ---
    // The background color of every screen (Scaffold widget)
    scaffoldBackgroundColor: const Color(0xFFF9FAFB),  // Very light gray

    // --- APP BAR THEME ---
    // Styles the top bar of your app
    appBarTheme: const AppBarTheme(
      // Elevation = shadow depth (0 = flat, no shadow)
      elevation: 0,
      // Centers the title on the app bar
      centerTitle: true,
      // App bar background color
      backgroundColor: Colors.white,
      // App bar text/icon color
      foregroundColor: Color(0xFF1F2937),
      // Title text style
      titleTextStyle: TextStyle(
        color: Color(0xFF1F2937),
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),

    // --- CARD THEME ---
    // Styles all Card widgets
    cardTheme: CardTheme(
      elevation: 0,  // Flat cards (modern look)
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),  // Rounded corners
        side: const BorderSide(color: Color(0xFFE5E7EB)),  // Light border
      ),
      color: Colors.white,
    ),

    // --- ELEVATED BUTTON THEME ---
    // Styles ElevatedButton widgets (primary action buttons)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,  // Flat button
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // --- OUTLINED BUTTON THEME ---
    // Styles OutlinedButton widgets (secondary action buttons)
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: const BorderSide(color: primaryColor),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // --- TEXT BUTTON THEME ---
    // Styles TextButton widgets (tertiary/text-only buttons)
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // --- INPUT DECORATION THEME ---
    // Styles TextField and TextFormField widgets
    inputDecorationTheme: InputDecorationTheme(
      filled: true,  // Adds background fill
      fillColor: Colors.white,

      // Border when not focused
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),

      // Border when enabled but not focused
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),

      // Border when focused (user is typing)
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),

      // Border when there's an error
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: errorColor),
      ),

      // Padding inside the text field
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    // --- FLOATING ACTION BUTTON THEME ---
    // Styles the FAB (usually bottom-right button)
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // --- BOTTOM NAVIGATION BAR THEME ---
    // Styles the bottom tab bar (if we use one)
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryColor,
      unselectedItemColor: const Color(0xFF9CA3AF),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

    // --- DIVIDER THEME ---
    // Styles Divider widgets (horizontal lines)
    dividerTheme: const DividerThemeData(
      color: Color(0xFFE5E7EB),
      thickness: 1,
    ),
  );

  // ==========================================================================
  // DARK THEME
  // ==========================================================================
  //
  // Dark theme = light text on dark backgrounds
  // Used when: User prefers dark mode, or during nighttime
  // Benefits: Easier on eyes at night, saves battery on OLED screens
  //
  // ==========================================================================

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,

    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      onPrimary: Colors.white,

      secondary: secondaryColor,
      onSecondary: Colors.white,

      // In dark mode, surfaces are dark gray, not black
      // Pure black (#000000) is harsh on the eyes
      surface: Color(0xFF1F2937),
      onSurface: Color(0xFFF9FAFB),  // Light text

      error: errorColor,
      onError: Colors.white,

      outline: Color(0xFF374151),
    ),

    scaffoldBackgroundColor: const Color(0xFF111827),  // Very dark blue-gray

    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Color(0xFF1F2937),
      foregroundColor: Color(0xFFF9FAFB),
      titleTextStyle: TextStyle(
        color: Color(0xFFF9FAFB),
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),

    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF374151)),
      ),
      color: const Color(0xFF1F2937),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: const BorderSide(color: primaryColor),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1F2937),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF374151)),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF374151)),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: errorColor),
      ),

      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: const Color(0xFF1F2937),
      selectedItemColor: primaryColor,
      unselectedItemColor: const Color(0xFF9CA3AF),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

    dividerTheme: const DividerThemeData(
      color: Color(0xFF374151),
      thickness: 1,
    ),
  );
}

// ============================================================================
// HOW TO USE THIS THEME
// ============================================================================
//
// 1. In main.dart, apply the theme to MaterialApp:
//
//    MaterialApp(
//      theme: AppTheme.lightTheme,       // Light mode
//      darkTheme: AppTheme.darkTheme,    // Dark mode
//      themeMode: ThemeMode.system,      // Follow device setting
//      home: MyHomePage(),
//    )
//
// 2. Access theme colors in any widget:
//
//    // Get current theme's primary color
//    final primaryColor = Theme.of(context).colorScheme.primary;
//
//    // Get current theme's text color
//    final textColor = Theme.of(context).colorScheme.onSurface;
//
//    // Check if current theme is dark
//    final isDark = Theme.of(context).brightness == Brightness.dark;
//
// 3. ThemeMode options:
//
//    ThemeMode.light   - Always use light theme
//    ThemeMode.dark    - Always use dark theme
//    ThemeMode.system  - Follow device's dark mode setting (recommended)
//
// ============================================================================
