import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Central theme definition. Light and dark are designed as distinct,
/// intentional palettes (§31) rather than one inverted the other.
class AppTheme {
  AppTheme._();

  static const double cardRadius = 20;
  static const double fieldRadius = 14;

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      surface: AppColors.lightSurface,
    ).copyWith(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.lightSurface,
    );

    return _base(
      colorScheme: colorScheme,
      scaffoldBackground: AppColors.lightBackground,
      cardColor: AppColors.lightSurface,
      borderColor: AppColors.lightBorder,
      textPrimary: AppColors.lightTextPrimary,
      textSecondary: AppColors.lightTextSecondary,
      brightness: Brightness.light,
    );
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaryDark,
      brightness: Brightness.dark,
      surface: AppColors.darkSurface,
    ).copyWith(
      primary: AppColors.primaryDark,
      secondary: AppColors.accent,
      surface: AppColors.darkSurface,
    );

    return _base(
      colorScheme: colorScheme,
      scaffoldBackground: AppColors.darkBackground,
      cardColor: AppColors.darkSurface,
      borderColor: AppColors.darkBorder,
      textPrimary: AppColors.darkTextPrimary,
      textSecondary: AppColors.darkTextSecondary,
      brightness: Brightness.dark,
    );
  }

  static ThemeData _base({
    required ColorScheme colorScheme,
    required Color scaffoldBackground,
    required Color cardColor,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
    required Brightness brightness,
  }) {
    final textTheme = _textTheme(textPrimary, textSecondary);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackground,
      textTheme: textTheme,
      splashFactory: InkRipple.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBackground,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: textTheme.headlineSmall,
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: BorderSide(color: borderColor, width: 1),
        ),
      ),
      dividerTheme: DividerThemeData(color: borderColor, thickness: 1, space: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(fieldRadius),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(fieldRadius),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(fieldRadius),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.6),
        ),
        labelStyle: TextStyle(color: textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(fieldRadius)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          minimumSize: const Size.fromHeight(52),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: BorderSide(color: borderColor),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(fieldRadius)),
          minimumSize: const Size.fromHeight(52),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cardColor,
        elevation: 0,
        height: 68,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.14),
        labelTextStyle: WidgetStatePropertyAll(
          textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scaffoldBackground,
        side: BorderSide(color: borderColor),
        labelStyle: TextStyle(color: textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: textSecondary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cardColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimary,
        contentTextStyle: TextStyle(color: scaffoldBackground),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static TextTheme _textTheme(Color primary, Color secondary) {
    return TextTheme(
      displayLarge: TextStyle(fontSize: 44, fontWeight: FontWeight.w700, color: primary, letterSpacing: -0.5),
      displayMedium: TextStyle(fontSize: 34, fontWeight: FontWeight.w700, color: primary, letterSpacing: -0.5),
      headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: primary),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: primary),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: primary),
      titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: primary),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: primary),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: primary),
      bodySmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: secondary),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: primary),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: secondary),
    );
  }
}
