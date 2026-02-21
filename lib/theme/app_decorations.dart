import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppDecorations {
  static BoxDecoration card({
    Color? color,
    BorderRadius? radius,
    bool isHovered = false,
  }) {
    return BoxDecoration(
      color: color ?? AppColors.card,
      borderRadius: radius ?? BorderRadius.circular(AppColors.borderRadius),
      border: Border.all(color: AppColors.border.withOpacity(0.6)),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withOpacity(isHovered ? 0.12 : 0.04),
          blurRadius: isHovered ? 24 : 12,
          offset: isHovered ? const Offset(0, 8) : const Offset(0, 4),
          spreadRadius: isHovered ? 2 : 0,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.02),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  static BoxDecoration glass({Color? color, BorderRadius? radius}) {
    return BoxDecoration(
      color: (color ?? Colors.white).withOpacity(0.7),
      borderRadius: radius ?? BorderRadius.circular(AppColors.borderRadius),
      border: Border.all(color: Colors.white.withOpacity(0.5)),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.05),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
