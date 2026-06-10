// theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const primaryColor   = Color(0xFF00A651);
  static const primaryDark    = Color(0xFF007A3D);
  static const primaryLight   = Color(0xFF4DC97E);
  static const accent         = Color(0xFFE8F7EF);
  static const accentDeep     = Color(0xFF00C260);
  static const scaffold       = Color(0xFFFFFFFF);
  static const surface        = Color(0xFFF7F8F7);
  static const cardColor      = Colors.white;
  static const textPrimary    = Color(0xFF0D1F14);
  static const textSecondary  = Color(0xFF6B7B70);
  static const divider        = Color(0xFFEBEFEC);

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
        headlineLarge: GoogleFonts.dmSerifDisplay(
          fontSize: 32, fontWeight: FontWeight.w400, color: textPrimary),
        titleLarge: GoogleFonts.dmSerifDisplay(
          fontSize: 22, fontWeight: FontWeight.w400, color: textPrimary),
        titleMedium: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w500, color: textSecondary),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14, color: textPrimary),
        labelSmall: GoogleFonts.inter(
          fontSize: 11, color: textSecondary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: GoogleFonts.dmSerifDisplay(
          fontSize: 20, fontWeight: FontWeight.w400, color: textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: divider)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: divider)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 1.8)),
        hintStyle: GoogleFonts.inter(
          fontSize: 14, color: const Color(0xFFADB5B7)),
      ),
    );
  }
}