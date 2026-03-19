// lib/app_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF1A3C5E);       // deep navy
  static const Color accent = Color(0xFFD4A843);         // warm gold
  static const Color surface = Color(0xFFF8F4EF);        // warm cream
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF0D1B2A);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color success = Color(0xFF2D7D46);
  static const Color danger = Color(0xFFB91C1C);
  static const Color issued = Color(0xFFD97706);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
          primary: primary,
          secondary: accent,
          surface: surface,
        ),
        scaffoldBackgroundColor: surface,
        textTheme: GoogleFonts.libreBaskervilleTextTheme().copyWith(
          displayLarge: GoogleFonts.playfairDisplay(
            fontSize: 32, fontWeight: FontWeight.w700, color: textDark),
          displayMedium: GoogleFonts.playfairDisplay(
            fontSize: 26, fontWeight: FontWeight.w600, color: textDark),
          titleLarge: GoogleFonts.playfairDisplay(
            fontSize: 20, fontWeight: FontWeight.w600, color: textDark),
          titleMedium: GoogleFonts.raleway(
            fontSize: 16, fontWeight: FontWeight.w600, color: textDark),
          bodyLarge: GoogleFonts.raleway(
            fontSize: 15, color: textDark),
          bodyMedium: GoogleFonts.raleway(
            fontSize: 14, color: textMuted),
          labelLarge: GoogleFonts.raleway(
            fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFDDD5C8), width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFDDD5C8), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: danger, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          hintStyle: GoogleFonts.raleway(color: const Color(0xFFB0A99A), fontSize: 14),
          labelStyle: GoogleFonts.raleway(color: textMuted, fontSize: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: GoogleFonts.raleway(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.5),
          ),
        ),
        cardTheme: CardThemeData(
          color: cardBg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFEDE8E0), width: 1),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: GoogleFonts.playfairDisplay(
            fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
          centerTitle: true,
        ),
      );
}