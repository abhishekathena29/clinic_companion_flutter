import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/patients_provider.dart';
import '../providers/queue_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';
import '../widgets/app_button.dart';
import '../widgets/dashboard_layout.dart';
import '../widgets/mobile_header.dart';

class QueueScreen extends StatelessWidget {
  const QueueScreen({super.key});

  bool _isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 768;

  Future<void> _showAddToQueueDialog(BuildContext context) async {
    final patients = context.read<PatientsProvider>().patients;
    if (patients.isEmpty) return;

    Patient selectedPatient = patients.first;
    final reasonController = TextEditingController();
    final waitController = TextEditingController();
    QueuePriority priority = QueuePriority.normal;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Check-in Patient'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    DropdownButtonFormField<Patient>(
                      value: selectedPatient,
                      decoration: const InputDecoration(labelText: 'Patient'),
                      items: patients
                          .map((patient) => DropdownMenuItem(
                                value: patient,
                                child: Text('${patient.name} • ${patient.patientId}'),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => selectedPatient = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: reasonController,
                      decoration: const InputDecoration(labelText: 'Reason for visit'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<QueuePriority>(
                      value: priority,
                      decoration: const InputDecoration(labelText: 'Priority'),
                      items: const [
                        DropdownMenuItem(value: QueuePriority.normal, child: Text('Normal')),
                        DropdownMenuItem(value: QueuePriority.urgent, child: Text('Urgent')),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => priority = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: waitController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Estimated wait (min)'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final reason = reasonController.text.trim().isEmpty
                        ? 'General Consultation'
                        : reasonController.text.trim();
                    final wait = int.tryParse(waitController.text.trim());
                    context.read<QueueProvider>().addToQueue(
                          patientName: selectedPatient.name,
                          patientId: selectedPatient.patientId,
                          phone: selectedPatient.phone,
                          reason: reason,
                          priority: priority,
                          waitTime: wait,
                        );
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Add to queue'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QueueProvider>();
    final queue = provider.queue;
    final waitingCount = provider.waitingCount;
    final inConsultationCount = provider.inConsultationCount;
    final completedCount = provider.completedCount;
    final avgWait = provider.averageWait;

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
                AppButton(
                  label: 'Check-in Patient',
                  icon: Icons.add,
                  onPressed: () => _showAddToQueueDialog(context),
                ),
              ],
            ),
          if (!isDesktop) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Today's Queue", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                AppButton(
                  label: 'Check-in',
                  icon: Icons.add,
                  size: AppButtonSize.small,
                  onPressed: () => _showAddToQueueDialog(context),
                ),
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
              _statTile(Icons.access_time, '${avgWait}m', 'Avg. Wait', AppColors.primary),
            ],
          ),
          const SizedBox(height: 16),
          if (!isDesktop)
            Column(
              children: queue.map((patient) {
                final statusStyle = _statusStyle(patient.status);
                final isUrgent = patient.priority == QueuePriority.urgent;

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
                          color: patient.status == QueueStatus.inConsultation
                              ? AppColors.info
                              : isUrgent
                                  ? AppColors.destructive
                                  : AppColors.muted,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${patient.tokenNumber}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: patient.status == QueueStatus.inConsultation || isUrgent
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
                                  patient.patientName,
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
                              patient.reason,
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
                                  patient.waitTime > 0 ? "${patient.waitTime}m wait" : 'Just in',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _waitColor(patient.waitTime),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                if (patient.status == QueueStatus.waiting)
                                  Expanded(
                                    child: AppButton(
                                      label: 'Start Consultation',
                                      icon: Icons.play_arrow,
                                      size: AppButtonSize.small,
                                    ),
                                  ),
                                if (patient.status == QueueStatus.inConsultation)
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
                      final statusStyle = _statusStyle(patient.status);
                      final isUrgent = patient.priority == QueuePriority.urgent;

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: patient.status == QueueStatus.inConsultation
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
                                color: patient.status == QueueStatus.inConsultation
                                    ? AppColors.info
                                    : isUrgent
                                        ? AppColors.destructive
                                        : AppColors.muted,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${patient.tokenNumber}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: patient.status == QueueStatus.inConsultation || isUrgent
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
                                        patient.patientName,
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
                                          patient.patientId,
                                          style: TextStyle(fontSize: 11, color: AppColors.mutedForeground),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.phone, size: 14, color: AppColors.mutedForeground),
                                          const SizedBox(width: 4),
                                          Text(
                                            patient.phone,
                                            style: TextStyle(fontSize: 12, color: AppColors.mutedForeground),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        patient.reason,
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
                                  'Check-in: ${patient.checkInTime}',
                                  style: TextStyle(fontSize: 12, color: AppColors.mutedForeground),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  patient.waitTime > 0 ? "${patient.waitTime} min wait" : 'Just arrived',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: _waitColor(patient.waitTime),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Row(
                              children: [
                                if (patient.status == QueueStatus.waiting)
                                  const AppButton(label: 'Start', icon: Icons.play_arrow, size: AppButtonSize.small),
                                if (patient.status == QueueStatus.inConsultation)
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

  _StatusStyle _statusStyle(QueueStatus status) {
    switch (status) {
      case QueueStatus.inConsultation:
        return _StatusStyle(
          label: 'With Doctor',
          icon: Icons.person,
          background: AppColors.info.withOpacity(0.15),
          foreground: AppColors.info,
          border: AppColors.info.withOpacity(0.3),
        );
      case QueueStatus.completed:
        return _StatusStyle(
          label: 'Completed',
          icon: Icons.check_circle,
          background: AppColors.success.withOpacity(0.15),
          foreground: AppColors.success,
          border: AppColors.success.withOpacity(0.3),
        );
      case QueueStatus.noShow:
        return _StatusStyle(
          label: 'No Show',
          icon: Icons.cancel,
          background: AppColors.destructive.withOpacity(0.15),
          foreground: AppColors.destructive,
          border: AppColors.destructive.withOpacity(0.3),
        );
      case QueueStatus.waiting:
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
