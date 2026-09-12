import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppBottomNavItem {
  const AppBottomNavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// A floating, pill-highlighted bottom navigation bar matching the
/// Medi-Connect visual language: a rounded card raised above the content
/// with the active tab shown inside a filled teal pill.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<AppBottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final isActive = index == currentIndex;
              final item = items[index];
              return _NavIcon(
                item: item,
                isActive: isActive,
                onTap: () => onTap(index),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  final AppBottomNavItem item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              size: 22,
              color: isActive ? Colors.white : AppColors.mutedForeground,
            ),
            if (isActive) ...[
              const SizedBox(width: 8),
              Text(
                item.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
