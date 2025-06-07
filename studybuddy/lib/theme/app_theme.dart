import 'package:flutter/material.dart';

final themeModeNotifier = ValueNotifier(ThemeMode.light);

class AppTheme {
  // Brand Colors
  static const Color primaryBlue = Color(0xFF2979FF);
  static const Color accentCyan = Color(0xFF00C4CC);
  static const Color darkBlue = Color(0xFF1565C0);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E2E);
  static const Color darkPrimaryText = Color(0xFFFFFFFF);
  static const Color darkSecondaryText = Color(0xFFB0BEC5);
  static const Color darkDivider = Color(0xFF2C2C2C);

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF5F5F5);
  static const Color lightPrimaryText = Color(0xFF212121);
  static const Color lightSecondaryText = Color(0xFF616161);
  static const Color lightDivider = Color(0xFFE0E0E0);

  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: lightBackground,
    cardColor: lightSurface,
    dividerColor: lightDivider,
    appBarTheme: const AppBarTheme(
      backgroundColor: lightBackground,
      foregroundColor: lightPrimaryText,
      elevation: 0,
      iconTheme: IconThemeData(color: lightPrimaryText),
      titleTextStyle: TextStyle(
        color: lightPrimaryText,
        fontWeight: FontWeight.bold,
        fontSize: 22,
        fontFamily: 'Roboto',
      ),
    ),
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: primaryBlue,
      onPrimary: Colors.white,
      secondary: accentCyan,
      onSecondary: Colors.white,
      surface: lightSurface,
      onSurface: lightPrimaryText,
      error: Colors.red,
      onError: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: lightPrimaryText, fontFamily: 'Roboto'),
      bodyMedium: TextStyle(color: lightSecondaryText, fontFamily: 'Roboto'),
      titleLarge: TextStyle(
        color: lightPrimaryText,
        fontWeight: FontWeight.bold,
        fontFamily: 'Roboto',
      ),
      titleMedium: TextStyle(
        color: lightPrimaryText,
        fontWeight: FontWeight.w600,
        fontFamily: 'Roboto',
      ),
    ),
    iconTheme: const IconThemeData(color: primaryBlue),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: lightSurface,
      selectedItemColor: primaryBlue,
      unselectedItemColor: lightSecondaryText,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: lightDivider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: lightDivider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: primaryBlue, width: 2),
      ),
      labelStyle: const TextStyle(
        color: lightSecondaryText,
        fontFamily: 'Roboto',
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
    ),
    cardTheme: CardThemeData(
      color: lightSurface,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
    ),
    dividerTheme: const DividerThemeData(color: lightDivider, thickness: 1),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: darkBackground,
    cardColor: darkSurface,
    dividerColor: darkDivider,
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBackground,
      foregroundColor: darkPrimaryText,
      elevation: 0,
      iconTheme: IconThemeData(color: darkPrimaryText),
      titleTextStyle: TextStyle(
        color: darkPrimaryText,
        fontWeight: FontWeight.bold,
        fontSize: 22,
        fontFamily: 'Roboto',
      ),
    ),
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: primaryBlue,
      onPrimary: Colors.white,
      secondary: accentCyan,
      onSecondary: Colors.white,
      surface: darkSurface,
      onSurface: darkPrimaryText,
      error: Colors.red,
      onError: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: darkPrimaryText, fontFamily: 'Roboto'),
      bodyMedium: TextStyle(color: darkSecondaryText, fontFamily: 'Roboto'),
      titleLarge: TextStyle(
        color: darkPrimaryText,
        fontWeight: FontWeight.bold,
        fontFamily: 'Roboto',
      ),
      titleMedium: TextStyle(
        color: darkPrimaryText,
        fontWeight: FontWeight.w600,
        fontFamily: 'Roboto',
      ),
    ),
    iconTheme: const IconThemeData(color: primaryBlue),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkSurface,
      selectedItemColor: primaryBlue,
      unselectedItemColor: darkSecondaryText,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: darkDivider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: darkDivider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: primaryBlue, width: 2),
      ),
      labelStyle: const TextStyle(
        color: darkSecondaryText,
        fontFamily: 'Roboto',
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
    ),
    cardTheme: CardThemeData(
      color: darkSurface,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
    ),
    dividerTheme: const DividerThemeData(color: darkDivider, thickness: 1),
  );

  static void toggleTheme() {
    themeModeNotifier.value = themeModeNotifier.value == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
  }
}
