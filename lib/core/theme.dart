import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Mirrors the web app's CSS custom properties in app/globals.css —
/// same warm-cream/gold/coral palette, same light/dark pairs.
class AppColors {
  final Color background;
  final Color surface;
  final Color ink;
  final Color inkSoft;
  final Color brand;
  final Color brandInk;
  final Color accent;
  final Color accentInk;
  final Color border;

  const AppColors({
    required this.background,
    required this.surface,
    required this.ink,
    required this.inkSoft,
    required this.brand,
    required this.brandInk,
    required this.accent,
    required this.accentInk,
    required this.border,
  });

  static const light = AppColors(
    background: Color(0xFFFAF3E6),
    surface: Color(0xFFFFFFFF),
    ink: Color(0xFF18130E),
    inkSoft: Color(0xFF57493A),
    brand: Color(0xFFF2A900),
    brandInk: Color(0xFF1D1204),
    accent: Color(0xFFFF3D68),
    accentInk: Color(0xFFFFF7EF),
    border: Color(0xFFE7D8BD),
  );

  static const dark = AppColors(
    background: Color(0xFF120F0A),
    surface: Color(0xFF1D1712),
    ink: Color(0xFFF8EFE0),
    inkSoft: Color(0xFFCDBBA1),
    brand: Color(0xFFFFC22E),
    brandInk: Color(0xFF1D1204),
    accent: Color(0xFFFF5C82),
    accentInk: Color(0xFF23020C),
    border: Color(0xFF362A1C),
  );
}

extension AppColorsX on BuildContext {
  AppColors get colors => Theme.of(this).brightness == Brightness.dark ? AppColors.dark : AppColors.light;
}

/// Bricolage Grotesque (display/headers) + Plus Jakarta Sans (body) —
/// the same pairing as next/font/google in app/layout.tsx.
ThemeData buildAppTheme(AppColors c) {
  final displayFont = GoogleFonts.bricolageGrotesque();
  final bodyFont = GoogleFonts.plusJakartaSans();

  final base = ThemeData(
    brightness: c == AppColors.dark ? Brightness.dark : Brightness.light,
    scaffoldBackgroundColor: c.background,
    fontFamily: bodyFont.fontFamily,
    colorScheme: ColorScheme(
      brightness: c == AppColors.dark ? Brightness.dark : Brightness.light,
      primary: c.accent,
      onPrimary: c.accentInk,
      secondary: c.brand,
      onSecondary: c.brandInk,
      surface: c.surface,
      onSurface: c.ink,
      error: c.accent,
      onError: c.accentInk,
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(fontFamily: displayFont.fontFamily, fontWeight: FontWeight.w800, color: c.ink),
      displayMedium: TextStyle(fontFamily: displayFont.fontFamily, fontWeight: FontWeight.w800, color: c.ink),
      headlineLarge: TextStyle(fontFamily: displayFont.fontFamily, fontWeight: FontWeight.w800, color: c.ink),
      headlineMedium: TextStyle(fontFamily: displayFont.fontFamily, fontWeight: FontWeight.w700, color: c.ink),
      bodyLarge: TextStyle(fontFamily: bodyFont.fontFamily, color: c.ink, fontWeight: FontWeight.w600),
      bodyMedium: TextStyle(fontFamily: bodyFont.fontFamily, color: c.inkSoft, fontWeight: FontWeight.w600),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: c.background,
      foregroundColor: c.ink,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: displayFont.fontFamily,
        fontWeight: FontWeight.w800,
        fontSize: 22,
        color: c.ink,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: c.border, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: c.border, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: c.accent, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: c.accent,
        foregroundColor: c.accentInk,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
        textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: c.ink,
        side: BorderSide(color: c.border, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
        textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
    ),
  );

  return base;
}
