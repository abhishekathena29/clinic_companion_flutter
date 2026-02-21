import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum AppButtonVariant { primary, outline, ghost, destructive }

enum AppButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;

  @override
  Widget build(BuildContext context) {
    final vertical = size == AppButtonSize.small
        ? 10.0
        : size == AppButtonSize.large
        ? 18.0
        : 14.0;
    final horizontal = size == AppButtonSize.small
        ? 16.0
        : size == AppButtonSize.large
        ? 32.0
        : 24.0;
    final fontSize = size == AppButtonSize.small
        ? 14.0
        : size == AppButtonSize.large
        ? 18.0
        : 16.0;
    final radius = BorderRadius.circular(AppColors.borderRadius);

    ButtonStyle style;
    switch (variant) {
      case AppButtonVariant.outline:
        style =
            OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(
                color: AppColors.primary.withOpacity(0.3),
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(borderRadius: radius),
              padding: EdgeInsets.symmetric(
                horizontal: horizontal,
                vertical: vertical,
              ),
              textStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
                letterSpacing: 0.3,
              ),
            ).copyWith(
              overlayColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.hovered))
                  return AppColors.primary.withOpacity(0.05);
                if (states.contains(WidgetState.pressed))
                  return AppColors.primary.withOpacity(0.1);
                return null;
              }),
            );
        return OutlinedButton(
          onPressed: onPressed,
          style: style,
          child: _buildContent(),
        );
      case AppButtonVariant.ghost:
        style =
            TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: radius),
              padding: EdgeInsets.symmetric(
                horizontal: horizontal,
                vertical: vertical,
              ),
              textStyle: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: fontSize,
                letterSpacing: 0.3,
              ),
            ).copyWith(
              overlayColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.hovered))
                  return AppColors.primary.withOpacity(0.08);
                if (states.contains(WidgetState.pressed))
                  return AppColors.primary.withOpacity(0.15);
                return null;
              }),
            );
        return TextButton(
          onPressed: onPressed,
          style: style,
          child: _buildContent(),
        );
      case AppButtonVariant.destructive:
        style =
            ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: AppColors.destructive,
              foregroundColor: AppColors.destructiveForeground,
              shape: RoundedRectangleBorder(borderRadius: radius),
              padding: EdgeInsets.symmetric(
                horizontal: horizontal,
                vertical: vertical,
              ),
              textStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
                letterSpacing: 0.3,
              ),
            ).copyWith(
              elevation: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.hovered)) return 6.0;
                return 0.0;
              }),
              shadowColor: WidgetStateProperty.all(
                AppColors.destructive.withOpacity(0.5),
              ),
            );
        return ElevatedButton(
          onPressed: onPressed,
          style: style,
          child: _buildContent(),
        );
      case AppButtonVariant.primary:
      default:
        style =
            ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.primaryForeground,
              shape: RoundedRectangleBorder(borderRadius: radius),
              padding: EdgeInsets.symmetric(
                horizontal: horizontal,
                vertical: vertical,
              ),
              textStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
                letterSpacing: 0.3,
              ),
            ).copyWith(
              elevation: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.hovered)) return 8.0;
                return 0.0;
              }),
              shadowColor: WidgetStateProperty.all(
                AppColors.primary.withOpacity(0.5),
              ),
            );
        return ElevatedButton(
          onPressed: onPressed,
          style: style,
          child: _buildContent(),
        );
    }
  }

  Widget _buildContent() {
    final iconSize = size == AppButtonSize.small
        ? 16.0
        : size == AppButtonSize.large
        ? 22.0
        : 18.0;
    if (label.isEmpty && icon != null) {
      return Icon(icon, size: iconSize);
    }
    if (icon == null) {
      return Text(label);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: iconSize),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}
