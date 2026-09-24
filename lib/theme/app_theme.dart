import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Warm Cortis-inspired palette — coral heart, soft cream, deep charcoal.
/// Tuned for glass panels: ink stays dark enough on frosted fills.
class CortifyColors {
  static const coral = Color(0xFFE85D4C);
  static const coralSoft = Color(0xFFFF8A7A);
  static const blush = Color(0xFFFFF0ED);
  static const cream = Color(0xFFFFF8F5);
  static const sand = Color(0xFFF5E6E0);
  static const charcoal = Color(0xFF2C2422);
  /// Secondary text — warmer + darker for ≥4.5:1 on glass.
  static const muted = Color(0xFF6B5650);
  static const sage = Color(0xFF5B8A7A);
  static const gold = Color(0xFFD4A574);
  static const white = Color(0xFFFFFFFF);
}

class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: CortifyColors.coral,
        primary: CortifyColors.coral,
        secondary: CortifyColors.gold,
        surface: CortifyColors.cream,
        onPrimary: CortifyColors.white,
        onSurface: CortifyColors.charcoal,
      ),
      scaffoldBackgroundColor: Colors.transparent,
    );

    return base.copyWith(
      textTheme: GoogleFonts.dmSansTextTheme(base.textTheme).apply(
        bodyColor: CortifyColors.charcoal,
        displayColor: CortifyColors.charcoal,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: CortifyColors.charcoal,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: GoogleFonts.fraunces(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: CortifyColors.charcoal,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: 0.72),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.85)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: CortifyColors.sand.withValues(alpha: 0.8),
        thickness: 1,
        space: 1,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: CortifyColors.coral,
        foregroundColor: CortifyColors.white,
        elevation: 4,
        focusElevation: 6,
        highlightElevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: CortifyColors.charcoal,
        contentTextStyle: GoogleFonts.dmSans(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: CortifyColors.coral,
        unselectedItemColor: CortifyColors.muted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.55),
        selectedColor: CortifyColors.coral,
        labelStyle: GoogleFonts.dmSans(fontSize: 13),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.7)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.75),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.9)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.9)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: CortifyColors.coral, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CortifyColors.coral,
          foregroundColor: CortifyColors.white,
          elevation: 0,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.dmSans(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: CortifyColors.coral,
          minimumSize: const Size(48, 40),
          textStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: CortifyColors.coral,
      ),
    );
  }
}
