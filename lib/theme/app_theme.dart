import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Cortify palette mapped to iOS semantic roles + brand tint.
class CortifyColors {
  static const coral = Color(0xFFE85D4C); // tint
  static const coralSoft = Color(0xFFFF8A7A);
  static const blush = Color(0xFFFFF0ED);
  static const cream = Color(0xFFF2F2F7); // systemGroupedBackground
  static const sand = Color(0xFFE5E5EA);
  static const label = Color(0xFF000000);
  static const charcoal = Color(0xFF1C1C1E); // label
  static const muted = Color(0xFF8E8E93); // secondaryLabel
  static const tertiary = Color(0xFFAEAEB2);
  static const sage = Color(0xFF5B8A7A);
  static const gold = Color(0xFFD4A574);
  static const white = Color(0xFFFFFFFF);
  static const systemBlue = Color(0xFF007AFF);
}

class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      platform: TargetPlatform.iOS,
      colorScheme: ColorScheme.fromSeed(
        seedColor: CortifyColors.coral,
        primary: CortifyColors.coral,
        secondary: CortifyColors.gold,
        surface: CortifyColors.cream,
        onPrimary: CortifyColors.white,
        onSurface: CortifyColors.charcoal,
      ),
      scaffoldBackgroundColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
    );

    // SF Pro–like UI scale (falls back when .SF Pro unavailable).
    final textTheme = base.textTheme.copyWith(
      displayLarge: const TextStyle(
        fontFamily: '.SF Pro Display',
        fontSize: 34,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.37,
        color: CortifyColors.label,
      ),
      headlineMedium: const TextStyle(
        fontFamily: '.SF Pro Display',
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.35,
        color: CortifyColors.label,
      ),
      titleLarge: const TextStyle(
        fontFamily: '.SF Pro Text',
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
        color: CortifyColors.label,
      ),
      titleMedium: const TextStyle(
        fontFamily: '.SF Pro Text',
        fontSize: 17,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.4,
        color: CortifyColors.label,
      ),
      bodyLarge: const TextStyle(
        fontFamily: '.SF Pro Text',
        fontSize: 17,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.4,
        height: 1.29,
        color: CortifyColors.label,
      ),
      bodyMedium: const TextStyle(
        fontFamily: '.SF Pro Text',
        fontSize: 15,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.24,
        color: CortifyColors.label,
      ),
      bodySmall: const TextStyle(
        fontFamily: '.SF Pro Text',
        fontSize: 13,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.08,
        color: CortifyColors.muted,
      ),
      labelLarge: const TextStyle(
        fontFamily: '.SF Pro Text',
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: CortifyColors.coral,
      ),
      labelSmall: const TextStyle(
        fontFamily: '.SF Pro Text',
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.06,
        color: CortifyColors.muted,
      ),
    );

    return base.copyWith(
      textTheme: textTheme,
      cupertinoOverrideTheme: const CupertinoThemeData(
        primaryColor: CortifyColors.coral,
        barBackgroundColor: Color(0x8CFFFFFF),
        scaffoldBackgroundColor: Color(0x00000000),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: CortifyColors.charcoal,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
          color: CortifyColors.label,
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0x33787880),
        thickness: 0.5,
        space: 0.5,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        highlightElevation: 0,
        focusElevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: CortifyColors.charcoal.withValues(alpha: 0.92),
        contentTextStyle: const TextStyle(
          fontFamily: '.SF Pro Text',
          color: Colors.white,
          fontSize: 15,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? Colors.white
              : Colors.white,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? CortifyColors.coral
              : const Color(0xFFE9E9EA),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.45),
        selectedColor: CortifyColors.coral,
        labelStyle: const TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.55),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: CortifyColors.coral, width: 1.5),
        ),
        hintStyle: const TextStyle(
          fontFamily: '.SF Pro Text',
          color: CortifyColors.tertiary,
          fontSize: 17,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CortifyColors.coral,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(44, 50),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: '.SF Pro Text',
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: CortifyColors.coral,
          minimumSize: const Size(44, 44),
          textStyle: const TextStyle(
            fontFamily: '.SF Pro Text',
            fontWeight: FontWeight.w400,
            fontSize: 17,
          ),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: CortifyColors.coral,
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
        minVerticalPadding: 12,
        iconColor: CortifyColors.coral,
        textColor: CortifyColors.label,
      ),
    );
  }
}
