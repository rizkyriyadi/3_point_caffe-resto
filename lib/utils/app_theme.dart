import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppTheme {
  // Primary color for the brand
  static const Color primaryColor = Color(0xFFC67C4E);

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFFDFDFD);
  static const Color lightTextPrimary = Color(0xFF313131);
  static const Color lightTextSecondary = Color(0xFF9B9B9B);
  static const Color lightCard = Colors.white;

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF8A8A8A);
  static const Color darkCard = Color(0xFF1F1F1F);

  static String formatRupiah(double amount) {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return format.format(amount);
  }

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: lightBackground,
    fontFamily: 'Poppins', // Default font
    textTheme: _buildTextTheme(base: ThemeData.light().textTheme, primaryColor: lightTextPrimary, secondaryColor: lightTextSecondary),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: lightTextPrimary),
      titleTextStyle: TextStyle(fontFamily: 'Urbanist', fontSize: 22, fontWeight: FontWeight.bold, color: lightTextPrimary),
    ),
    elevatedButtonTheme: _elevatedButtonTheme,
    iconTheme: const IconThemeData(color: lightTextSecondary),
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: primaryColor,
      background: lightBackground,
      surface: lightCard,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: lightTextPrimary,
      onSurface: lightTextPrimary,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: darkBackground,
    fontFamily: 'Poppins', // Default font
    textTheme: _buildTextTheme(base: ThemeData.dark().textTheme, primaryColor: darkTextPrimary, secondaryColor: darkTextSecondary),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: darkTextPrimary),
      titleTextStyle: TextStyle(fontFamily: 'Urbanist', fontSize: 22, fontWeight: FontWeight.bold, color: darkTextPrimary),
    ),
    elevatedButtonTheme: _elevatedButtonTheme,
    iconTheme: const IconThemeData(color: darkTextSecondary),
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: primaryColor,
      background: darkBackground,
      surface: darkCard,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: darkTextPrimary,
      onSurface: darkTextPrimary,
    ),
  );

  static TextTheme _buildTextTheme({required TextTheme base, required Color primaryColor, required Color secondaryColor}) {
    return base.copyWith(
      displayLarge: TextStyle(fontFamily: 'Urbanist', fontSize: 32, fontWeight: FontWeight.bold, color: primaryColor),
      displayMedium: TextStyle(fontFamily: 'Urbanist', fontSize: 28, fontWeight: FontWeight.bold, color: primaryColor),
      displaySmall: TextStyle(fontFamily: 'Urbanist', fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor),
      headlineMedium: TextStyle(fontFamily: 'Urbanist', fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor),
      headlineSmall: TextStyle(fontFamily: 'Urbanist', fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
      titleLarge: TextStyle(fontFamily: 'Urbanist', fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor),
      bodyLarge: TextStyle(fontSize: 16, color: primaryColor, height: 1.5),
      bodyMedium: TextStyle(fontSize: 14, color: secondaryColor, height: 1.5),
      labelLarge: const TextStyle(fontFamily: 'Urbanist', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
    ).apply(
      fontFamily: 'Poppins',
    );
  }

  static final ElevatedButtonThemeData _elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Urbanist'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
      elevation: 5,
      shadowColor: primaryColor.withOpacity(0.4),
    ),
  );
}
