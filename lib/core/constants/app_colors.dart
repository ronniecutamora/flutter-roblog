import 'package:flutter/material.dart';

/// Centralized color constants for the Roblog application.
///
/// Usage:
/// ```dart
/// Container(color: AppColors.primary)
/// ```
///
/// Benefits:
/// - Consistent colors across the app
/// - Easy theme changes in one place
/// - Supports adding dark mode later
class AppColors {
  AppColors._(); // Private constructor

  // ─── Primary ────────────────────────────────────────────────────────────────
  
  /// Primary brand color - used for app bar, buttons, links.
  static const Color primary = Color(0xFF6200EE);
  
  /// Darker variant of primary for pressed states.
  static const Color primaryDark = Color(0xFF3700B3);
  
  /// Lighter variant of primary for backgrounds.
  static const Color primaryLight = Color(0xFFBB86FC);

  // ─── Secondary ──────────────────────────────────────────────────────────────
  
  /// Secondary accent color for FABs, highlights.
  static const Color secondary = Color(0xFF03DAC6);
  
  /// Darker variant of secondary.
  static const Color secondaryDark = Color(0xFF018786);

  // ─── Neutral ────────────────────────────────────────────────────────────────
  
  /// Background color for scaffolds.
  static const Color background = Color(0xFFF5F5F5);
  
  /// Surface color for cards, dialogs.
  static const Color surface = Color(0xFFFFFFFF);
  
  /// Primary text color.
  static const Color textPrimary = Color(0xFF212121);
  
  /// Secondary/hint text color.
  static const Color textSecondary = Color(0xFF757575);

  // ─── Status ─────────────────────────────────────────────────────────────────
  
  /// Error color for validation, destructive actions.
  static const Color error = Color(0xFFB00020);
  
  /// Success color for confirmations.
  static const Color success = Color(0xFF4CAF50);
  
  /// Warning color for alerts.
  static const Color warning = Color(0xFFFFC107);
}
