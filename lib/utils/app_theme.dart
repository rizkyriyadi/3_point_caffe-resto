import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AppTheme {
  // Palet Warna Baru (Green & Fresh)
  static const Color primaryGreen = Color(0xFF006A42);
  static const Color accentOrange = Color(0xFFF9A261);
  static const Color background = Color(0xFFF7F7F8);
  static const Color surface = Colors.white;
  static const Color darkText = Color(0xFF1B1B1B);
  static const Color secondaryText = Color(0xFF6A6A6A);

  static String formatRupiah(double amount) {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return format.format(amount);
  }

  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryGreen,
    scaffoldBackgroundColor: background,
    fontFamily: GoogleFonts.poppins().fontFamily,
    colorScheme: const ColorScheme.light(
      primary: primaryGreen,
      secondary: accentOrange,
      background: background,
      surface: surface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: darkText,
      onSurface: darkText,
    ),
    textTheme: _buildTextTheme(base: ThemeData.light().textTheme, primaryColor: darkText, secondaryColor: secondaryText),
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: darkText, size: 24),
      titleTextStyle: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: darkText),
    ),
    elevatedButtonTheme: _elevatedButtonTheme,

    // PERBAIKAN: Menggunakan CardThemeData
    cardTheme: CardThemeData(
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: surface,
    ),

    inputDecorationTheme: InputDecorationTheme(
      hintStyle: const TextStyle(color: secondaryText),
      prefixIconColor: secondaryText,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
    ),

    // PERBAIKAN: Menggunakan TabBarThemeData
    tabBarTheme: TabBarThemeData(
      indicator: BoxDecoration(
        color: primaryGreen,
        borderRadius: BorderRadius.circular(12),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      labelColor: Colors.white,
      unselectedLabelColor: darkText,
      labelStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
      unselectedLabelStyle: const TextStyle(fontFamily: 'Poppins'),
    ),
  );

  static final ThemeData darkTheme = lightTheme.copyWith(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0D0D0D),
    colorScheme: const ColorScheme.dark(
      primary: primaryGreen,
      secondary: accentOrange,
      background: Color(0xFF0D0D0D),
      surface: Color(0xFF1A1A1A),
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onBackground: Colors.white,
      onSurface: Colors.white,
    ),
    textTheme: _buildTextTheme(base: ThemeData.dark().textTheme, primaryColor: Colors.white, secondaryColor: Colors.white70),
    appBarTheme: lightTheme.appBarTheme.copyWith(
      backgroundColor: const Color(0xFF0D0D0D),
      iconTheme: const IconThemeData(color: Colors.white, size: 24),
      titleTextStyle: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
    ),
    cardTheme: lightTheme.cardTheme.copyWith(
      color: const Color(0xFF1A1A1A),
    ),
    inputDecorationTheme: lightTheme.inputDecorationTheme.copyWith(
      fillColor: const Color(0xFF1A1A1A),
      hintStyle: const TextStyle(color: Colors.white54),
      prefixIconColor: Colors.white54,
    ),
    tabBarTheme: lightTheme.tabBarTheme.copyWith(
      unselectedLabelColor: Colors.white70,
    ),
  );

  static TextTheme _buildTextTheme({required TextTheme base, required Color primaryColor, required Color secondaryColor}) {
    return base.copyWith(
      displayLarge: GoogleFonts.urbanist(fontSize: 32, fontWeight: FontWeight.bold, color: primaryColor),
      displayMedium: GoogleFonts.urbanist(fontSize: 28, fontWeight: FontWeight.bold, color: primaryColor),
      displaySmall: GoogleFonts.urbanist(fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor),
      headlineMedium: GoogleFonts.urbanist(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor),
      headlineSmall: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
      titleLarge: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: primaryColor),
      bodyLarge: GoogleFonts.poppins(fontSize: 16, color: primaryColor),
      bodyMedium: GoogleFonts.poppins(fontSize: 14, color: secondaryColor),
      labelLarge: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
    ).apply(
      fontFamily: 'Poppins',
    );
  }

  static final ElevatedButtonThemeData _elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryGreen,
      foregroundColor: Colors.white,
      textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
      elevation: 2,
      shadowColor: primaryGreen.withOpacity(0.3),
    ),
  );
}