import 'package:flutter/material.dart';

/// Brand palette. Deliberately steers away from a "gym/bodybuilding" red-
/// and-black look — MeasureMe is about precision and personal organization
/// across body, clothing, and shoe sizing, not just training (§2).
class AppColors {
  AppColors._();

  // Primary: a calm, precise teal — reads as "health + measurement",
  // not "workout app".
  static const Color primary = Color(0xFF0E7C7B);
  static const Color primaryDark = Color(0xFF57C4C0);

  // Secondary: a warm brass/gold accent, evoking a tape measure's metal
  // tip — used sparingly for highlights, not as a dominant color.
  static const Color accent = Color(0xFFC9962E);

  static const Color lightBackground = Color(0xFFFAFAF8);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE7E5E0);
  static const Color lightTextPrimary = Color(0xFF1B1C1D);
  static const Color lightTextSecondary = Color(0xFF6B6F72);

  static const Color darkBackground = Color(0xFF121415);
  static const Color darkSurface = Color(0xFF1C1F20);
  static const Color darkBorder = Color(0xFF2E3234);
  static const Color darkTextPrimary = Color(0xFFF2F3F2);
  static const Color darkTextSecondary = Color(0xFFA3A8AA);

  // Neutral trend colors. Direction is shown with an icon + color as a
  // secondary cue, never as the only signal (§8, §30 accessibility).
  static const Color trendUp = Color(0xFF2E7D6B);
  static const Color trendDown = Color(0xFFB6562C);
  static const Color trendStable = Color(0xFF8A8D8F);
}
