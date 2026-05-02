import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const background = Color(0xFF0D0F1A);
  static const card = Color(0xFF161929);
  static const cardElevated = Color(0xFF1C2035);
  static const primary = Color(0xFF00E5C3);
  static const primaryFg = Color(0xFF0D0F1A);
  static const secondary = Color(0xFF6C63FF);
  static const warning = Color(0xFFFF8C42);
  static const danger = Color(0xFFFF4D6D);
  static const success = Color(0xFF00D68F);
  static const textPrimary = Color(0xFFF0F4FF);
  static const textMuted = Color(0xFF4A5480);
  static const muted = Color(0xFF1C2035);
  static const border = Color(0xFF1E2540);
}

class AppRankColors {
  static const wanderer = Color(0xFF4A5480);
  static const seeker = Color(0xFF6C63FF);
  static const apprentice = Color(0xFF00E5C3);
  static const guardian = Color(0xFF00D68F);
  static const sage = Color(0xFFFF8C42);
  static const mindMaster = Color(0xFFFFD700);
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      surface: AppColors.card,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      error: AppColors.danger,
      onPrimary: AppColors.primaryFg,
      onSurface: AppColors.textPrimary,
    ),
    textTheme: GoogleFonts.interTextTheme(
      ThemeData.dark().textTheme,
    ).apply(
        bodyColor: AppColors.textPrimary, displayColor: AppColors.textPrimary),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.card,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    cardTheme: CardTheme(
    color: AppColors.card,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    dividerColor: AppColors.border,
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith(
        (s) => s.contains(MaterialState.selected)
            ? AppColors.primary
            : AppColors.textMuted,
      ),
      trackColor: MaterialStateProperty.resolveWith(
        (s) => s.contains(MaterialState.selected)
            ? AppColors.primary.withAlpha(77)
            : AppColors.muted,
      ),
    ),
  );
}
