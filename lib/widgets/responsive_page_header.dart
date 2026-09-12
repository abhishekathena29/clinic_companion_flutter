import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A page header with a title/subtitle block on the left and a row of
/// action buttons on the right. On wide layouts the two sit side by side
/// (title flexes, actions keep their natural size); below [breakpoint] the
/// actions drop to a new line instead of overflowing.
class ResponsivePageHeader extends StatelessWidget {
  const ResponsivePageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    this.breakpoint = 640,
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final double breakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final titleBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.mutedForeground,
                  fontSize: 16,
                ),
              ),
            ],
          ],
        );

        if (actions.isEmpty) return titleBlock;

        final actionsRow = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < actions.length; i++) ...[
              if (i > 0) const SizedBox(width: 16),
              actions[i],
            ],
          ],
        );

        if (constraints.maxWidth >= breakpoint) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: titleBlock),
              const SizedBox(width: 16),
              actionsRow,
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [titleBlock, const SizedBox(height: 16), actionsRow],
        );
      },
    );
  }
}
