import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/patients_provider.dart';
import '../providers/queue_provider.dart';
import '../providers/schedule_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';
import '../widgets/app_button.dart';
import '../widgets/dashboard_layout.dart';
import '../widgets/mobile_header.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  bool _isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 768;

  Future<void> _showScheduleDialog(BuildContext context) async {
    final patients = context.read<PatientsProvider>().patients;
    if (patients.isEmpty) return;

    Patient selectedPatient = patients.first;
    final timeController = TextEditingController(text: '09:00 AM');
    final typeController = TextEditingController(text: 'Consultation');
    final durationController = TextEditingController(text: '20 min');
    DateTime selectedDate = DateTime.now();
    bool addToQueue = true;
    final waitController = TextEditingController(text: '10');

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: const Text(
                'New Appointment',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    DropdownButtonFormField<Patient>(
                      value: selectedPatient,
                      decoration: const InputDecoration(labelText: 'Patient'),
                      items: patients
                          .map(
                            (patient) => DropdownMenuItem(
                              value: patient,
                              child: Text(
                                '${patient.name} • ${patient.patientId}',
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => selectedPatient = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: timeController,
                      decoration: const InputDecoration(
                        labelText: 'Time',
                        prefixIcon: Icon(Icons.access_time_rounded),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: typeController,
                      decoration: const InputDecoration(
                        labelText: 'Type',
                        prefixIcon: Icon(Icons.category_rounded),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: durationController,
                      decoration: const InputDecoration(
                        labelText: 'Duration',
                        prefixIcon: Icon(Icons.timer_rounded),
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: dialogContext,
                          initialDate: selectedDate,
                          firstDate: DateTime.now().subtract(
                            const Duration(days: 1),
                          ),
                          lastDate: DateTime.now().add(
                            const Duration(days: 60),
                          ),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: AppColors.primary,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setState(() => selectedDate = picked);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          prefixIcon: Icon(Icons.calendar_today_rounded),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            DateFormat(
                              'd MMM yyyy',
                              'en_IN',
                            ).format(selectedDate),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      value: addToQueue,
                      activeColor: AppColors.primary,
                      onChanged: (value) => setState(() => addToQueue = value),
                      title: const Text(
                        'Add to today\'s queue',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                    if (addToQueue) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: waitController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Estimated wait (min)',
                          prefixIcon: Icon(Icons.hourglass_empty_rounded),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                AppButton(
                  label: 'Schedule',
                  onPressed: () {
                    context.read<ScheduleProvider>().addAppointment(
                      patient: selectedPatient.name,
                      date: selectedDate,
                      time: timeController.text.trim(),
                      type: typeController.text.trim(),
                      duration: durationController.text.trim(),
                      status: 'Confirmed',
                    );

                    final isToday =
                        DateTime.now().year == selectedDate.year &&
                        DateTime.now().month == selectedDate.month &&
                        DateTime.now().day == selectedDate.day;
                    if (addToQueue && isToday) {
                      context.read<QueueProvider>().addToQueue(
                        patientName: selectedPatient.name,
                        patientId: selectedPatient.patientId,
                        phone: selectedPatient.phone,
                        reason: typeController.text.trim(),
                        waitTime: int.tryParse(waitController.text.trim()),
                      );
                    }
                    Navigator.of(dialogContext).pop();
                  },
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
    final isDesktop = _isDesktop(context);
    final provider = context.watch<ScheduleProvider>();
    final selectedDate = provider.selectedDate;
    final appointments = provider.appointmentsForSelectedDate;

    return DashboardLayout(
      routeName: '/appointments',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isDesktop)
            const MobileHeader(title: 'Schedule', showSearch: false),
          if (isDesktop)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Schedule',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Appointments for ${DateFormat('d MMMM yyyy', 'en_IN').format(selectedDate)}',
                      style: TextStyle(
                        color: AppColors.mutedForeground,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const AppButton(
                      label: 'Sync Calendar',
                      icon: Icons.sync_rounded,
                      variant: AppButtonVariant.outline,
                    ),
                    const SizedBox(width: 16),
                    AppButton(
                      label: 'New Appointment',
                      icon: Icons.add_rounded,
                      onPressed: () => _showScheduleDialog(context),
                    ),
                  ],
                ),
              ],
            ),
          if (!isDesktop)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Today',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  AppButton(
                    label: 'New',
                    icon: Icons.add_rounded,
                    size: AppButtonSize.small,
                    onPressed: () => _showScheduleDialog(context),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          _DaySelector(
            selected: selectedDate,
            days: provider.upcomingDays,
            onSelected: provider.selectDate,
          ),
          const SizedBox(height: 24),
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _AppointmentsList(appointments: appointments)),
                const SizedBox(width: 24),
                SizedBox(
                  width: 320,
                  child: _SummaryPanel(
                    total: appointments.length,
                    confirmed: appointments
                        .where((a) => a.status == 'Confirmed')
                        .length,
                    pending: appointments
                        .where((a) => a.status == 'Pending')
                        .length,
                    checkedIn: appointments
                        .where((a) => a.status == 'Checked-in')
                        .length,
                  ),
                ),
              ],
            )
          else
            _AppointmentsList(appointments: appointments),
        ],
      ),
    );
  }
}

class _DaySelector extends StatelessWidget {
  const _DaySelector({
    required this.selected,
    required this.days,
    required this.onSelected,
  });

  final DateTime selected;
  final List<DateTime> days;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: days.map((day) {
          final isActive =
              day.year == selected.year &&
              day.month == selected.month &&
              day.day == selected.day;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => onSelected(day),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  gradient: isActive ? AppColors.gradientPrimary : null,
                  color: isActive ? null : AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive ? Colors.transparent : AppColors.border,
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat('EEE', 'en_IN').format(day).toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        color: isActive
                            ? Colors.white.withOpacity(0.9)
                            : AppColors.mutedForeground,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('d', 'en_IN').format(day),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: isActive ? Colors.white : AppColors.foreground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _AppointmentsList extends StatelessWidget {
  const _AppointmentsList({required this.appointments});

  final List<Appointment> appointments;

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return Container(
        decoration: AppDecorations.card(),
        padding: const EdgeInsets.all(40),
        alignment: Alignment.center,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.muted,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_available_rounded,
                size: 48,
                color: AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No appointments',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.foreground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enjoy your free time or schedule a new appointment.',
              style: TextStyle(color: AppColors.mutedForeground, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return Column(
      children: appointments.map((appointment) {
        return _AppointmentListItem(appointment: appointment);
      }).toList(),
    );
  }
}

class _AppointmentListItem extends StatefulWidget {
  final Appointment appointment;

  const _AppointmentListItem({required this.appointment});

  @override
  State<_AppointmentListItem> createState() => _AppointmentListItemState();
}

class _AppointmentListItemState extends State<_AppointmentListItem> {
  bool _isHovered = false;

  Color _statusColor(String status) {
    switch (status) {
      case 'Confirmed':
        return AppColors.success;
      case 'Checked-in':
        return AppColors.info;
      case 'Pending':
      default:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appointment = widget.appointment;
    final statusColor = _statusColor(appointment.status);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: _isHovered ? AppColors.muted.withOpacity(0.3) : AppColors.card,
          borderRadius: BorderRadius.circular(AppColors.borderRadius),
          border: Border.all(
            color: AppColors.border.withOpacity(_isHovered ? 0.8 : 0.5),
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: statusColor.withOpacity(0.2)),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.medical_services_rounded,
                color: statusColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment.patient,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            appointment.type,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.mutedForeground,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          appointment.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color: AppColors.mutedForeground,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${appointment.time} • ${appointment.duration}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.mutedForeground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.location_on_rounded,
                        size: 16,
                        color: AppColors.mutedForeground,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Consultation Room 3',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.mutedForeground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: const [
                      AppButton(
                        label: 'Start Session',
                        icon: Icons.play_arrow_rounded,
                        size: AppButtonSize.small,
                      ),
                      SizedBox(width: 12),
                      AppButton(
                        label: 'Reschedule',
                        icon: Icons.calendar_today_rounded,
                        size: AppButtonSize.small,
                        variant: AppButtonVariant.outline,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryPanel extends StatelessWidget {
  const _SummaryPanel({
    required this.total,
    required this.confirmed,
    required this.pending,
    required this.checkedIn,
  });

  final int total;
  final int confirmed;
  final int pending;
  final int checkedIn;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.card(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pie_chart_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              const Text(
                'Day Summary',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _summaryRow(
            'Total Appointments',
            total,
            AppColors.foreground,
            isBold: true,
          ),
          const Divider(height: 24),
          _summaryRow('Confirmed', confirmed, AppColors.success),
          _summaryRow('Checked-in', checkedIn, AppColors.info),
          _summaryRow('Pending', pending, AppColors.warning),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.1)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '2 gaps in the afternoon. Consider moving lab review to 2:40 PM to optimize flow.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    int value,
    Color color, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isBold ? AppColors.foreground : AppColors.mutedForeground,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$value',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
