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
  static final background = hslToColor(210, 20, 98);
  static final foreground = hslToColor(215, 25, 15);

  static final card = hslToColor(0, 0, 100);
  static final cardForeground = hslToColor(215, 25, 15);

  static final primary = hslToColor(175, 70, 35);
  static final primaryForeground = hslToColor(0, 0, 100);
  static final primaryLight = hslToColor(175, 60, 95);

  static final secondary = hslToColor(210, 20, 96);
  static final secondaryForeground = hslToColor(215, 25, 25);

  static final muted = hslToColor(210, 15, 94);
  static final mutedForeground = hslToColor(215, 15, 50);

  static final accent = hslToColor(38, 95, 55);
  static final accentForeground = hslToColor(38, 100, 15);
  static final accentLight = hslToColor(38, 90, 95);

  static final success = hslToColor(150, 60, 40);
  static final successForeground = hslToColor(0, 0, 100);
  static final successLight = hslToColor(150, 50, 95);

  static final warning = hslToColor(38, 95, 55);
  static final warningForeground = hslToColor(38, 100, 15);
  static final warningLight = hslToColor(38, 90, 95);

  static final destructive = hslToColor(0, 70, 55);
  static final destructiveForeground = hslToColor(0, 0, 100);
  static final destructiveLight = hslToColor(0, 60, 97);

  static final info = hslToColor(205, 85, 50);
  static final infoForeground = hslToColor(0, 0, 100);
  static final infoLight = hslToColor(205, 80, 96);

  static final border = hslToColor(210, 20, 90);

  static final sidebarBackground = hslToColor(175, 70, 35);
  static final sidebarForeground = hslToColor(0, 0, 100);
  static final sidebarAccent = hslToColor(175, 60, 40);
  static final sidebarBorder = hslToColor(175, 60, 30);

  static const borderRadius = 12.0;

  static final gradientPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [hslToColor(175, 70, 35), hslToColor(175, 70, 45)],
  );

  static final gradientHero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [hslToColor(175, 70, 35), hslToColor(190, 70, 40)],
  );
}
