import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../features/auth/auth_provider.dart';
import '../../../shared/appointments_repository.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_decorations.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/communication_sheet.dart';
import '../../../widgets/consultation_mode_toggle.dart';
import '../../../widgets/video_consultation_actions.dart';
import '../doctors/patient_doctors_provider.dart';
import 'patient_appointments_provider.dart';

class PatientAppointmentsScreen extends StatelessWidget {
  const PatientAppointmentsScreen({super.key});

  bool _isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 768;

  Future<void> _showBookingDialog(
    BuildContext context, {
    required String patientId,
    required String patientName,
  }) async {
    final doctors = context.read<PatientDoctorsProvider>().doctors;
    if (doctors.isEmpty) return;
    DoctorProfile selected = doctors.first;
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    final timeController = TextEditingController(text: '10:30 AM');
    final reasonController = TextEditingController(text: 'Consultation');
    String consultationMode = kConsultationInPerson;

    const timeSlots = [
      '09:30 AM',
      '10:30 AM',
      '11:30 AM',
      '02:00 PM',
      '03:30 PM',
      '05:00 PM',
    ];

    const commonReasons = [
      'General Consultation',
      'Follow-up Visit',
      'Prescription Refill',
      'Fever & Cold',
      'Routine Health Checkup',
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
                constraints: const BoxConstraints(maxWidth: 540, maxHeight: 720),
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
                              Icons.calendar_month_rounded,
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
                                  'Request Appointment',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Choose specialist, consultation mode, and slot',
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
                            // Doctor Selector
                            Text(
                              'Select Doctor',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.mutedForeground,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<DoctorProfile>(
                              value: selected,
                              decoration: const InputDecoration(
                                labelText: 'Doctor',
                                prefixIcon: Icon(Icons.medical_services_rounded),
                              ),
                              items: doctors
                                  .map(
                                    (doctor) => DropdownMenuItem(
                                      value: doctor,
                                      child: Text(
                                        '${doctor.name} • ${doctor.specialty}',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() => selected = value);
                              },
                            ),
                            const SizedBox(height: 20),

                            // Consultation Mode
                            Text(
                              'Consultation Mode',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.mutedForeground,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ConsultationModeToggle(
                              mode: consultationMode,
                              onChanged: (value) => setState(() => consultationMode = value),
                            ),
                            const SizedBox(height: 20),

                            // Date Picker
                            Text(
                              'Appointment Date',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.mutedForeground,
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: dialogContext,
                                  initialDate: selectedDate,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 60)),
                                );
                                if (picked != null) {
                                  setState(() => selectedDate = picked);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.border),
                                  borderRadius: BorderRadius.circular(16),
                                  color: AppColors.background,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today_rounded,
                                      size: 18,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        DateFormat('EEEE, d MMMM yyyy').format(selectedDate),
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Icon(Icons.arrow_drop_down_rounded, color: AppColors.mutedForeground),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Time Slots
                            Text(
                              'Time Slot',
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
                              children: timeSlots.map((slot) {
                                final isSelected = timeController.text == slot;
                                return ChoiceChip(
                                  label: Text(slot),
                                  selected: isSelected,
                                  selectedColor: AppColors.primary,
                                  labelStyle: TextStyle(
                                    color: isSelected ? Colors.white : AppColors.foreground,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                  onSelected: (val) {
                                    if (val) setState(() => timeController.text = slot);
                                  },
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: timeController,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Please select or enter preferred time';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                labelText: 'Custom Time',
                                hintText: 'e.g. 11:15 AM',
                                prefixIcon: Icon(Icons.access_time_rounded),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Reason
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
                                if (val.trim().length < 3) {
                                  return 'Reason must be at least 3 characters';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                labelText: 'Reason / Symptoms',
                                prefixIcon: Icon(Icons.edit_note_rounded),
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
                            label: 'Submit Request',
                            icon: Icons.check_circle_rounded,
                            onPressed: () {
                              if (!formKey.currentState!.validate()) return;
                              context.read<PatientAppointmentsProvider>().bookAppointment(
                                patientId: patientId,
                                patientName: patientName,
                                doctorId: selected.id,
                                doctor: selected.name,
                                specialty: selected.specialty,
                                clinic: selected.clinic,
                                date: selectedDate,
                                time: timeController.text.trim(),
                                reason: reasonController.text.trim(),
                                consultationMode: consultationMode,
                              );
                              Navigator.of(dialogContext).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Appointment requested with ${selected.name}!'),
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
    final isDesktop = _isDesktop(context);
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<PatientAppointmentsProvider>();
    final patient = context.read<AppointmentsRepository>().patientForUser(
      auth.user?.uid,
    );
    final patientId = patient?.id ?? auth.user?.uid ?? '';
    final patientName = auth.profileName;

    final appointments = provider.upcomingAppointmentsFor(patientId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Appointments',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(width: 12),
            AppButton(
              label: 'Request Slot',
              icon: Icons.add_rounded,
              size: AppButtonSize.small,
              onPressed: () => _showBookingDialog(
                context,
                patientId: patientId,
                patientName: patientName,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Track requested and confirmed appointments.',
          style: TextStyle(color: AppColors.mutedForeground, fontSize: 15),
        ),
        const SizedBox(height: 24),
        if (appointments.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: AppDecorations.card(),
            child: Row(
              children: [
                Icon(
                  Icons.event_busy_rounded,
                  color: AppColors.mutedForeground,
                ),
                const SizedBox(width: 12),
                const Expanded(child: Text('No appointment requests yet.')),
                AppButton(
                  label: 'Book',
                  size: AppButtonSize.small,
                  onPressed: () => _showBookingDialog(
                    context,
                    patientId: patientId,
                    patientName: patientName,
                  ),
                ),
              ],
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 16.0;
              final columns = isDesktop ? 2 : 1;
              final itemWidth = columns == 1
                  ? constraints.maxWidth
                  : (constraints.maxWidth - spacing) / 2;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: appointments.map((appointment) {
                  return SizedBox(
                    width: itemWidth,
                    child: _AppointmentTile(appointment: appointment),
                  );
                }).toList(),
              );
            },
          ),
      ],
    );
  }
}

class _AppointmentTile extends StatelessWidget {
  const _AppointmentTile({required this.appointment});

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<AppointmentsRepository>();
    final doctor = repo.doctorById(appointment.doctorId);
    final isReviewed = repo.isAppointmentReviewed(appointment.id);
    final isCompletedOrPast = appointment.status.toLowerCase() == 'completed' ||
        appointment.date.isBefore(DateTime.now());

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.medical_services_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.doctor,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${appointment.specialty} • ${appointment.clinic}',
                      style: TextStyle(
                        color: AppColors.mutedForeground,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${DateFormat('d MMM yyyy', 'en_IN').format(appointment.date)} • ${appointment.time}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      appointment.type,
                      style: TextStyle(
                        color: AppColors.mutedForeground,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.muted,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      appointment.status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ),
                  if (appointment.hasPrescription) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF10B981).withValues(alpha: 0.35),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.receipt_long_rounded,
                            size: 11,
                            color: Color(0xFF10B981),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Rx Available',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              if (appointment.isVideoConsultation)
                Expanded(
                  child: VideoConsultationActions(
                    appointment: appointment,
                    contactPhone: doctor?.phone ?? '',
                  ),
                )
              else
                const Spacer(),
              if (appointment.hasPrescription) ...[
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    _showPrescriptionViewDialog(
                      context,
                      appointment: appointment,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF10B981).withValues(alpha: 0.35),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.receipt_long_rounded,
                          size: 14,
                          color: Color(0xFF10B981),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'View Prescription & Notes',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (isReviewed)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.warning.withOpacity(0.35)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_rounded, size: 14, color: AppColors.warning),
                      const SizedBox(width: 4),
                      Text(
                        'Feedback Sent',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                )
              else if (isCompletedOrPast)
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    _showAddReviewDialog(
                      context,
                      appointment: appointment,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.warning.withOpacity(0.35),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.rate_review_rounded, size: 14, color: AppColors.warning),
                        const SizedBox(width: 6),
                        Text(
                          'Rate Consultation',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  CommunicationSheet.show(
                    context,
                    recipientName: appointment.doctor,
                    recipientRole: 'Doctor',
                    phone: doctor?.phone ?? '',
                    isScheduled: appointment.status.toLowerCase() != 'cancelled',
                    scheduledTime:
                        '${DateFormat('d MMM').format(appointment.date)} at ${appointment.time}',
                    statusText: '${appointment.specialty} • ${appointment.clinic}',
                    meetingLink: appointment.meetingLink,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                      Icon(Icons.phone_in_talk_rounded, size: 14, color: Color(0xFF25D366)),
                      SizedBox(width: 6),
                      Text(
                        'Call / WhatsApp',
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
            ],
          ),
        ],
      ),
    );
  }
}

void _showPrescriptionViewDialog(
  BuildContext context, {
  required Appointment appointment,
}) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) {
      final dateStr = appointment.prescriptionDate != null
          ? DateFormat('d MMM yyyy, hh:mm a', 'en_IN')
              .format(appointment.prescriptionDate!)
          : DateFormat('d MMM yyyy', 'en_IN').format(appointment.date);

      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520, maxHeight: 680),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
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
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(28)),
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
                        Icons.receipt_long_rounded,
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
                            'Doctor\'s Prescription & Advice',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Dr. ${appointment.doctor} • ${appointment.specialty}',
                            style: const TextStyle(
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Clinic & Consultation Info Banner
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.muted,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.local_hospital_rounded,
                              size: 20,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    appointment.clinic,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    'Consultation Date: $dateStr',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.mutedForeground,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Medications / Rx
                      if (appointment.prescription.isNotEmpty) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.medication_rounded,
                                  size: 18,
                                  color: Color(0xFF10B981),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Prescribed Medications (Rx)',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            TextButton.icon(
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(text: appointment.prescription),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Prescription copied to clipboard!'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.copy_rounded, size: 14),
                              label: const Text('Copy',
                                  style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981)
                                .withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF10B981)
                                  .withValues(alpha: 0.25),
                            ),
                          ),
                          child: Text(
                            appointment.prescription,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.6,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Doctor Notes & Clinical Advice
                      if (appointment.doctorNotes.isNotEmpty) ...[
                        const Row(
                          children: [
                            Icon(
                              Icons.notes_rounded,
                              size: 18,
                              color: Color(0xFF3B82F6),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Clinical Notes & Doctor\'s Advice',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6)
                                .withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF3B82F6)
                                  .withValues(alpha: 0.25),
                            ),
                          ),
                          child: Text(
                            appointment.doctorNotes,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.6,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Digital Authenticity stamp
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.verified_rounded,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Verified digital prescription issued by Dr. ${appointment.doctor} on MentiFit Swasthya Vault.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.mutedForeground,
                                  fontStyle: FontStyle.italic,
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

              // Footer
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('Close'),
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
}

void _showAddReviewDialog(BuildContext context, {required Appointment appointment}) {
  double selectedRating = 5.0;
  final commentController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 480),
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
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.star_rate_rounded, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Rate Your Consultation',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'With ${appointment.doctor}',
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
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'How was your experience?',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.foreground,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Your review helps other patients and gives feedback to the doctor.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: AppColors.mutedForeground),
                          ),
                          const SizedBox(height: 16),
                          // Star Selector
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (index) {
                              final starNum = index + 1.0;
                              return IconButton(
                                iconSize: 36,
                                onPressed: () {
                                  setState(() => selectedRating = starNum);
                                },
                                icon: Icon(
                                  starNum <= selectedRating
                                      ? Icons.star_rounded
                                      : Icons.star_border_rounded,
                                  color: AppColors.warning,
                                ),
                              );
                            }),
                          ),
                          Text(
                            selectedRating == 5.0
                                ? 'Excellent'
                                : selectedRating == 4.0
                                    ? 'Good'
                                    : selectedRating == 3.0
                                        ? 'Average'
                                        : selectedRating == 2.0
                                            ? 'Below Average'
                                            : 'Poor',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.warning,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: commentController,
                            maxLines: 3,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please write a brief feedback comment';
                              }
                              if (val.trim().length < 4) {
                                return 'Feedback must be at least 4 characters';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Consultation Feedback / Review *',
                              hintText: 'Share how the doctor helped you, diagnosis clarity, wait time...',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Actions
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.muted.withOpacity(0.4),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
                      border: Border(top: BorderSide(color: AppColors.border)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              if (!formKey.currentState!.validate()) return;
                              Navigator.of(dialogContext).pop();
                              final repo = context.read<AppointmentsRepository>();
                              await repo.addDoctorReview(
                                doctorId: appointment.doctorId,
                                doctorName: appointment.doctor,
                                patientId: appointment.patientId,
                                patientName: appointment.patient,
                                rating: selectedRating,
                                comment: commentController.text.trim(),
                                appointmentId: appointment.id,
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Thank you! Your feedback has been submitted.'),
                                    backgroundColor: AppColors.primary,
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.send_rounded, size: 16),
                            label: const Text('Submit Review'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
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
