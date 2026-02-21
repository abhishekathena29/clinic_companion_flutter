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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.destructive.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.notifications_active_rounded,
                    size: 22,
                    color: AppColors.destructive,
                  ),
                ),
                const SizedBox(width: 14),
                const Text(
                  'Urgent Alerts',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.destructive,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.destructive.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '${alerts.length} New',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.destructiveForeground,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: alerts.map((alert) {
                final style = _alertStyle(alert['type'] as String);
                return _HoverableAlertItem(alert: alert, style: style);
              }).toList(),
            ),
          ),
          const Divider(height: 1),
          InkWell(
            onTap: () {},
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(AppColors.borderRadius),
              bottomRight: Radius.circular(AppColors.borderRadius),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'View All Alerts',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HoverableAlertItem extends StatefulWidget {
  final Map<String, String> alert;
  final _AlertStyle style;

  const _HoverableAlertItem({required this.alert, required this.style});

  @override
  State<_HoverableAlertItem> createState() => _HoverableAlertItemState();
}

class _HoverableAlertItemState extends State<_HoverableAlertItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _isHovered
              ? widget.style.background.withOpacity(0.12)
              : widget.style.background.withOpacity(0.06),
          borderRadius: BorderRadius.circular(AppColors.borderRadius - 2),
          border: Border.all(
            color: widget.style.border.withOpacity(_isHovered ? 0.4 : 0.15),
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: widget.style.foreground.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: widget.style.foreground.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.style.icon,
                size: 20,
                color: widget.style.foreground,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.alert['patientName']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.alert['time']!,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.mutedForeground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.alert['message']!,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.foreground.withOpacity(0.85),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (_isHovered) ...[
              const SizedBox(width: 8),
              InkWell(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: AppColors.foreground.withOpacity(0.5),
                  ),
                ),
              ),
            ],
          ],
        ),
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
        icon: Icons.warning_rounded,
        background: AppColors.destructive,
        foreground: AppColors.destructive,
        border: AppColors.destructive,
      );
    case 'overdue':
      return _AlertStyle(
        icon: Icons.event_busy_rounded,
        background: AppColors.warning,
        foreground: AppColors.warningForeground,
        border: AppColors.warning,
      );
    case 'medication':
      return _AlertStyle(
        icon: Icons.medication_rounded,
        background: AppColors.info,
        foreground: AppColors.info,
        border: AppColors.info,
      );
    case 'report':
    default:
      return _AlertStyle(
        icon: Icons.description_rounded,
        background: AppColors.primary,
        foreground: AppColors.primary,
        border: AppColors.primary,
      );
  }
}
