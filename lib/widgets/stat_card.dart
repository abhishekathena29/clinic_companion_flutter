import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';

enum StatVariant { primary, success, warning, info, destructive }

enum StatChangeType { positive, negative, neutral }

class StatCard extends StatefulWidget {
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
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final accent = _variantColor(widget.variant);
    final accentBg = accent.withOpacity(0.12);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -6.0 : 0.0),
        decoration: AppDecorations.card(isHovered: _isHovered),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 6,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppColors.borderRadius),
                    bottomLeft: Radius.circular(AppColors.borderRadius),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.mutedForeground,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.value,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        if (widget.change != null) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(
                                _changeIcon(widget.changeType),
                                size: 16,
                                color: _changeColor(widget.changeType),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  widget.change!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: _changeColor(widget.changeType),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _isHovered ? accent : accentBg,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: _isHovered
                          ? [
                              BoxShadow(
                                color: accent.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Icon(
                      widget.icon,
                      size: 24,
                      color: _isHovered ? Colors.white : accent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
      case StatVariant.destructive:
        return AppColors.destructive;
      case StatVariant.primary:
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
        return AppColors.mutedForeground;
    }
  }

  IconData _changeIcon(StatChangeType type) {
    switch (type) {
      case StatChangeType.positive:
        return Icons.trending_up;
      case StatChangeType.negative:
        return Icons.trending_down;
      case StatChangeType.neutral:
        return Icons.trending_flat;
    }
  }
}
