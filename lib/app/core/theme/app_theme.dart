import 'package:flutter/material.dart';

import 'app_colors.dart';

/// The website uses `--radius: 0.75rem`, so 12 is the base corner radius here.
const double kRadius = 12;

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(
        brightness: Brightness.light,
        primary: AppColors.primary,
        background: AppColors.background,
        surface: AppColors.surface,
        foreground: AppColors.foreground,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        muted: AppColors.muted,
        mutedForeground: AppColors.mutedForeground,
        border: AppColors.border,
        destructive: AppColors.destructive,
      );

  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        primary: AppColors.primaryDark,
        background: AppColors.backgroundDark,
        surface: AppColors.surfaceDark,
        foreground: AppColors.foregroundDark,
        secondary: AppColors.secondaryDark,
        onSecondary: AppColors.onSecondaryDark,
        muted: AppColors.mutedDark,
        mutedForeground: AppColors.mutedForegroundDark,
        border: AppColors.borderDark,
        destructive: AppColors.destructiveDark,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color primary,
    required Color background,
    required Color surface,
    required Color foreground,
    required Color secondary,
    required Color onSecondary,
    required Color muted,
    required Color mutedForeground,
    required Color border,
    required Color destructive,
  }) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: AppColors.onPrimary,
      secondary: secondary,
      onSecondary: onSecondary,
      error: destructive,
      onError: AppColors.onPrimary,
      surface: surface,
      onSurface: foreground,
      surfaceContainerHighest: muted,
      onSurfaceVariant: mutedForeground,
      outline: border,
    );

    final radius = BorderRadius.circular(kRadius);

    OutlineInputBorder inputBorder(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: color, width: width),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      dividerColor: border,
      splashFactory: InkSparkle.splashFactory,

      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: foreground,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: foreground,
          fontSize: 19,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
      ),

      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: border),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: AppColors.onPrimary,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: radius),
          textStyle: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: foreground,
          minimumSize: const Size.fromHeight(52),
          side: BorderSide(color: border),
          shape: RoundedRectangleBorder(borderRadius: radius),
          textStyle: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        border: inputBorder(border),
        enabledBorder: inputBorder(border),
        focusedBorder: inputBorder(primary, 1.6),
        errorBorder: inputBorder(destructive),
        focusedErrorBorder: inputBorder(destructive, 1.6),
        hintStyle: TextStyle(color: mutedForeground, fontSize: 14.5),
        labelStyle: TextStyle(color: mutedForeground, fontSize: 14.5),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: foreground,
        contentTextStyle: TextStyle(color: background, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: radius),
      ),

      textTheme: TextTheme(
        headlineLarge: TextStyle(
          color: foreground,
          fontSize: 30,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.8,
          height: 1.15,
        ),
        headlineMedium: TextStyle(
          color: foreground,
          fontSize: 23,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        titleMedium: TextStyle(
          color: foreground,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: foreground, fontSize: 15.5, height: 1.45),
        bodyMedium: TextStyle(color: foreground, fontSize: 14.5, height: 1.45),
        bodySmall: TextStyle(color: mutedForeground, fontSize: 13, height: 1.4),
        labelLarge: TextStyle(color: foreground, fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }
}
