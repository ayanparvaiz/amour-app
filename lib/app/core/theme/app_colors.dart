import 'package:flutter/material.dart';

/// Palette carried over from the web app's design tokens in `src/index.css`,
/// converted from HSL. Keep these in sync if the website's tokens change.
///
/// The website's own dark theme is the untouched shadcn default (its `--primary`
/// turns near-white), which reads as a bug rather than a design. The dark values
/// below keep the rose accent instead, lifted for contrast on a dark ground.
class AppColors {
  AppColors._();

  // --- Brand -------------------------------------------------------------
  /// hsl(350 80% 60%) — the rose the whole product is built around.
  static const Color primary = Color(0xFFEB4763);
  static const Color primaryDark = Color(0xFFFF7387);
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// Second stop of `--gradient-hero`, hsl(20 90% 65%).
  static const Color heroGradientEnd = Color(0xFFF68B55);

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, heroGradientEnd],
  );

  // --- Light -------------------------------------------------------------
  static const Color background = Color(0xFFFCFCFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color foreground = Color(0xFF17171C);
  static const Color secondary = Color(0xFFF6EEF0);
  static const Color onSecondary = Color(0xFFB81F3D);
  static const Color muted = Color(0xFFF4F4F5);
  static const Color mutedForeground = Color(0xFF6D6D79);
  static const Color border = Color(0xFFE4E4E7);
  static const Color destructive = Color(0xFFEF4343);

  // --- Dark --------------------------------------------------------------
  static const Color backgroundDark = Color(0xFF121013);
  static const Color surfaceDark = Color(0xFF1C181A);
  static const Color foregroundDark = Color(0xFFF3EDEF);
  static const Color secondaryDark = Color(0xFF3A1F26);
  static const Color onSecondaryDark = Color(0xFFFFA9B6);
  static const Color mutedDark = Color(0xFF262023);
  static const Color mutedForegroundDark = Color(0xFF9A8D92);
  static const Color borderDark = Color(0xFF352D31);
  static const Color destructiveDark = Color(0xFFFF7B6B);

  // --- Status ------------------------------------------------------------
  /// Presence dot in the conversation list, matching the web app's green.
  static const Color online = Color(0xFF22C55E);
}
