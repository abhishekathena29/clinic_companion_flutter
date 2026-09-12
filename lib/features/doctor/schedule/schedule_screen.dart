import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../features/auth/auth_provider.dart';
import '../../../shared/appointments_repository.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_decorations.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/consultation_mode_toggle.dart';
import '../../../widgets/communication_sheet.dart';
import '../../../widgets/mobile_header.dart';
import '../../../widgets/responsive_page_header.dart';
import '../../../widgets/video_consultation_actions.dart';
import '../patients/patients_provider.dart';
import '../queue/queue_provider.dart';
import 'schedule_provider.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key, this.showHeader = true});

  final bool showHeader;

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
    String consultationMode = kConsultationInPerson;
    final meetingLinkController = TextEditingController();

    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 24,
              ),
              child: Container(
                width: 520,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.90,
                ),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 28,
                      offset: const Offset(0, 10),
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
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withOpacity(0.85),
                          ],
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.calendar_month_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'New Appointment',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Schedule consultation & notify patient',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: Colors.white70),
                            onPressed: () => Navigator.of(dialogContext).pop(),
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Flexible(
                      child: Form(
                        key: formKey,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                            // Patient Selector
                            const Text(
                              'Select Patient',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<Patient>(
                              value: selectedPatient,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.person_outline_rounded),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              items: patients
                                  .map(
                                    (patient) => DropdownMenuItem(
                                      value: patient,
                                      child: Text(
                                        '${patient.name} (${patient.patientId})',
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() => selectedPatient = value);
                              },
                            ),
                            const SizedBox(height: 18),

                            // Date Picker
                            const Text(
                              'Appointment Date',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              borderRadius: BorderRadius.circular(12),
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
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.border),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today_rounded,
                                      size: 18,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      DateFormat('EEEE, d MMMM yyyy').format(selectedDate),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(
                                      Icons.arrow_drop_down_rounded,
                                      color: AppColors.mutedForeground,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Time & Duration
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Time',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: timeController,
                                        validator: (val) {
                                          if (val == null || val.trim().isEmpty) {
                                            return 'Time required';
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(Icons.access_time_rounded),
                                          hintText: 'e.g. 10:30 AM',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Duration',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: durationController,
                                        validator: (val) {
                                          if (val == null || val.trim().isEmpty) {
                                            return 'Duration required';
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(Icons.timer_outlined),
                                          hintText: 'e.g. 20 min',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),

                            // Consultation Type Chips
                            const Text(
                              'Appointment Type',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: [
                                'General Consultation',
                                'Follow-up',
                                'Prescription Refill',
                                'Specialist Checkup',
                              ].map((type) {
                                final isSelected = typeController.text == type;
                                return ChoiceChip(
                                  label: Text(type),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() => typeController.text = type);
                                    }
                                  },
                                  selectedColor: AppColors.primary.withOpacity(0.15),
                                  labelStyle: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? AppColors.primary : null,
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 18),

                            // Consultation Mode
                            const Text(
                              'Consultation Mode',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ConsultationModeToggle(
                              mode: consultationMode,
                              onChanged: (value) =>
                                  setState(() => consultationMode = value),
                            ),
                            if (consultationMode == kConsultationVideo) ...[
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: meetingLinkController,
                                validator: (val) {
                                  if (consultationMode == kConsultationVideo) {
                                    if (val == null || val.trim().isEmpty) {
                                      return 'Meeting link required for video mode';
                                    }
                                    if (!val.trim().startsWith('http://') && !val.trim().startsWith('https://')) {
                                      return 'Valid URL (e.g. https://meet.google.com/...)';
                                    }
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Google Meet / Video Link',
                                  prefixIcon: const Icon(Icons.video_call_rounded),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 18),

                            // Queue Switch
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.muted.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                children: [
                                  SwitchListTile(
                                    value: addToQueue,
                                    activeColor: AppColors.primary,
                                    onChanged: (value) =>
                                        setState(() => addToQueue = value),
                                    title: const Text(
                                      'Add to today\'s live queue',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    subtitle: const Text(
                                      'Automatically adds patient to active waiting list',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  if (addToQueue) ...[
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: waitController,
                                      keyboardType: TextInputType.number,
                                      validator: (val) {
                                        if (addToQueue) {
                                          if (val == null || val.trim().isEmpty) {
                                            return 'Enter wait minutes';
                                          }
                                          final n = int.tryParse(val.trim());
                                          if (n == null || n < 0 || n > 480) {
                                            return 'Valid minutes (0-480)';
                                          }
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        labelText: 'Estimated Wait (minutes)',
                                        prefixIcon: const Icon(Icons.hourglass_empty_rounded),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                    // Actions
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: AppColors.border)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(dialogContext).pop(),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.check_rounded, size: 18),
                              label: const Text(
                                'Schedule',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                if (!formKey.currentState!.validate()) return;
                                context.read<ScheduleProvider>().addAppointment(
                                  doctorId:
                                      context.read<AuthProvider>().user?.uid ?? '',
                                  doctorName:
                                      context.read<AuthProvider>().profileName,
                                  specialty:
                                      context
                                          .read<AppointmentsRepository>()
                                          .doctorById(
                                            context.read<AuthProvider>().user?.uid,
                                          )
                                          ?.specialty ??
                                      'General Medicine',
                                  clinic:
                                      context
                                          .read<AppointmentsRepository>()
                                          .doctorById(
                                            context.read<AuthProvider>().user?.uid,
                                          )
                                          ?.clinic ??
                                      'MentiFit Clinic',
                                  patientId: selectedPatient.id,
                                  patient: selectedPatient.name,
                                  date: selectedDate,
                                  time: timeController.text.trim(),
                                  type: typeController.text.trim(),
                                  duration: durationController.text.trim(),
                                  status: 'Confirmed',
                                  consultationMode: consultationMode,
                                  meetingLink: meetingLinkController.text.trim(),
                                );

                                final isToday =
                                    DateTime.now().year == selectedDate.year &&
                                    DateTime.now().month == selectedDate.month &&
                                    DateTime.now().day == selectedDate.day;
                                if (addToQueue && isToday) {
                                  context.read<QueueProvider>().addToQueue(
                                    doctorId:
                                        context.read<AuthProvider>().user?.uid ?? '',
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
    final isDesktop = _isDesktop(context);
    final provider = context.watch<ScheduleProvider>();
    final auth = context.watch<AuthProvider>();
    final doctorId = auth.user?.uid ?? '';
    final selectedDate = provider.selectedDate;
    final appointments = provider.appointmentsForDate(doctorId);

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHeader) ...[
            if (!isDesktop)
              const MobileHeader(title: 'Schedule', showSearch: false),
            if (isDesktop)
              ResponsivePageHeader(
                title: 'Schedule',
                subtitle:
                    'Appointments for ${DateFormat('d MMMM yyyy', 'en_IN').format(selectedDate)}',
                actions: [
                  const AppButton(
                    label: 'Sync Calendar',
                    icon: Icons.sync_rounded,
                    variant: AppButtonVariant.outline,
                  ),
                  AppButton(
                    label: 'New Appointment',
                    icon: Icons.add_rounded,
                    onPressed: () => _showScheduleDialog(context),
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
                        Text(
                          DateFormat('EEEE, d MMMM yyyy', 'en_IN').format(selectedDate),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${appointments.length} appointments scheduled',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppButton(
                    label: 'New Appointment',
                    icon: Icons.add_rounded,
                    size: AppButtonSize.small,
                    onPressed: () => _showScheduleDialog(context),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment.patient,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            appointment.type,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.mutedForeground,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        ),
                      ),
                      const SizedBox(width: 12),
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
                  Wrap(
                    spacing: 16,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
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
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            appointment.isVideoConsultation
                                ? Icons.videocam_rounded
                                : Icons.location_on_rounded,
                            size: 16,
                            color: AppColors.mutedForeground,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            appointment.isVideoConsultation
                                ? 'Video consultation'
                                : appointment.clinic,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.mutedForeground,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (appointment.hasPrescription) ...[
                    Container(
                      margin: const EdgeInsets.only(top: 14, bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.receipt_long_rounded, size: 18, color: AppColors.primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              appointment.prescription.isNotEmpty
                                  ? 'Prescription: ${appointment.prescription}'
                                  : 'Notes: ${appointment.doctorNotes}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                            ),
                          ),
                          TextButton(
                            onPressed: () => _showAddPrescriptionDialog(context, appointment),
                            child: const Text('Edit', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  if (appointment.isVideoConsultation)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        VideoConsultationActions(
                          appointment: appointment,
                          contactPhone:
                              context
                                  .watch<AppointmentsRepository>()
                                  .patientById(appointment.patientId)
                                  ?.phone ??
                              '',
                        ),
                        if (appointment.status != 'Completed')
                          AppButton(
                            label: 'Complete',
                            icon: Icons.task_alt_rounded,
                            size: AppButtonSize.small,
                            variant: AppButtonVariant.primary,
                            onPressed: () => _completeAppointmentDirectly(context, appointment),
                          ),
                        AppButton(
                          label: appointment.hasPrescription ? 'Rx Added' : 'Add Rx',
                          icon: Icons.medication_rounded,
                          size: AppButtonSize.small,
                          variant: appointment.hasPrescription
                              ? AppButtonVariant.primary
                              : AppButtonVariant.outline,
                          onPressed: () => _showAddPrescriptionDialog(context, appointment),
                        ),
                        IconButton.filledTonal(
                          icon: const Icon(Icons.perm_phone_msg_rounded, size: 18),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.primary.withOpacity(0.12),
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.all(10),
                          ),
                          tooltip: 'Call or WhatsApp Patient',
                          onPressed: () {
                            final patient = context
                                .read<AppointmentsRepository>()
                                .patientById(appointment.patientId);
                            CommunicationSheet.show(
                              context,
                              recipientName: appointment.patient,
                              phone: patient?.phone ?? '',
                              recipientRole: 'Patient',
                              scheduledTime:
                                  '${appointment.time} • ${DateFormat('d MMM').format(appointment.date)}',
                              statusText: appointment.type,
                              isScheduled: appointment.status != 'Cancelled',
                              meetingLink: appointment.meetingLink,
                            );
                          },
                        ),
                      ],
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (appointment.status != 'Completed')
                          AppButton(
                            label: 'Complete Session',
                            icon: Icons.task_alt_rounded,
                            size: AppButtonSize.small,
                            variant: AppButtonVariant.primary,
                            onPressed: () => _completeAppointmentDirectly(context, appointment),
                          ),
                        AppButton(
                          label: appointment.hasPrescription ? 'View/Edit Rx' : 'Add Rx & Notes',
                          icon: Icons.medication_rounded,
                          size: AppButtonSize.small,
                          variant: appointment.hasPrescription
                              ? AppButtonVariant.outline
                              : AppButtonVariant.outline,
                          onPressed: () => _showAddPrescriptionDialog(context, appointment),
                        ),
                        AppButton(
                          label: 'Call / WhatsApp',
                          icon: Icons.perm_phone_msg_rounded,
                          size: AppButtonSize.small,
                          variant: AppButtonVariant.outline,
                          onPressed: () {
                            final patient = context
                                .read<AppointmentsRepository>()
                                .patientById(appointment.patientId);
                            CommunicationSheet.show(
                              context,
                              recipientName: appointment.patient,
                              phone: patient?.phone ?? '',
                              recipientRole: 'Patient',
                              scheduledTime:
                                  '${appointment.time} • ${DateFormat('d MMM').format(appointment.date)}',
                              statusText: appointment.type,
                              isScheduled: appointment.status != 'Cancelled',
                              meetingLink: appointment.meetingLink,
                            );
                          },
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

  Future<void> _completeAppointmentDirectly(
    BuildContext context,
    Appointment appointment,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.task_alt_rounded, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('Complete Consultation'),
          ],
        ),
        content: Text(
          'Mark consultation for "${appointment.patient}" as completed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await context
          .read<AppointmentsRepository>()
          .updateAppointmentStatus(appointment.id, 'Completed');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Consultation with ${appointment.patient} marked as completed!',
            ),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    }
  }

  Future<void> _showAddPrescriptionDialog(
    BuildContext context,
    Appointment appointment,
  ) async {
    final prescriptionController =
        TextEditingController(text: appointment.prescription);
    final notesController =
        TextEditingController(text: appointment.doctorNotes);
    bool markCompleted = appointment.status != 'Completed';
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Container(
                width: 540,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.90,
                ),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
                      decoration: BoxDecoration(
                        gradient: AppColors.gradientHero,
                        borderRadius:
                            const BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.medication_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  appointment.hasPrescription
                                      ? 'Update Prescription & Notes'
                                      : 'Add Prescription & Clinical Notes',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Patient: ${appointment.patient} • ${DateFormat('d MMM yyyy').format(appointment.date)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded,
                                color: Colors.white70),
                            onPressed: () => Navigator.of(dialogContext).pop(),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 20),
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Medications & Dosage (Rx) *',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: prescriptionController,
                                maxLines: 4,
                                validator: (val) {
                                  if ((val == null || val.trim().isEmpty) &&
                                      notesController.text.trim().isEmpty) {
                                    return 'Please enter either medications or clinical notes';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  hintText:
                                      'e.g.:\n1. Tab Paracetamol 650mg - 1 tab after meals twice daily (3 days)\n2. Cetirizine 10mg - 1 tab at bedtime (5 days)',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Clinical Observations & Doctor Advice',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: notesController,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  hintText:
                                      'e.g. Advised plenty of fluid intake, warm water gargle. Review if symptoms persist beyond 3 days.',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.muted,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: markCompleted,
                                      activeColor: AppColors.primary,
                                      onChanged: (val) => setState(
                                          () => markCompleted = val ?? false),
                                    ),
                                    const SizedBox(width: 8),
                                    const Expanded(
                                      child: Text(
                                        'Mark Consultation as Completed',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        border:
                            Border(top: BorderSide(color: AppColors.border)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.send_rounded, size: 16),
                            label: const Text('Save & Publish to Patient'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () async {
                              if (!formKey.currentState!.validate()) return;
                              await context
                                  .read<AppointmentsRepository>()
                                  .saveAppointmentPrescription(
                                    appointmentId: appointment.id,
                                    prescription:
                                        prescriptionController.text.trim(),
                                    doctorNotes: notesController.text.trim(),
                                    markCompleted: markCompleted,
                                  );
                              if (dialogContext.mounted) {
                                Navigator.of(dialogContext).pop();
                              }
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                        'Prescription & notes published! Patient can view it on their portal.'),
                                    backgroundColor: AppColors.primary,
                                  ),
                                );
                              }
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
