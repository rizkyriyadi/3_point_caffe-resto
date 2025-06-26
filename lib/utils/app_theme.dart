// lib/utils/app_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Tema Terang (Hijau - Putih)
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF2A9361),
    scaffoldBackgroundColor: const Color(0xFFF7F7F7),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF2A9361),
      secondary: Color(0xFF1E6A45),
      background: Color(0xFFF7F7F7),
      onBackground: Colors.black,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFFF7F7F7),
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
      titleTextStyle: GoogleFonts.poppins(
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: GoogleFonts.poppinsTextTheme().apply(
      bodyColor: Colors.black,
      displayColor: Colors.black,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2A9361),
        foregroundColor: Colors.white,
      ),
    ),
  );

  // Tema Gelap (Coklat - Hitam)
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.brown[400],
    scaffoldBackgroundColor: const Color(0xFF1a1a1a),
    colorScheme: ColorScheme.dark(
      primary: Colors.brown[300]!,
      secondary: Colors.brown[400]!,
      background: const Color(0xFF1a1a1a),
      onBackground: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF1a1a1a),
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: GoogleFonts.poppins(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: GoogleFonts.poppinsTextTheme().apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.brown[400],
        foregroundColor: Colors.white,
      ),
    ),
  );
}
