import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Bright, vivid green palette
  static const primaryColor   = Color(0xFF00C853); // vivid green
  static const primaryDark    = Color(0xFF00A040); // deeper green
  static const primaryLight   = Color(0xFF69F0AE); // bright mint
  static const accent         = Color(0xFFB9F6CA); // soft mint fill
  static const accentDeep     = Color(0xFF00E676); // neon-ish accent
  static const scaffold       = Color(0xFFF3FFF7); // very light green tint
  static const cardColor      = Colors.white;
  static const textPrimary    = Color(0xFF0D2B1A);
  static const textSecondary  = Color(0xFF5A7568);
  static const divider        = Color(0xFFDCF5E4);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: scaffold,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: accentDeep,
        brightness: Brightness.light,
      ),
      cardColor: cardColor,
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.playfairDisplay(
          fontSize: 30, fontWeight: FontWeight.w700, color: textPrimary),
        titleLarge: GoogleFonts.playfairDisplay(
          fontSize: 22, fontWeight: FontWeight.w700, color: textPrimary),
        titleMedium: GoogleFonts.plusJakartaSans(
          fontSize: 14, color: textSecondary),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 14, color: textPrimary),
        labelSmall: GoogleFonts.plusJakartaSans(
          fontSize: 11, color: textSecondary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF0FFF4),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFB7E4C7))),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFB7E4C7))),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 1.8)),
        hintStyle: GoogleFonts.plusJakartaSans(
          fontSize: 13, color: const Color(0xFF9CA3AF)),
      ),
    );
  }
}
