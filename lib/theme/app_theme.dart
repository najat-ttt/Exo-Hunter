import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color constants
  static const Color midnightBlue = Color(0xFF0B132B);
  static const Color nebulaCyan = Color(0xFF00BFA6);
  static const Color cosmicPurple = Color(0xFF6C63FF);
  static const Color supernovaOrange = Color(0xFFFF6F00);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        surface: midnightBlue,
        primary: nebulaCyan,
        secondary: cosmicPurple,
        tertiary: supernovaOrange,
        onSurface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
      ),

      // Text Theme with custom fonts
      textTheme: TextTheme(
        // Headlines using Orbitron
        headlineLarge: GoogleFonts.orbitron(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineMedium: GoogleFonts.orbitron(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineSmall: GoogleFonts.orbitron(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),

        // Body text using Inter
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: Colors.white70,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: Colors.white70,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          color: Colors.white60,
        ),

        // Labels using Inter
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),

      // Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: nebulaCyan,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withAlpha((0.1 * 255).toInt()),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withAlpha((0.3 * 255).toInt())),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: nebulaCyan, width: 2),
        ),
        labelStyle: GoogleFonts.inter(color: Colors.white70),
        hintStyle: GoogleFonts.inter(color: Colors.white54),
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: midnightBlue,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.orbitron(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}