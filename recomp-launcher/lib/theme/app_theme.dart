import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const background = Color(0xFF07070F);
  static const surface = Color(0xFF0E0E1C);
  static const card = Color(0xFF131328);
  static const cardBorder = Color(0xFF252545);
  static const primary = Color(0xFF00B341);
  static const primaryGlow = Color(0x4400B341);
  static const accent = Color(0xFF107CC4);
  static const accentGlow = Color(0x44107CC4);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF9999BB);
  static const textTertiary = Color(0xFF55557A);
  static const divider = Color(0xFF1A1A30);
  static const error = Color(0xFFFF4455);
  static const warning = Color(0xFFFFAA00);
  static const xboxGreen = Color(0xFF00B341);
  static const navBar = Color(0xFF0A0A18);
}

class AppTheme {
  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.surface,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSurface: AppColors.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.orbitron(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: 1.5,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.navBar,
        indicatorColor: AppColors.primaryGlow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary, size: 24);
          }
          return const IconThemeData(color: AppColors.textTertiary, size: 22);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.exo2(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            );
          }
          return GoogleFonts.exo2(
            fontSize: 11,
            color: AppColors.textTertiary,
          );
        }),
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.cardBorder, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        hintStyle: GoogleFonts.exo2(color: AppColors.textTertiary, fontSize: 14),
        labelStyle: GoogleFonts.exo2(color: AppColors.textSecondary),
      ),
      textTheme: GoogleFonts.exo2TextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.orbitron(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          letterSpacing: 2,
        ),
        displayMedium: GoogleFonts.orbitron(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: 1,
        ),
        titleLarge: GoogleFonts.orbitron(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: 0.5,
        ),
        titleMedium: GoogleFonts.exo2(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.exo2(
          fontSize: 15,
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.exo2(
          fontSize: 13,
          color: AppColors.textSecondary,
        ),
        bodySmall: GoogleFonts.exo2(
          fontSize: 11,
          color: AppColors.textTertiary,
        ),
        labelLarge: GoogleFonts.exo2(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
