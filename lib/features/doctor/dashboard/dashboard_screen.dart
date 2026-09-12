import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../shared/appointments_repository.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_decorations.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/communication_sheet.dart';
import '../../../widgets/header.dart';
import '../../../widgets/mobile_header.dart';
import '../../../widgets/stat_card.dart';
import '../../../widgets/video_consultation_actions.dart';
import '../../auth/auth_provider.dart';
import '../doctor_shell.dart';
import '../reports/reports_screen.dart';
import '../schedule/schedule_queue_screen.dart';
import 'dashboard_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 768;

  void _openFullSchedule(BuildContext context) {
    final nav = DoctorNavScope.maybeOf(context);
    if (nav != null) {
      nav.onSelectTab(2);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: SafeArea(
              child: ScheduleQueueScreen(initialTab: 0),
            ),
          ),
        ),
      );
    }
  }

  void _openFullReports(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text(
              'Clinical Reports & Analytics',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            backgroundColor: AppColors.card,
            elevation: 0,
          ),
          body: const SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: ReportsScreen(),
            ),
          ),
        ),
      ),
    );
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.06),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.border.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.medication_rounded,
                              color: AppColors.primary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Prescription & Consultation Notes',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Patient: ${appointment.patient} • ${appointment.time}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.mutedForeground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => Navigator.of(dialogContext).pop(),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Medications & Dosage *',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: prescriptionController,
                                maxLines: 4,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Please enter medicine, dosage or prescription details';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  hintText:
                                      'e.g. 1. Paracetamol 500mg - 1 tab after food TID x 3 days\n2. Vitamin C 500mg OD x 15 days',
                                  hintStyle: TextStyle(
                                    color: AppColors.mutedForeground
                                        .withValues(alpha: 0.6),
                                    fontSize: 13,
                                  ),
                                  filled: true,
                                  fillColor: AppColors.muted.withValues(alpha: 0.3),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                      color: AppColors.border,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Doctor Clinical Notes / Advice',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: notesController,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  hintText:
                                      'e.g. Drink plenty of warm fluids. Follow up after 5 days if fever persists.',
                                  hintStyle: TextStyle(
                                    color: AppColors.mutedForeground
                                        .withValues(alpha: 0.6),
                                    fontSize: 13,
                                  ),
                                  filled: true,
                                  fillColor: AppColors.muted.withValues(alpha: 0.3),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                      color: AppColors.border,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.accent.withValues(alpha: 0.25),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: markCompleted,
                                      activeColor: AppColors.primary,
                                      onChanged: (val) => setState(
                                        () => markCompleted = val ?? false,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Expanded(
                                      child: Text(
                                        'Mark Consultation as Completed',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
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
                        horizontal: 24,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.muted.withValues(alpha: 0.4),
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(24),
                        ),
                        border: Border(
                          top: BorderSide(
                            color: AppColors.border.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            child: Text(
                              'Cancel',
                              style: TextStyle(color: AppColors.mutedForeground),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            icon: const Icon(
                              Icons.publish_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Publish Prescription',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
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
                                      'Prescription published! Patient can view it on their portal.',
                                    ),
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

  @override
  Widget build(BuildContext context) {
    final isDesktop = _isDesktop(context);
    final provider = context.watch<DashboardProvider>();
    final auth = context.watch<AuthProvider>();
    final repository = context.watch<AppointmentsRepository>();

    final today = provider.today;
    final shortDate = provider.shortDate;
    final greeting = provider.greeting;
    final doctorId = auth.user?.uid ?? '';
    final doctorName = auth.profileName.isEmpty ? 'Doctor' : auth.profileName;
    final appointments = repository.forDoctor(doctorId)
      ..sort((a, b) => a.date.compareTo(b.date));
    final queue = repository.queueForDoctor(doctorId);
    final reviews = repository.reviewsForDoctor(doctorId);
    final patientIds = appointments.map((item) => item.patientId).toSet();
    final patients =
        repository.patients
            .where(
              (patient) =>
                  patientIds.contains(patient.id) ||
                  patientIds.contains(patient.userId),
            )
            .toList()
          ..sort((a, b) => b.lastVisit.compareTo(a.lastVisit));

    final todayDateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final todayAppointments = appointments.where((a) {
      return DateFormat('yyyy-MM-dd').format(a.date) == todayDateStr;
    }).toList();

    // Clinical analytics
    final totalConsultations = appointments.length;
    final completedCount = appointments
        .where((a) => a.status.toLowerCase() == 'completed')
        .length;
    final videoCount =
        appointments.where((a) => a.isVideoConsultation).length;
    final inClinicCount =
        appointments.where((a) => !a.isVideoConsultation).length;
    final prescriptionsCount =
        appointments.where((a) => a.hasPrescription).length;

    // Search filtering
    final query = _searchQuery.toLowerCase();
    final isSearching = query.isNotEmpty;
    final searchAppointments = appointments.where((a) {
      return a.patient.toLowerCase().contains(query) ||
          a.type.toLowerCase().contains(query) ||
          a.clinic.toLowerCase().contains(query) ||
          a.status.toLowerCase().contains(query);
    }).toList();
    final searchQueue = queue.where((q) {
      return q.patientName.toLowerCase().contains(query) ||
          q.reason.toLowerCase().contains(query) ||
          q.phone.contains(query);
    }).toList();
    final searchPatients = repository.patients.where((p) {
      return p.name.toLowerCase().contains(query) ||
          p.phone.contains(query) ||
          p.patientId.toLowerCase().contains(query);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isDesktop)
          MobileHeader(
            title: '$greeting, $doctorName',
            subtitle: shortDate,
            searchController: _searchController,
            onSearchChanged: (val) =>
                setState(() => _searchQuery = val.trim()),
          ),
        if (isDesktop)
          Header(
            title: '$greeting, $doctorName',
            subtitle: today,
            showNewPatient: false,
            searchController: _searchController,
            onSearchChanged: (val) =>
                setState(() => _searchQuery = val.trim()),
          ),
        if (!auth.isProfileCompleted) ...[
          const SizedBox(height: 16),
          _ProfileSetupBanner(
            onComplete: () => _showDoctorProfileSetupDialog(context, auth),
          ),
        ],
        const SizedBox(height: 16),

        if (isSearching) ...[
          _SearchResultsView(
            query: _searchQuery,
            appointments: searchAppointments,
            queue: searchQueue,
            patients: searchPatients,
            onClear: () {
              setState(() {
                _searchController.clear();
                _searchQuery = '';
              });
            },
            onCompleteAppointment: (a) =>
                _completeAppointmentDirectly(context, a),
            onAddPrescription: (a) =>
                _showAddPrescriptionDialog(context, a),
          ),
        ] else ...[
          // KPI Metric cards (minimal layout)
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = isDesktop
                  ? (constraints.maxWidth >= 1180 ? 4 : 2)
                  : 2;
              final spacing = isDesktop ? 16.0 : 10.0;
              final itemWidth =
                  (constraints.maxWidth - spacing * (crossAxisCount - 1)) /
                  crossAxisCount;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: provider
                    .statsForDoctor(doctorId)
                    .map(
                      (stat) => SizedBox(
                        width: itemWidth,
                        child: StatCard(
                          title: stat.title,
                          value: stat.value,
                          change: stat.change,
                          changeType: stat.changeType,
                          icon: stat.icon,
                          variant: stat.variant,
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 24),

          // Schedule & Appointments Hub on Dashboard
          _TodayScheduleHub(
            todayAppointments: todayAppointments,
            allAppointments: appointments,
            onOpenFullSchedule: () => _openFullSchedule(context),
            onCompleteAppointment: (a) =>
                _completeAppointmentDirectly(context, a),
            onAddPrescription: (a) => _showAddPrescriptionDialog(context, a),
          ),
          const SizedBox(height: 24),

          // Reports & Clinical Analytics Hub on Dashboard
          _ReportsAnalyticsHub(
            totalConsultations: totalConsultations,
            completedCount: completedCount,
            videoCount: videoCount,
            inClinicCount: inClinicCount,
            prescriptionsCount: prescriptionsCount,
            onOpenFullReports: () => _openFullReports(context),
          ),
          const SizedBox(height: 24),

          // Live Queue & Recent Patients Split Section
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _QueuePreview(entries: queue.take(4).toList())),
                const SizedBox(width: 24),
                Expanded(
                  child: _RecentPatientsCard(
                    patients: patients.take(5).toList(),
                  ),
                ),
              ],
            )
          else ...[
            _QueuePreview(entries: queue.take(4).toList()),
            const SizedBox(height: 16),
            _RecentPatientsCard(patients: patients.take(5).toList()),
          ],

          if (reviews.isNotEmpty) ...[
            const SizedBox(height: 24),
            _DoctorReviewsPreviewCard(
              reviews: reviews,
              doctorRating: repository.doctorById(doctorId)?.rating ?? 5.0,
            ),
          ],
        ],
      ],
    );
  }
}

/// Dedicated Hub for Today's Schedule on the Dashboard
class _TodayScheduleHub extends StatelessWidget {
  const _TodayScheduleHub({
    required this.todayAppointments,
    required this.allAppointments,
    required this.onOpenFullSchedule,
    required this.onCompleteAppointment,
    required this.onAddPrescription,
  });

  final List<Appointment> todayAppointments;
  final List<Appointment> allAppointments;
  final VoidCallback onOpenFullSchedule;
  final void Function(Appointment) onCompleteAppointment;
  final void Function(Appointment) onAddPrescription;

  @override
  Widget build(BuildContext context) {
    final appointmentsToShow = todayAppointments.isNotEmpty
        ? todayAppointments
        : allAppointments.take(3).toList();
    final isShowingToday = todayAppointments.isNotEmpty;

    return Container(
      decoration: AppDecorations.card(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 520;
              final titleWidget = Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.calendar_month_rounded,
                      color: AppColors.primary,
                      size: 20,
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
                                isShowingToday
                                    ? "Today's Schedule"
                                    : "Upcoming Schedule",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${appointmentsToShow.length}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isShowingToday
                              ? DateFormat('EEEE, d MMMM yyyy').format(DateTime.now())
                              : 'Quick access to consultations and schedules',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.mutedForeground,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );

              final actionButton = OutlinedButton.icon(
                onPressed: onOpenFullSchedule,
                icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                label: const Text(
                  'Full Schedule',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );

              if (isCompact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleWidget,
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: actionButton,
                    ),
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: titleWidget),
                  const SizedBox(width: 12),
                  actionButton,
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          if (appointmentsToShow.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.muted.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.event_available_rounded,
                    size: 36,
                    color: AppColors.mutedForeground.withValues(alpha: 0.6),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No appointments scheduled for today',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.foreground.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Book consultations or click Full Schedule to view calendar',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: appointmentsToShow.map((appointment) {
                final isCompleted =
                    appointment.status.toLowerCase() == 'completed';
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isCompleted
                          ? AppColors.success.withValues(alpha: 0.3)
                          : AppColors.border,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor:
                                      AppColors.primary.withValues(alpha: 0.12),
                                  foregroundColor: AppColors.primary,
                                  child: Text(
                                    appointment.patient.isNotEmpty
                                        ? appointment.patient
                                            .substring(0, 1)
                                            .toUpperCase()
                                        : 'P',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        appointment.patient,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${appointment.time} • ${appointment.duration} • ${appointment.type}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.mutedForeground,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: (isCompleted
                                      ? AppColors.success
                                      : (appointment.status == 'Confirmed'
                                          ? AppColors.primary
                                          : AppColors.warning))
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              appointment.status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: isCompleted
                                    ? AppColors.success
                                    : (appointment.status == 'Confirmed'
                                        ? AppColors.primary
                                        : AppColors.warning),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (appointment.hasPrescription) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.receipt_long_rounded,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  appointment.prescription.isNotEmpty
                                      ? 'Rx: ${appointment.prescription}'
                                      : 'Notes: ${appointment.doctorNotes}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (appointment.isVideoConsultation)
                            VideoConsultationActions(
                              appointment: appointment,
                              contactPhone: context
                                      .watch<AppointmentsRepository>()
                                      .patientById(appointment.patientId)
                                      ?.phone ??
                                  '',
                            ),
                          if (!isCompleted)
                            AppButton(
                              label: 'Complete Session',
                              icon: Icons.task_alt_rounded,
                              size: AppButtonSize.small,
                              variant: AppButtonVariant.primary,
                              onPressed: () =>
                                  onCompleteAppointment(appointment),
                            ),
                          AppButton(
                            label: appointment.hasPrescription
                                ? 'View/Edit Rx'
                                : 'Add Rx & Notes',
                            icon: Icons.medication_rounded,
                            size: AppButtonSize.small,
                            variant: AppButtonVariant.outline,
                            onPressed: () => onAddPrescription(appointment),
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
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

/// Dedicated Hub for Reports & Clinical Analytics on Dashboard
class _ReportsAnalyticsHub extends StatelessWidget {
  const _ReportsAnalyticsHub({
    required this.totalConsultations,
    required this.completedCount,
    required this.videoCount,
    required this.inClinicCount,
    required this.prescriptionsCount,
    required this.onOpenFullReports,
  });

  final int totalConsultations;
  final int completedCount;
  final int videoCount;
  final int inClinicCount;
  final int prescriptionsCount;
  final VoidCallback onOpenFullReports;

  @override
  Widget build(BuildContext context) {
    final completionRate = totalConsultations > 0
        ? ((completedCount / totalConsultations) * 100).toInt()
        : 0;

    return Container(
      decoration: AppDecorations.card(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 520;
              final titleWidget = Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.insights_rounded,
                      color: AppColors.accent,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Reports & Clinical Analytics',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Consultation completion and performance metrics',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.mutedForeground,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );

              final actionButton = OutlinedButton.icon(
                onPressed: onOpenFullReports,
                icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                label: const Text(
                  'Detailed Reports',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );

              if (isCompact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleWidget,
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: actionButton,
                    ),
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: titleWidget),
                  const SizedBox(width: 12),
                  actionButton,
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final int cols = width >= 800 ? 4 : (width >= 420 ? 2 : 1);
              final spacing = 12.0;
              final itemWidth = (width - ((cols - 1) * spacing)) / cols;

              final items = [
                _MiniReportMetric(
                  label: 'Completed',
                  value: '$completedCount / $totalConsultations',
                  subtext: '$completionRate% completion rate',
                  color: AppColors.success,
                  icon: Icons.check_circle_rounded,
                ),
                _MiniReportMetric(
                  label: 'Video Consults',
                  value: '$videoCount',
                  subtext:
                      '${totalConsultations > 0 ? ((videoCount / totalConsultations) * 100).toInt() : 0}% of all visits',
                  color: AppColors.primary,
                  icon: Icons.videocam_rounded,
                ),
                _MiniReportMetric(
                  label: 'In-Clinic Visits',
                  value: '$inClinicCount',
                  subtext:
                      '${totalConsultations > 0 ? ((inClinicCount / totalConsultations) * 100).toInt() : 0}% in-person',
                  color: AppColors.warning,
                  icon: Icons.location_on_rounded,
                ),
                _MiniReportMetric(
                  label: 'Prescriptions',
                  value: '$prescriptionsCount',
                  subtext: 'Published records',
                  color: AppColors.accent,
                  icon: Icons.medication_rounded,
                ),
              ];

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: items
                    .map((item) => SizedBox(width: itemWidth, child: item))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MiniReportMetric extends StatelessWidget {
  const _MiniReportMetric({
    required this.label,
    required this.value,
    required this.subtext,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final String subtext;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mutedForeground,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(icon, size: 16, color: color),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtext,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}

/// Real-time live search results view on Dashboard
class _SearchResultsView extends StatelessWidget {
  const _SearchResultsView({
    required this.query,
    required this.appointments,
    required this.queue,
    required this.patients,
    required this.onClear,
    required this.onCompleteAppointment,
    required this.onAddPrescription,
  });

  final String query;
  final List<Appointment> appointments;
  final List<QueueEntry> queue;
  final List<Patient> patients;
  final VoidCallback onClear;
  final void Function(Appointment) onCompleteAppointment;
  final void Function(Appointment) onAddPrescription;

  @override
  Widget build(BuildContext context) {
    final totalCount = appointments.length + queue.length + patients.length;

    return Container(
      decoration: AppDecorations.card(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Search Results for "$query"',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$totalCount matches',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded, size: 16),
                label: const Text('Clear Search'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (totalCount == 0)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 40,
                      color: AppColors.mutedForeground,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'No matches found for "$query"',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Try searching with a patient name, phone number, token or condition',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (appointments.isNotEmpty) ...[
            Text(
              'Appointments (${appointments.length})',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            ...appointments.map((a) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.muted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor:
                          AppColors.primary.withValues(alpha: 0.15),
                      foregroundColor: AppColors.primary,
                      child: Text(
                        a.patient.isNotEmpty
                            ? a.patient.substring(0, 1).toUpperCase()
                            : 'P',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a.patient,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${DateFormat('d MMM').format(a.date)} • ${a.time} • ${a.type}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppButton(
                      label: a.hasPrescription ? 'Rx Added' : 'Add Rx',
                      icon: Icons.medication_rounded,
                      size: AppButtonSize.small,
                      variant: AppButtonVariant.outline,
                      onPressed: () => onAddPrescription(a),
                    ),
                    const SizedBox(width: 8),
                    if (a.status != 'Completed')
                      AppButton(
                        label: 'Complete',
                        icon: Icons.task_alt_rounded,
                        size: AppButtonSize.small,
                        variant: AppButtonVariant.primary,
                        onPressed: () => onCompleteAppointment(a),
                      ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
          ],
          if (queue.isNotEmpty) ...[
            Text(
              'Queue (${queue.length})',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            ...queue.map((q) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.muted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.info.withValues(alpha: 0.15),
                      foregroundColor: AppColors.info,
                      child: Text(
                        '#${q.tokenNumber}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            q.patientName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${q.reason} • ${q.phone}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        DoctorNavScope.maybeOf(context)?.onSelectTab(2);
                      },
                      child: const Text('Go to Queue', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
          ],
          if (patients.isNotEmpty) ...[
            Text(
              'Patients (${patients.length})',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            ...patients.map((p) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.muted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor:
                          AppColors.accent.withValues(alpha: 0.15),
                      foregroundColor: AppColors.accent,
                      child: Text(
                        p.name.isNotEmpty
                            ? p.name.substring(0, 1).toUpperCase()
                            : 'P',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${p.patientId} • ${p.phone} • Last visit: ${p.lastVisit.isEmpty ? 'Never' : p.lastVisit}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        DoctorNavScope.maybeOf(context)?.onSelectTab(1);
                      },
                      child: const Text('View Patient', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}


class _ProfileSetupBanner extends StatelessWidget {
  const _ProfileSetupBanner({required this.onComplete});

  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.12),
            AppColors.accent.withValues(alpha: 0.18),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.verified_user_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Complete Your Doctor Profile',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Action Needed',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Set your clinical expertise, years of experience, degrees, and consultation fee so patients can book appointments with you.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.foreground.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: onComplete,
            icon: const Icon(Icons.edit_note_rounded, size: 18),
            label: const Text('Complete Profile'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _showDoctorProfileSetupDialog(BuildContext context, AuthProvider auth) {
  final nameController = TextEditingController(
    text: auth.profileName.isNotEmpty ? auth.profileName : 'Doctor',
  );
  final clinicController = TextEditingController(
    text: auth.profileClinic.isNotEmpty ? auth.profileClinic : 'MentiFit Clinic',
  );
  final specialtyController = TextEditingController(
    text: auth.profileSpecialty.isNotEmpty ? auth.profileSpecialty : 'General Medicine',
  );
  final experienceController = TextEditingController(
    text: auth.profileExperienceYears > 0 ? auth.profileExperienceYears.toString() : '5',
  );
  final qualificationsController = TextEditingController(
    text: auth.profileQualifications.isNotEmpty ? auth.profileQualifications : 'MBBS, MD',
  );
  final feeController = TextEditingController(
    text: auth.profileFee > 0 ? auth.profileFee.toString() : '500',
  );
  final phoneController = TextEditingController(text: auth.profilePhone);
  final bioController = TextEditingController(text: auth.profileBio);

  const popularSpecialties = [
    'General Medicine',
    'Cardiology',
    'Pediatrics',
    'Dermatology',
    'Orthopedics',
    'Neurology',
    'Psychiatry',
    'Gynecology',
    'ENT Specialist',
    'Ophthalmology',
    'Dental Care',
  ];

  final formKey = GlobalKey<FormState>();

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 580, maxHeight: 760),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 36,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Gradient Header
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
                    decoration: BoxDecoration(
                      gradient: AppColors.gradientHero,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.verified_user_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Complete Doctor Profile',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Provide clinical credentials visible to patients',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.85),
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
                  // Form Content
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Doctor Name & Clinic
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: nameController,
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) return 'Name required';
                                      if (v.trim().length < 2) return 'Min 2 characters';
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'Doctor Full Name *',
                                      prefixIcon: const Icon(Icons.person_rounded),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: clinicController,
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) return 'Clinic required';
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'Clinic / Hospital *',
                                      prefixIcon: const Icon(Icons.local_hospital_rounded),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Specialty / Expertise selector
                            Text(
                              'Medical Expertise / Specialty *',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: AppColors.foreground,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: popularSpecialties.map((s) {
                                final isSelected = specialtyController.text == s;
                                return ChoiceChip(
                                  label: Text(s),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() => specialtyController.text = s);
                                    }
                                  },
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: specialtyController,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Please specify your specialty';
                                if (v.trim().length < 2) return 'Min 2 characters';
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: 'Specialty / Expertise (Custom or selected) *',
                                prefixIcon: const Icon(Icons.medical_services_rounded),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Experience and Qualifications
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: TextFormField(
                                    controller: experienceController,
                                    keyboardType: TextInputType.number,
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) return 'Years required';
                                      final yrs = int.tryParse(v.trim());
                                      if (yrs == null || yrs < 1 || yrs > 70) {
                                        return 'Enter valid years (1-70)';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'Experience (Years) *',
                                      hintText: 'e.g. 10',
                                      prefixIcon: const Icon(Icons.timeline_rounded),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 3,
                                  child: TextFormField(
                                    controller: qualificationsController,
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) return 'Degrees required';
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'Qualifications / Degrees *',
                                      hintText: 'e.g. MBBS, MD, DNB',
                                      prefixIcon: const Icon(Icons.school_rounded),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Fee and Phone
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: feeController,
                                    keyboardType: TextInputType.number,
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) return 'Fee required';
                                      final fee = int.tryParse(v.trim());
                                      if (fee == null || fee < 0) return 'Invalid fee';
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'Consultation Fee (₹) *',
                                      hintText: '500',
                                      prefixIcon: const Icon(Icons.currency_rupee_rounded),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: phoneController,
                                    keyboardType: TextInputType.phone,
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) return 'Phone required';
                                      final digits = v.replaceAll(RegExp(r'[^0-9]'), '');
                                      if (digits.length < 10) return '10-digit number';
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'Calling / WhatsApp Phone *',
                                      prefixIcon: const Icon(Icons.phone_rounded),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Bio
                            TextFormField(
                              controller: bioController,
                              maxLines: 2,
                              decoration: InputDecoration(
                                labelText: 'About / Medical Bio (optional)',
                                hintText: 'Brief summary of clinical focus, awards, or clinic timings...',
                                prefixIcon: const Icon(Icons.info_outline_rounded),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Footer Actions
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.muted.withOpacity(0.4),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
                      border: Border(top: BorderSide(color: AppColors.border)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: Text(
                            'Later',
                            style: TextStyle(color: AppColors.mutedForeground),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () async {
                            if (!formKey.currentState!.validate()) return;
                            Navigator.of(dialogContext).pop();
                            await auth.updateDoctorProfile(
                              name: nameController.text.trim(),
                              clinic: clinicController.text.trim(),
                              specialty: specialtyController.text.trim(),
                              experienceYears: int.tryParse(experienceController.text.trim()) ?? 1,
                              qualifications: qualificationsController.text.trim(),
                              fee: int.tryParse(feeController.text.trim()) ?? 500,
                              phone: phoneController.text.trim(),
                              bio: bioController.text.trim(),
                              profileCompleted: true,
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Doctor profile completed! Your credentials are now live.'),
                                  backgroundColor: AppColors.primary,
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.check_circle_rounded, size: 18),
                          label: const Text('Save & Publish Credentials'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

class _DoctorReviewsPreviewCard extends StatelessWidget {
  const _DoctorReviewsPreviewCard({
    required this.reviews,
    required this.doctorRating,
  });

  final List<DoctorReview> reviews;
  final double doctorRating;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.card(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Patient Reviews & Feedback',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Recent feedback submitted by patients after consultations',
                    style: TextStyle(
                      color: AppColors.mutedForeground,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded, color: AppColors.warning, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      doctorRating.toStringAsFixed(1),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '(${reviews.length} ${reviews.length == 1 ? 'review' : 'reviews'})',
                      style: TextStyle(color: AppColors.mutedForeground, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: reviews.take(3).map((r) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.muted.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                          foregroundColor: AppColors.primary,
                          child: Text(
                            r.patientName.isNotEmpty ? r.patientName.substring(0, 1).toUpperCase() : 'P',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            r.patientName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < r.rating ? Icons.star_rounded : Icons.star_border_rounded,
                              size: 16,
                              color: AppColors.warning,
                            );
                          }),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('d MMM').format(r.createdAt),
                          style: TextStyle(color: AppColors.mutedForeground, fontSize: 12),
                        ),
                      ],
                    ),
                    if (r.comment.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        r.comment,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.foreground.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _QueuePreview extends StatelessWidget {
  const _QueuePreview({required this.entries});

  final List<QueueEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.card(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Today's Queue",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              TextButton.icon(
                onPressed: () {
                  DoctorNavScope.maybeOf(context)?.onSelectTab(2);
                },
                icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                label: const Text('Live Queue', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (entries.isEmpty)
            Text(
              'No patients are waiting right now.',
              style: TextStyle(color: AppColors.mutedForeground),
            )
          else
            Column(
              children: entries.map((entry) {
                final isActive = entry.status == QueueStatus.inConsultation;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.muted.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: isActive
                            ? AppColors.info
                            : AppColors.primary.withValues(alpha: 0.12),
                        foregroundColor: isActive
                            ? Colors.white
                            : AppColors.primary,
                        child: Text('${entry.tokenNumber}'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.patientName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              entry.reason,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        entry.waitTime > 0 ? '${entry.waitTime}m' : 'Now',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: isActive ? AppColors.info : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _RecentPatientsCard extends StatelessWidget {
  const _RecentPatientsCard({required this.patients});

  final List<Patient> patients;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.card(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Patients',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              TextButton.icon(
                onPressed: () {
                  DoctorNavScope.maybeOf(context)?.onSelectTab(1);
                },
                icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                label: const Text('View Patients', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (patients.isEmpty)
            Text(
              'Patient data will appear here once appointments are booked.',
              style: TextStyle(color: AppColors.mutedForeground),
            )
          else
            Column(
              children: patients.map((patient) {
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      DoctorNavScope.maybeOf(context)?.onSelectTab(1);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.accent.withValues(alpha: 0.14),
                            foregroundColor: AppColors.accent,
                            child: Text(
                              patient.name.isNotEmpty
                                  ? patient.name.substring(0, 1).toUpperCase()
                                  : 'P',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  patient.name,
                                  style: const TextStyle(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${patient.patientId} • ${patient.phone.isEmpty ? 'No phone' : patient.phone}',
                                  style: TextStyle(fontSize: 12, color: AppColors.mutedForeground),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                patient.lastVisit.isEmpty ? 'New' : patient.lastVisit,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.mutedForeground,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${patient.totalVisits} visits',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.mutedForeground,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 18,
                            color: AppColors.mutedForeground,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
