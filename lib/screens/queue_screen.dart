import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';
import '../widgets/app_button.dart';
import '../widgets/dashboard_layout.dart';
import '../widgets/mobile_header.dart';

class QueueScreen extends StatelessWidget {
  const QueueScreen({super.key});

  bool _isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 768;

  @override
  Widget build(BuildContext context) {
    final queue = [
      {
        'id': '1',
        'tokenNumber': 1,
        'patientName': 'Priya Sharma',
        'patientId': 'SV-2024-001',
        'phone': '+91 98765 43210',
        'checkInTime': '09:15 AM',
        'waitTime': 45,
        'status': 'in-consultation',
        'reason': 'Follow-up - Diabetes',
        'priority': 'normal',
      },
      {
        'id': '2',
        'tokenNumber': 2,
        'patientName': 'Amit Patel',
        'patientId': 'SV-2024-042',
        'phone': '+91 87654 32109',
        'checkInTime': '09:30 AM',
        'waitTime': 30,
        'status': 'waiting',
        'reason': 'Fever & Cold',
        'priority': 'urgent',
      },
      {
        'id': '3',
        'tokenNumber': 3,
        'patientName': 'Sunita Devi',
        'patientId': 'SV-2024-089',
        'phone': '+91 76543 21098',
        'checkInTime': '09:45 AM',
        'waitTime': 15,
        'status': 'waiting',
        'reason': 'BP Check',
        'priority': 'normal',
      },
      {
        'id': '4',
        'tokenNumber': 4,
        'patientName': 'Rahul Singh',
        'patientId': 'SV-2024-156',
        'phone': '+91 65432 10987',
        'checkInTime': '10:00 AM',
        'waitTime': 5,
        'status': 'waiting',
        'reason': 'New Patient Registration',
        'priority': 'normal',
      },
      {
        'id': '5',
        'tokenNumber': 5,
        'patientName': 'Meera Joshi',
        'patientId': 'SV-2024-203',
        'phone': '+91 54321 09876',
        'checkInTime': '10:05 AM',
        'waitTime': 0,
        'status': 'waiting',
        'reason': 'Lab Results',
        'priority': 'normal',
      },
    ];

    final waitingCount = queue.where((p) => p['status'] == 'waiting').length;
    final inConsultationCount = queue.where((p) => p['status'] == 'in-consultation').length;
    final completedCount = queue.where((p) => p['status'] == 'completed').length;
    final avgWait = queue
            .where((p) => p['status'] == 'waiting')
            .fold<int>(0, (sum, p) => sum + (p['waitTime'] as int)) /
        (waitingCount == 0 ? 1 : waitingCount);

    final isDesktop = _isDesktop(context);

    return DashboardLayout(
      routeName: '/queue',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isDesktop) const MobileHeader(title: 'Queue', showSearch: false),
          if (isDesktop)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Queue Management', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(
                      "Today's patient queue and check-ins",
                      style: TextStyle(color: AppColors.mutedForeground),
                    ),
                  ],
                ),
                const AppButton(label: 'Check-in Patient', icon: Icons.add),
              ],
            ),
          if (!isDesktop) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("Today's Queue", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                AppButton(label: 'Check-in', icon: Icons.add, size: AppButtonSize.small),
              ],
            ),
          ],
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: isDesktop ? 4 : 2,
            mainAxisSpacing: isDesktop ? 16 : 12,
            crossAxisSpacing: isDesktop ? 16 : 12,
            childAspectRatio: isDesktop ? 2.4 : 1.6,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _statTile(Icons.access_time, waitingCount.toString(), 'Waiting', AppColors.warning),
              _statTile(Icons.person, inConsultationCount.toString(), 'Consulting', AppColors.info),
              _statTile(Icons.check_circle, completedCount.toString(), 'Done', AppColors.success),
              _statTile(Icons.access_time, '${avgWait.round()}m', 'Avg. Wait', AppColors.primary),
            ],
          ),
          const SizedBox(height: 16),
          if (!isDesktop)
            Column(
              children: queue.map((patient) {
                final statusStyle = _statusStyle(patient['status'] as String);
                final isUrgent = patient['priority'] == 'urgent';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: AppDecorations.card(),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: patient['status'] == 'in-consultation'
                              ? AppColors.info
                              : isUrgent
                                  ? AppColors.destructive
                                  : AppColors.muted,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${patient['tokenNumber']}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: patient['status'] == 'in-consultation' || isUrgent
                                ? Colors.white
                                : AppColors.mutedForeground,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  patient['patientName'] as String,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                if (isUrgent) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.destructive.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      'Urgent',
                                      style: TextStyle(fontSize: 11, color: AppColors.destructive),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              patient['reason'] as String,
                              style: TextStyle(fontSize: 12, color: AppColors.mutedForeground),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusStyle.background,
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(color: statusStyle.border),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(statusStyle.icon, size: 12, color: statusStyle.foreground),
                                      const SizedBox(width: 4),
                                      Text(
                                        statusStyle.label,
                                        style: TextStyle(fontSize: 11, color: statusStyle.foreground),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  (patient['waitTime'] as int) > 0
                                      ? "${patient['waitTime']}m wait"
                                      : 'Just in',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _waitColor(patient['waitTime'] as int),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                if (patient['status'] == 'waiting')
                                  Expanded(
                                    child: AppButton(
                                      label: 'Start Consultation',
                                      icon: Icons.play_arrow,
                                      size: AppButtonSize.small,
                                    ),
                                  ),
                                if (patient['status'] == 'in-consultation')
                                  Expanded(
                                    child: AppButton(
                                      label: 'Complete',
                                      icon: Icons.check_circle,
                                      size: AppButtonSize.small,
                                      variant: AppButtonVariant.outline,
                                    ),
                                  ),
                                const SizedBox(width: 8),
                                AppButton(
                                  label: '',
                                  icon: Icons.chevron_right,
                                  size: AppButtonSize.small,
                                  variant: AppButtonVariant.ghost,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            )
          else
            Container(
              decoration: AppDecorations.card(),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: const [
                        Text('Current Queue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Column(
                    children: queue.map((patient) {
                      final statusStyle = _statusStyle(patient['status'] as String);
                      final isUrgent = patient['priority'] == 'urgent';

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: patient['status'] == 'in-consultation'
                              ? AppColors.info.withOpacity(0.05)
                              : Colors.transparent,
                          border: Border(bottom: BorderSide(color: AppColors.border.withOpacity(0.7))),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: patient['status'] == 'in-consultation'
                                    ? AppColors.info
                                    : isUrgent
                                        ? AppColors.destructive
                                        : AppColors.muted,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${patient['tokenNumber']}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: patient['status'] == 'in-consultation' || isUrgent
                                      ? Colors.white
                                      : AppColors.mutedForeground,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        patient['patientName'] as String,
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                      ),
                                      if (isUrgent) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.destructive.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(999),
                                          ),
                                          child: Text(
                                            'Urgent',
                                            style: TextStyle(fontSize: 11, color: AppColors.destructive),
                                          ),
                                        ),
                                      ],
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: statusStyle.background,
                                          borderRadius: BorderRadius.circular(999),
                                          border: Border.all(color: statusStyle.border),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(statusStyle.icon, size: 12, color: statusStyle.foreground),
                                            const SizedBox(width: 4),
                                            Text(
                                              statusStyle.label,
                                              style: TextStyle(fontSize: 11, color: statusStyle.foreground),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.muted,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          patient['patientId'] as String,
                                          style: TextStyle(fontSize: 11, color: AppColors.mutedForeground),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.phone, size: 14, color: AppColors.mutedForeground),
                                          const SizedBox(width: 4),
                                          Text(
                                            patient['phone'] as String,
                                            style: TextStyle(fontSize: 12, color: AppColors.mutedForeground),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        patient['reason'] as String,
                                        style: TextStyle(fontSize: 12, color: AppColors.mutedForeground),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Check-in: ${patient['checkInTime']}',
                                  style: TextStyle(fontSize: 12, color: AppColors.mutedForeground),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  (patient['waitTime'] as int) > 0
                                      ? "${patient['waitTime']} min wait"
                                      : 'Just arrived',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: _waitColor(patient['waitTime'] as int),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Row(
                              children: [
                                if (patient['status'] == 'waiting')
                                  const AppButton(label: 'Start', icon: Icons.play_arrow, size: AppButtonSize.small),
                                if (patient['status'] == 'in-consultation')
                                  const AppButton(
                                    label: 'Complete',
                                    icon: Icons.check_circle,
                                    size: AppButtonSize.small,
                                    variant: AppButtonVariant.outline,
                                  ),
                                const SizedBox(width: 8),
                                AppButton(
                                  label: '',
                                  icon: Icons.chevron_right,
                                  size: AppButtonSize.small,
                                  variant: AppButtonVariant.ghost,
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  if (queue.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'No patients in queue',
                        style: TextStyle(color: AppColors.mutedForeground),
                      ),
                    ),
                ],
              ),
            ),
          if (queue.isEmpty && !isDesktop)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'No patients in queue',
                style: TextStyle(color: AppColors.mutedForeground),
              ),
            ),
        ],
      ),
    );
  }

  Widget _statTile(IconData icon, String value, String label, Color color) {
    return Container(
      decoration: AppDecorations.card(),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(label, style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
            ],
          ),
        ],
      ),
    );
  }

  _StatusStyle _statusStyle(String status) {
    switch (status) {
      case 'in-consultation':
        return _StatusStyle(
          label: 'With Doctor',
          icon: Icons.person,
          background: AppColors.info.withOpacity(0.15),
          foreground: AppColors.info,
          border: AppColors.info.withOpacity(0.3),
        );
      case 'completed':
        return _StatusStyle(
          label: 'Completed',
          icon: Icons.check_circle,
          background: AppColors.success.withOpacity(0.15),
          foreground: AppColors.success,
          border: AppColors.success.withOpacity(0.3),
        );
      case 'no-show':
        return _StatusStyle(
          label: 'No Show',
          icon: Icons.cancel,
          background: AppColors.destructive.withOpacity(0.15),
          foreground: AppColors.destructive,
          border: AppColors.destructive.withOpacity(0.3),
        );
      case 'waiting':
      default:
        return _StatusStyle(
          label: 'Waiting',
          icon: Icons.access_time,
          background: AppColors.warning.withOpacity(0.15),
          foreground: AppColors.warning,
          border: AppColors.warning.withOpacity(0.3),
        );
    }
  }

  Color _waitColor(int waitTime) {
    if (waitTime > 30) return AppColors.destructive;
    if (waitTime > 15) return AppColors.warning;
    return AppColors.success;
  }
}

class _StatusStyle {
  const _StatusStyle({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.border,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final Color border;
}
