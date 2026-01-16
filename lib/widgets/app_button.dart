import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum AppButtonVariant { primary, outline, ghost, destructive }

enum AppButtonSize { small, medium }

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
    final vertical = size == AppButtonSize.small ? 8.0 : 10.0;
    final horizontal = size == AppButtonSize.small ? 12.0 : 16.0;
    final radius = BorderRadius.circular(AppColors.borderRadius - 2);

    ButtonStyle style;
    switch (variant) {
      case AppButtonVariant.outline:
        style = OutlinedButton.styleFrom(
          foregroundColor: AppColors.foreground,
          side: BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(borderRadius: radius),
          padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
        );
        return OutlinedButton(
          onPressed: onPressed,
          style: style,
          child: _buildContent(),
        );
      case AppButtonVariant.ghost:
        style = TextButton.styleFrom(
          foregroundColor: AppColors.foreground,
          shape: RoundedRectangleBorder(borderRadius: radius),
          padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
        );
        return TextButton(
          onPressed: onPressed,
          style: style,
          child: _buildContent(),
        );
      case AppButtonVariant.destructive:
        style = ElevatedButton.styleFrom(
          backgroundColor: AppColors.destructive,
          foregroundColor: AppColors.destructiveForeground,
          shape: RoundedRectangleBorder(borderRadius: radius),
          padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
        );
        return ElevatedButton(
          onPressed: onPressed,
          style: style,
          child: _buildContent(),
        );
      case AppButtonVariant.primary:
      default:
        style = ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.primaryForeground,
          shape: RoundedRectangleBorder(borderRadius: radius),
          padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
        );
        return ElevatedButton(
          onPressed: onPressed,
          style: style,
          child: _buildContent(),
        );
    }
  }

  Widget _buildContent() {
    if (label.isEmpty && icon != null) {
      return Icon(icon, size: 16);
    }
    if (icon == null) {
      return Text(label, style: const TextStyle(fontWeight: FontWeight.w600));
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
