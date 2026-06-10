import 'package:flutter/material.dart';

class AppTheme {
  // Modern green color palette
  static const primaryColor = Color(0xFF00C853); // Modern green
  static const primaryLight = Color(0xFF69F0AE); // Light green
  static const primaryDark = Color(0xFF007E33); // Dark green
  static const accentColor = Color(0xFF00BFA5); // Teal accent
  static const backgroundColor = Color(0xFFF1F8E9); // Light green background
  static const cardColor = Colors.white;
  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
  static const shadowColor = Color(0x1A000000);
  static const dividerColor = Color(0xFFBDBDBD);
  static const shimmerBase = Color(0xFFE0E0E0);
  static const shimmerHighlight = Color(0xFFF5F5F5);
  static const successColor = Color(0xFF4CAF50);
  static const errorColor = Color(0xFFE53935);
  static const warningColor = Color(0xFFFB8C00);

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        bodyMedium: TextStyle(
          color: textPrimary,
          fontSize: 16,
        ),
        titleMedium: TextStyle(
          color: textSecondary,
          fontSize: 14,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
        hintStyle: TextStyle(color: textSecondary.withOpacity(0.7)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 4,
      ),
    );
  }
}