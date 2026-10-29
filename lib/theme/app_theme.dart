import 'package:flutter/material.dart';

class AppTheme {
  // Paleta de colores solicitada: Blanco, Azul cielo, Azul marino y Gris claro
  static const Color pureWhite = Colors.white; // Blanco
  static const Color navyBlue = Color(0xFF0F172A); // Azul marino
  static const Color skyBlue = Color(0xFF0EA5E9); // Azul cielo
  static const Color lightGray = Color(0xFFF1F5F9); // Gris claro
  
  // Aliases for compatibility
  static const Color primaryNavy = navyBlue;
  static const Color mediumBlue = skyBlue;
  static const Color backgroundLight = lightGray;
  
  static const Color cardBackground = pureWhite;
  static const Color textDark = navyBlue;
  static const Color textMuted = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE2E8F0);
  
  // Status Colors
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color errorRed = Color(0xFFEF4444);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: skyBlue,
        primary: navyBlue,
        secondary: skyBlue,
        surface: lightGray,
        onSurface: textDark,
      ),
      scaffoldBackgroundColor: lightGray,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: pureWhite,
        foregroundColor: textDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBackground,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: skyBlue,
          foregroundColor: pureWhite,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: pureWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: skyBlue, width: 2),
        ),
        hintStyle: const TextStyle(color: textMuted, fontSize: 14),
      ),
    );
  }
}
