import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';

class AlertsPanel extends StatelessWidget {
  const AlertsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final alerts = [
      {
        'id': '1',
        'type': 'critical',
        'message': 'High BP reading needs review',
        'patientName': 'Ramesh Gupta',
        'time': '2 hours ago',
      },
      {
        'id': '2',
        'type': 'overdue',
        'message': 'Missed diabetes follow-up',
        'patientName': 'Sunita Devi',
        'time': '3 days overdue',
      },
      {
        'id': '3',
        'type': 'medication',
        'message': 'Prescription refill needed',
        'patientName': 'Amit Patel',
        'time': 'Due tomorrow',
      },
      {
        'id': '4',
        'type': 'report',
        'message': 'Lab results pending review',
        'patientName': 'Priya Sharma',
        'time': '1 day ago',
      },
    ];

    return Container(
      decoration: AppDecorations.card(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Alerts',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.destructive,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${alerts.length}',
                    style: TextStyle(fontSize: 11, color: AppColors.destructiveForeground),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: alerts.map((alert) {
                final style = _alertStyle(alert['type'] as String);
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: style.background,
                    borderRadius: BorderRadius.circular(AppColors.borderRadius),
                    border: Border.all(color: style.border),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(style.icon, size: 18, color: style.foreground),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              alert['patientName'] as String,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              alert['message'] as String,
                              style: TextStyle(fontSize: 12, color: AppColors.foreground.withOpacity(0.8)),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              alert['time'] as String,
                              style: TextStyle(fontSize: 11, color: AppColors.foreground.withOpacity(0.6)),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.close, size: 16, color: AppColors.foreground.withOpacity(0.5)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),
          TextButton(
            onPressed: () {},
            child: Text(
              'View All Alerts ->',
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertStyle {
  const _AlertStyle({
    required this.icon,
    required this.background,
    required this.foreground,
    required this.border,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
  final Color border;
}

_AlertStyle _alertStyle(String type) {
  switch (type) {
    case 'critical':
      return _AlertStyle(
        icon: Icons.warning,
        background: AppColors.destructive.withOpacity(0.1),
        foreground: AppColors.destructive,
        border: AppColors.destructive.withOpacity(0.2),
      );
    case 'overdue':
      return _AlertStyle(
        icon: Icons.event,
        background: AppColors.warning.withOpacity(0.1),
        foreground: AppColors.warning,
        border: AppColors.warning.withOpacity(0.2),
      );
    case 'medication':
      return _AlertStyle(
        icon: Icons.medication,
        background: AppColors.info.withOpacity(0.1),
        foreground: AppColors.info,
        border: AppColors.info.withOpacity(0.2),
      );
    case 'report':
    default:
      return _AlertStyle(
        icon: Icons.description,
        background: AppColors.primary.withOpacity(0.1),
        foreground: AppColors.primary,
        border: AppColors.primary.withOpacity(0.2),
      );
  }
}
