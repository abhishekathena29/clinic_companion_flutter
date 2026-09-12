import 'package:flutter/material.dart';

import '../shared/appointments_repository.dart';
import '../theme/app_colors.dart';

/// A simple two-way "In person / Video call" selector used in booking and
/// scheduling dialogs.
class ConsultationModeToggle extends StatelessWidget {
  const ConsultationModeToggle({
    super.key,
    required this.mode,
    required this.onChanged,
  });

  final String mode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ModeChip(
            label: 'In person',
            icon: Icons.storefront_rounded,
            isActive: mode == kConsultationInPerson,
            onTap: () => onChanged(kConsultationInPerson),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ModeChip(
            label: 'Video call',
            icon: Icons.video_call_rounded,
            isActive: mode == kConsultationVideo,
            onTap: () => onChanged(kConsultationVideo),
          ),
        ),
      ],
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryLight : AppColors.muted,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? AppColors.primary : AppColors.mutedForeground,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: isActive
                    ? AppColors.primary
                    : AppColors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
