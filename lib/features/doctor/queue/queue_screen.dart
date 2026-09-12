import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/auth/auth_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_decorations.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/communication_sheet.dart';
import '../../../widgets/mobile_header.dart';
import '../../../widgets/responsive_page_header.dart';
import '../patients/patients_provider.dart';
import 'queue_provider.dart';

class QueueScreen extends StatelessWidget {
  const QueueScreen({super.key, this.showHeader = true});

  final bool showHeader;

  bool _isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 768;

  Future<void> _showAddToQueueDialog(BuildContext context) async {
    final patients = context.read<PatientsProvider>().patients;
    if (patients.isEmpty) return;

    Patient selectedPatient = patients.first;
    final reasonController = TextEditingController(text: 'General Consultation');
    final waitController = TextEditingController(text: '15');
    QueuePriority priority = QueuePriority.normal;

    const commonReasons = [
      'General Consultation',
      'Follow-up Visit',
      'Prescription Refill',
      'Fever & Cold',
      'Emergency Check',
    ];

    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 520, maxHeight: 700),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 36,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
                      decoration: BoxDecoration(
                        gradient: AppColors.gradientHero,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.how_to_reg_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Check-in Patient to Queue',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Assign token number & consultation priority',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.85),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            icon: const Icon(Icons.close_rounded, color: Colors.white),
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Flexible(
                      child: Form(
                        key: formKey,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                            // Patient Selector
                            Text(
                              'Select Patient',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.mutedForeground,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<Patient>(
                              value: selectedPatient,
                              decoration: const InputDecoration(
                                labelText: 'Patient',
                                prefixIcon: Icon(Icons.person_rounded),
                              ),
                              items: patients
                                  .map(
                                    (patient) => DropdownMenuItem(
                                      value: patient,
                                      child: Text(
                                        '${patient.name} • ${patient.patientId}',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() => selectedPatient = value);
                              },
                            ),
                            const SizedBox(height: 20),

                            // Priority Selector
                            Text(
                              'Queue Priority',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.mutedForeground,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                ChoiceChip(
                                  label: const Text('Normal Priority'),
                                  selected: priority == QueuePriority.normal,
                                  selectedColor: AppColors.primary,
                                  labelStyle: TextStyle(
                                    color: priority == QueuePriority.normal
                                        ? Colors.white
                                        : AppColors.foreground,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  onSelected: (val) {
                                    if (val) setState(() => priority = QueuePriority.normal);
                                  },
                                ),
                                const SizedBox(width: 10),
                                ChoiceChip(
                                  label: const Text('Urgent Priority'),
                                  selected: priority == QueuePriority.urgent,
                                  selectedColor: AppColors.destructive,
                                  labelStyle: TextStyle(
                                    color: priority == QueuePriority.urgent
                                        ? Colors.white
                                        : AppColors.foreground,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  onSelected: (val) {
                                    if (val) setState(() => priority = QueuePriority.urgent);
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Reason for Visit
                            Text(
                              'Reason for Visit',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.mutedForeground,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: commonReasons.map((r) {
                                final isSelected = reasonController.text == r;
                                return ActionChip(
                                  label: Text(r),
                                  backgroundColor: isSelected
                                      ? AppColors.primaryLight.withOpacity(0.6)
                                      : AppColors.background,
                                  side: BorderSide(
                                    color: isSelected ? AppColors.primary : AppColors.border,
                                  ),
                                  labelStyle: TextStyle(
                                    color: isSelected ? AppColors.primary : AppColors.foreground,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                  onPressed: () => setState(() => reasonController.text = r),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: reasonController,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Please enter reason for visit';
                                }
                                if (val.trim().length < 2) {
                                  return 'Reason must be at least 2 characters';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                labelText: 'Reason Description',
                                prefixIcon: Icon(Icons.edit_note_rounded),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Estimated Wait Time
                            Text(
                              'Estimated Wait Time (Minutes)',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.mutedForeground,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [5, 10, 15, 25, 30].map((mins) {
                                final isSelected = waitController.text == mins.toString();
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    label: Text('${mins}m'),
                                    selected: isSelected,
                                    selectedColor: AppColors.accent,
                                    labelStyle: TextStyle(
                                      color: isSelected ? Colors.white : AppColors.foreground,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    onSelected: (val) {
                                      if (val) setState(() => waitController.text = mins.toString());
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: waitController,
                              keyboardType: TextInputType.number,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Please enter estimated wait time';
                                }
                                final n = int.tryParse(val.trim());
                                if (n == null || n < 0 || n > 480) {
                                  return 'Enter valid minutes (0-480)';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                labelText: 'Custom Wait (Minutes)',
                                prefixIcon: Icon(Icons.timer_rounded),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                    // Action Footer
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: AppColors.border)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: AppColors.mutedForeground,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          AppButton(
                            label: 'Assign Token',
                            icon: Icons.confirmation_number_rounded,
                            onPressed: () {
                              if (!formKey.currentState!.validate()) return;
                              final reason = reasonController.text.trim();
                              final wait = int.tryParse(waitController.text.trim());
                              context.read<QueueProvider>().addToQueue(
                                doctorId: context.read<AuthProvider>().user?.uid ?? '',
                                patientName: selectedPatient.name,
                                patientId: selectedPatient.patientId,
                                phone: selectedPatient.phone,
                                reason: reason,
                                priority: priority,
                                waitTime: wait,
                              );
                              Navigator.of(dialogContext).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${selectedPatient.name} added to queue!'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QueueProvider>();
    final auth = context.watch<AuthProvider>();
    final doctorId = auth.user?.uid ?? '';
    final queue = provider.queueForDoctor(doctorId);
    final waitingCount = provider.waitingCountFor(doctorId);
    final inConsultationCount = provider.inConsultationCountFor(doctorId);
    final completedCount = provider.completedCountFor(doctorId);
    final avgWait = provider.averageWaitFor(doctorId);

    final isDesktop = _isDesktop(context);

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHeader) ...[
            if (!isDesktop) const MobileHeader(title: 'Queue', showSearch: false),
            if (isDesktop)
              ResponsivePageHeader(
                title: 'Queue Management',
                subtitle: "Today's patient queue and check-ins",
                actions: [
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
                  const Text(
                    "Today's Queue",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  AppButton(
                    label: 'Check-in',
                    icon: Icons.add,
                    size: AppButtonSize.small,
                    onPressed: () => _showAddToQueueDialog(context),
                  ),
                ],
              ),
            ],
          ] else
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Live Patient Queue",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '$waitingCount waiting • $inConsultationCount in consultation',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppButton(
                    label: 'Check-in Patient',
                    icon: Icons.how_to_reg_rounded,
                    size: AppButtonSize.small,
                    onPressed: () => _showAddToQueueDialog(context),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = isDesktop
                  ? (constraints.maxWidth >= 620 ? 4 : 2)
                  : 2;
              final spacing = isDesktop ? 16.0 : 12.0;
              final itemWidth =
                  (constraints.maxWidth - spacing * (crossAxisCount - 1)) /
                  crossAxisCount;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  SizedBox(
                    width: itemWidth,
                    child: _statTile(
                      Icons.access_time,
                      waitingCount.toString(),
                      'Waiting',
                      AppColors.warning,
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _statTile(
                      Icons.person,
                      inConsultationCount.toString(),
                      'Consulting',
                      AppColors.info,
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _statTile(
                      Icons.check_circle,
                      completedCount.toString(),
                      'Done',
                      AppColors.success,
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _statTile(
                      Icons.access_time,
                      '${avgWait}m',
                      'Avg. Wait',
                      AppColors.primary,
                    ),
                  ),
                ],
              );
            },
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
                            color:
                                patient.status == QueueStatus.inConsultation ||
                                    isUrgent
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
                                Flexible(
                                  child: Text(
                                  patient.patientName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  ),
                                ),
                                if (isUrgent) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.destructive.withOpacity(
                                        0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      'Urgent',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.destructive,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              patient.reason,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.mutedForeground,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusStyle.background,
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: statusStyle.border,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        statusStyle.icon,
                                        size: 12,
                                        color: statusStyle.foreground,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        statusStyle.label,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: statusStyle.foreground,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  patient.waitTime > 0
                                      ? "${patient.waitTime}m wait"
                                      : 'Just in',
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
                                      onPressed: () => context
                                          .read<QueueProvider>()
                                          .startConsultation(patient.id),
                                    ),
                                  ),
                                if (patient.status ==
                                    QueueStatus.inConsultation)
                                  Expanded(
                                    child: AppButton(
                                      label: 'Complete',
                                      icon: Icons.check_circle,
                                      size: AppButtonSize.small,
                                      variant: AppButtonVariant.outline,
                                      onPressed: () => context
                                          .read<QueueProvider>()
                                          .completeConsultation(patient.id),
                                    ),
                                  ),
                                const SizedBox(width: 8),
                                InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: () {
                                    CommunicationSheet.show(
                                      context,
                                      recipientName: patient.patientName,
                                      recipientRole: 'Patient',
                                      phone: patient.phone,
                                      isScheduled: true,
                                      scheduledTime:
                                          'Token #${patient.tokenNumber} • Check-in: ${patient.checkInTime}',
                                      statusText: patient.reason,
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF25D366).withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: const Color(0xFF25D366).withOpacity(0.35),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.phone_in_talk_rounded,
                                      size: 18,
                                      color: Color(0xFF25D366),
                                    ),
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
                        Text(
                          'Current Queue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
                              ? AppColors.info.withValues(alpha: 0.05)
                              : Colors.transparent,
                          border: Border(
                            bottom: BorderSide(
                              color: AppColors.border.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color:
                                    patient.status == QueueStatus.inConsultation
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
                                  color:
                                      patient.status ==
                                              QueueStatus.inConsultation ||
                                          isUrgent
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
                                      Flexible(
                                        child: Text(
                                        patient.patientName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        ),
                                      ),
                                      if (isUrgent) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.destructive
                                                .withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                          child: Text(
                                            'Urgent',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: AppColors.destructive,
                                            ),
                                          ),
                                        ),
                                      ],
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusStyle.background,
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                          border: Border.all(
                                            color: statusStyle.border,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              statusStyle.icon,
                                              size: 12,
                                              color: statusStyle.foreground,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              statusStyle.label,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: statusStyle.foreground,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.muted,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          patient.patientId,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: AppColors.mutedForeground,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.phone,
                                            size: 14,
                                            color: AppColors.mutedForeground,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            patient.phone,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.mutedForeground,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        patient.reason,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.mutedForeground,
                                        ),
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
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.mutedForeground,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  patient.waitTime > 0
                                      ? "${patient.waitTime} min wait"
                                      : 'Just arrived',
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
                                  AppButton(
                                    label: 'Start',
                                    icon: Icons.play_arrow,
                                    size: AppButtonSize.small,
                                    onPressed: () => context
                                        .read<QueueProvider>()
                                        .startConsultation(patient.id),
                                  ),
                                if (patient.status ==
                                    QueueStatus.inConsultation)
                                  AppButton(
                                    label: 'Complete',
                                    icon: Icons.check_circle,
                                    size: AppButtonSize.small,
                                    variant: AppButtonVariant.outline,
                                    onPressed: () => context
                                        .read<QueueProvider>()
                                        .completeConsultation(patient.id),
                                  ),
                                const SizedBox(width: 8),
                                InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: () {
                                    CommunicationSheet.show(
                                      context,
                                      recipientName: patient.patientName,
                                      recipientRole: 'Patient',
                                      phone: patient.phone,
                                      isScheduled: true,
                                      scheduledTime:
                                          'Token #${patient.tokenNumber} • Check-in: ${patient.checkInTime}',
                                      statusText: patient.reason,
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF25D366).withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: const Color(0xFF25D366).withOpacity(0.35),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(
                                          Icons.phone_in_talk_rounded,
                                          size: 14,
                                          color: Color(0xFF25D366),
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Call / Chat',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF25D366),
                                          ),
                                        ),
                                      ],
                                    ),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
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
