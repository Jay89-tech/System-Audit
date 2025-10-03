import 'package:flutter/material.dart';

/// Corporate Color Palette for Skills Audit System
class AppColors {
  // Primary Brand Colors
  static const Color softGrey = Color(0xFFD3D3D3);
  static const Color white = Color(0xFFFFFFFF);
  static const Color darkGrey = Color(0xFF333333);
  static const Color black = Color(0xFF000000);
  static const Color deepBlue = Color(0xFF1E3A8A);

  // Additional UI Colors
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color mediumGrey = Color(0xFF666666);
  static const Color blueAccent = Color(0xFF3B82F6);
  static const Color errorRed = Color(0xFFDC2626);
  static const Color successGreen = Color(0xFF16A34A);
  static const Color warningOrange = Color(0xFFEA580C);

  // Status Colors
  static const Color pendingColor = Color(0xFFEA580C); // Orange
  static const Color approvedColor = Color(0xFF16A34A); // Green
  static const Color rejectedColor = Color(0xFFDC2626); // Red
  static const Color inProgressColor = Color(0xFF3B82F6); // Blue
  static const Color completedColor = Color(0xFF16A34A); // Green
  static const Color notStartedColor = Color(0xFF666666); // Grey

  // Skill Level Colors
  static const Color beginnerColor = Color(0xFF94A3B8);
  static const Color intermediateColor = Color(0xFF3B82F6);
  static const Color advancedColor = Color(0xFF8B5CF6);
  static const Color expertColor = Color(0xFF10B981);

  // Background Colors
  static const Color scaffoldBackground = Color(0xFFF5F5F5);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color appBarBackground = Color(0xFFFFFFFF);

  // Text Colors
  static const Color primaryText = Color(0xFF333333);
  static const Color secondaryText = Color(0xFF666666);
  static const Color hintText = Color(0xFF999999);
  static const Color disabledText = Color(0xFFCCCCCC);

  // Border Colors
  static const Color borderLight = Color(0xFFE5E5E5);
  static const Color borderMedium = Color(0xFFD3D3D3);
  static const Color borderDark = Color(0xFF999999);

  // Shadow Colors
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowMedium = Color(0x33000000);
  static const Color shadowDark = Color(0x4D000000);

  // Overlay Colors
  static const Color overlayLight = Color(0x80000000);
  static const Color overlayDark = Color(0xCC000000);

  // Gradient Colors
  static List<Color> get primaryGradient => [
        deepBlue,
        blueAccent,
      ];

  static List<Color> get successGradient => [
        successGreen,
        Color(0xFF22C55E),
      ];

  static List<Color> get warningGradient => [
        warningOrange,
        Color(0xFFF97316),
      ];

  static List<Color> get errorGradient => [
        errorRed,
        Color(0xFFEF4444),
      ];

  // Transparent variants
  static Color get deepBlueTransparent => deepBlue.withOpacity(0.1);
  static Color get errorRedTransparent => errorRed.withOpacity(0.1);
  static Color get successGreenTransparent => successGreen.withOpacity(0.1);
  static Color get warningOrangeTransparent => warningOrange.withOpacity(0.1);

  // Chart Colors
  static const List<Color> chartColors = [
    Color(0xFF1E3A8A), // Deep Blue
    Color(0xFF3B82F6), // Blue Accent
    Color(0xFF16A34A), // Green
    Color(0xFFEA580C), // Orange
    Color(0xFFDC2626), // Red
    Color(0xFF8B5CF6), // Purple
    Color(0xFF06B6D4), // Cyan
    Color(0xFFF59E0B), // Amber
  ];

  // Get color by status
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return pendingColor;
      case 'approved':
        return approvedColor;
      case 'rejected':
        return rejectedColor;
      case 'in progress':
      case 'inprogress':
        return inProgressColor;
      case 'completed':
        return completedColor;
      case 'not started':
      case 'notstarted':
        return notStartedColor;
      default:
        return mediumGrey;
    }
  }

  // Get color by skill level
  static Color getSkillLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return beginnerColor;
      case 'intermediate':
        return intermediateColor;
      case 'advanced':
        return advancedColor;
      case 'expert':
        return expertColor;
      default:
        return mediumGrey;
    }
  }

  // Private constructor to prevent instantiation
  AppColors._();
}

/// Material Color Swatches
class AppColorSwatches {
  static const MaterialColor deepBlueSwatch = MaterialColor(
    0xFF1E3A8A,
    <int, Color>{
      50: Color(0xFFE3E8F4),
      100: Color(0xFFB9C6E4),
      200: Color(0xFF8BA0D3),
      300: Color(0xFF5D7AC2),
      400: Color(0xFF3A5EB5),
      500: Color(0xFF1E3A8A),
      600: Color(0xFF1A3482),
      700: Color(0xFF162C77),
      800: Color(0xFF12256D),
      900: Color(0xFF0A1854),
    },
  );

  static const MaterialColor successGreenSwatch = MaterialColor(
    0xFF16A34A,
    <int, Color>{
      50: Color(0xFFE6F7EC),
      100: Color(0xFFC0EBD0),
      200: Color(0xFF96DEB1),
      300: Color(0xFF6CD192),
      400: Color(0xFF4DC77A),
      500: Color(0xFF16A34A),
      600: Color(0xFF139B43),
      700: Color(0xFF10913A),
      800: Color(0xFF0C8832),
      900: Color(0xFF067722),
    },
  );
}

/// Extension methods for Color manipulation
extension ColorExtensions on Color {
  /// Lighten the color
  Color lighten([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  /// Darken the color
  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  /// Make the color more saturated
  Color saturate([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final saturation = (hsl.saturation + amount).clamp(0.0, 1.0);
    return hsl.withSaturation(saturation).toColor();
  }

  /// Make the color less saturated
  Color desaturate([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final saturation = (hsl.saturation - amount).clamp(0.0, 1.0);
    return hsl.withSaturation(saturation).toColor();
  }

  /// Convert to hex string
  String toHex() {
    return '#${value.toRadixString(16).substring(2).toUpperCase()}';
  }
}
