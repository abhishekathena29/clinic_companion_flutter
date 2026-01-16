import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';

enum StatVariant { primary, success, warning, info }

enum StatChangeType { positive, negative, neutral }

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.change,
    this.changeType = StatChangeType.neutral,
    this.variant = StatVariant.primary,
  });

  final String title;
  final String value;
  final IconData icon;
  final String? change;
  final StatChangeType changeType;
  final StatVariant variant;

  @override
  Widget build(BuildContext context) {
    final accent = _variantColor(variant);
    final accentBg = accent.withOpacity(0.1);

    return Container(
      decoration: AppDecorations.card(),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(width: 4, color: accent),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(fontSize: 12, color: AppColors.mutedForeground),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        value,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      if (change != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          change!,
                          style: TextStyle(
                            fontSize: 12,
                            color: _changeColor(changeType),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: accent),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _variantColor(StatVariant variant) {
    switch (variant) {
      case StatVariant.success:
        return AppColors.success;
      case StatVariant.warning:
        return AppColors.warning;
      case StatVariant.info:
        return AppColors.info;
      case StatVariant.primary:
      default:
        return AppColors.primary;
    }
  }

  Color _changeColor(StatChangeType type) {
    switch (type) {
      case StatChangeType.positive:
        return AppColors.success;
      case StatChangeType.negative:
        return AppColors.destructive;
      case StatChangeType.neutral:
      default:
        return AppColors.mutedForeground;
    }
  }
}
