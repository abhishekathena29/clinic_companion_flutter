import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppDecorations {
  static BoxDecoration card({Color? color, BorderRadius? radius}) {
    return BoxDecoration(
      color: color ?? AppColors.card,
      borderRadius: radius ?? BorderRadius.circular(AppColors.borderRadius),
      border: Border.all(color: AppColors.border),
      boxShadow: const [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.08),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.04),
          blurRadius: 3,
          offset: Offset(0, 1),
        ),
      ],
    );
  }
}
