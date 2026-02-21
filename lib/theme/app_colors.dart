import 'package:flutter/material.dart';

Color hslToColor(double h, double s, double l, {double alpha = 1}) {
  final hh = (h % 360) / 360.0;
  final ss = s / 100.0;
  final ll = l / 100.0;

  final c = (1 - (2 * ll - 1).abs()) * ss;
  final x = c * (1 - ((hh * 6) % 2 - 1).abs());
  final m = ll - c / 2;

  double r = 0;
  double g = 0;
  double b = 0;

  if (hh < 1 / 6) {
    r = c;
    g = x;
  } else if (hh < 2 / 6) {
    r = x;
    g = c;
  } else if (hh < 3 / 6) {
    g = c;
    b = x;
  } else if (hh < 4 / 6) {
    g = x;
    b = c;
  } else if (hh < 5 / 6) {
    r = x;
    b = c;
  } else {
    r = c;
    b = x;
  }

  return Color.fromRGBO(
    ((r + m) * 255).round(),
    ((g + m) * 255).round(),
    ((b + m) * 255).round(),
    alpha,
  );
}

class AppColors {
  // Ultra-light, slightly cool background
  static final background = hslToColor(220, 20, 98);
  static final foreground = hslToColor(220, 25, 12);

  // Clean white cards
  static final card = hslToColor(0, 0, 100);
  static final cardForeground = hslToColor(220, 25, 15);

  // Modern vibrant primary (Deep Ocean to Cyan vibe)
  static final primary = hslToColor(225, 80, 55);
  static final primaryForeground = hslToColor(0, 0, 100);
  static final primaryLight = hslToColor(225, 75, 95);

  // Soft secondary surfaces
  static final secondary = hslToColor(220, 25, 93);
  static final secondaryForeground = hslToColor(225, 80, 45);

  // Muted variants
  static final muted = hslToColor(220, 15, 95);
  static final mutedForeground = hslToColor(220, 15, 45);

  // Beautiful energetic accent (Purple)
  static final accent = hslToColor(270, 80, 60);
  static final accentForeground = hslToColor(0, 0, 100);
  static final accentLight = hslToColor(270, 70, 95);

  // State colors - adjusted for premium look
  static final success = hslToColor(150, 70, 45);
  static final successForeground = hslToColor(0, 0, 100);
  static final successLight = hslToColor(150, 60, 95);

  static final warning = hslToColor(35, 95, 55);
  static final warningForeground = hslToColor(35, 100, 15);
  static final warningLight = hslToColor(35, 90, 95);

  static final destructive = hslToColor(350, 80, 60);
  static final destructiveForeground = hslToColor(0, 0, 100);
  static final destructiveLight = hslToColor(350, 70, 96);

  static final info = hslToColor(200, 90, 50);
  static final infoForeground = hslToColor(0, 0, 100);
  static final infoLight = hslToColor(200, 80, 95);

  // Subtle borders
  static final border = hslToColor(220, 20, 91);

  // Sidebar colors - modern dark gradient look
  static final sidebarBackground = hslToColor(225, 40, 15);
  static final sidebarForeground = hslToColor(0, 0, 100);
  static final sidebarAccent = hslToColor(225, 50, 25);
  static final sidebarBorder = hslToColor(225, 30, 20);

  // Larger border radius for friendly aesthetics
  static const borderRadius = 16.0;

  // Premium Gradients
  static final gradientPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [hslToColor(225, 85, 55), hslToColor(205, 95, 50)],
  );

  static final gradientHero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      hslToColor(225, 85, 55),
      hslToColor(270, 80, 60),
    ], // Blue to Purple
  );

  static final gradientDark = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [hslToColor(225, 40, 18), hslToColor(225, 40, 12)],
  );
}
