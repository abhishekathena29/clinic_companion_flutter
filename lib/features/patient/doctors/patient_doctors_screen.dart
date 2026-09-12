import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../features/auth/auth_provider.dart';
import '../../../shared/appointments_repository.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_decorations.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/consultation_mode_toggle.dart';
import '../appointments/patient_appointments_provider.dart';
import 'patient_doctors_provider.dart';

class PatientDoctorsScreen extends StatelessWidget {
  const PatientDoctorsScreen({super.key});

  bool _isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 768;

  Future<void> _showBookingDialog(
    BuildContext context,
    DoctorProfile doctor, {
    required String patientId,
    required String patientName,
  }) async {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    final timeController = TextEditingController(text: '10:30 AM');
    final reasonController = TextEditingController(text: 'General Consultation');
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
                    // Header with Doctor Preview
                    Container(
                      padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
                      decoration: BoxDecoration(
                        gradient: AppColors.gradientHero,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              doctor.name.isNotEmpty
                                  ? doctor.name.substring(0, 1).toUpperCase()
                                  : 'D',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doctor.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${doctor.specialty} • ${doctor.clinic}',
                                  style: TextStyle(
                                    fontSize: 13,
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

                    // Scrollable Options
                    Flexible(
                      child: Form(
                        key: formKey,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                            // Consultation Mode
                            Text(
                              'Consultation Type',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.mutedForeground,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ConsultationModeToggle(
                              mode: consultationMode,
                              onChanged: (value) => setState(() => consultationMode = value),
                            ),
                            const SizedBox(height: 20),

                            // Date Picker Card
                            Text(
                              'Select Date',
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
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryLight.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        Icons.calendar_month_rounded,
                                        size: 20,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            DateFormat('EEEE, d MMMM yyyy').format(selectedDate),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Tap to select another date',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: AppColors.mutedForeground,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_drop_down_rounded,
                                      color: AppColors.mutedForeground,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Preferred Time Slots
                            Text(
                              'Preferred Time Slot',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.mutedForeground,
                              ),
                            ),
                            const SizedBox(height: 10),
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
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: timeController,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Please select or enter preferred time';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                labelText: 'Or Custom Time',
                                hintText: 'e.g. 11:15 AM',
                                prefixIcon: Icon(Icons.access_time_rounded),
                              ),
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
                            const SizedBox(height: 10),
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
                            const SizedBox(height: 10),
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
                        children: [
                          if (doctor.fee > 0) ...[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Fee',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.mutedForeground,
                                  ),
                                ),
                                Text(
                                  '₹${doctor.fee}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                          ] else
                            const Spacer(),
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
                            label: 'Confirm Slot',
                            icon: Icons.calendar_today_rounded,
                            onPressed: () {
                              if (!formKey.currentState!.validate()) return;
                              context.read<PatientAppointmentsProvider>().bookAppointment(
                                patientId: patientId,
                                patientName: patientName,
                                doctorId: doctor.id,
                                doctor: doctor.name,
                                specialty: doctor.specialty,
                                clinic: doctor.clinic,
                                date: selectedDate,
                                time: timeController.text.trim(),
                                reason: reasonController.text.trim(),
                                consultationMode: consultationMode,
                              );
                              Navigator.of(dialogContext).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Appointment requested with ${doctor.name}!'),
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
    final provider = context.watch<PatientDoctorsProvider>();
    final patient = context.read<AppointmentsRepository>().patientForUser(
      auth.user?.uid,
    );
    final patientId = patient?.id ?? auth.user?.uid ?? '';
    final patientName = auth.profileName;
    final doctors = provider.doctors
        .where((d) => d.experienceYears > 0 || d.profileCompleted)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Find Doctors',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        Text(
          'Browse verified specialists, reviews, and book consultations in minutes.',
          style: TextStyle(color: AppColors.mutedForeground, fontSize: 15),
        ),
        const SizedBox(height: 24),
        if (doctors.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: AppDecorations.card(),
            alignment: Alignment.center,
            child: Column(
              children: [
                Icon(Icons.medical_information_outlined, size: 48, color: AppColors.mutedForeground),
                const SizedBox(height: 12),
                const Text(
                  'No doctors available currently',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Check back shortly as doctors set up their availability.',
                  style: TextStyle(color: AppColors.mutedForeground, fontSize: 13),
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
                children: doctors.map((doctor) {
                  return SizedBox(
                    width: itemWidth,
                    child: _DoctorCard(
                      doctor: doctor,
                      onBook: () => _showBookingDialog(
                        context,
                        doctor,
                        patientId: patientId,
                        patientName: patientName,
                      ),
                      onViewDetails: () => _showDoctorProfileAndReviewsDialog(
                        context,
                        doctor,
                        patientId: patientId,
                        patientName: patientName,
                        onBook: () => _showBookingDialog(
                          context,
                          doctor,
                          patientId: patientId,
                          patientName: patientName,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
      ],
    );
  }
}

class _DoctorCard extends StatelessWidget {
  const _DoctorCard({
    required this.doctor,
    required this.onBook,
    required this.onViewDetails,
  });

  final DoctorProfile doctor;
  final VoidCallback onBook;
  final VoidCallback onViewDetails;

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<AppointmentsRepository>();
    final reviews = repo.reviewsForDoctor(doctor.id);
    final reviewCount = doctor.reviewCount > 0 ? doctor.reviewCount : reviews.length;

    return InkWell(
      onTap: onViewDetails,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: AppDecorations.card(),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: AppColors.gradientHero,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    doctor.name.isNotEmpty
                        ? doctor.name.substring(0, doctor.name.length >= 2 ? 2 : 1).toUpperCase()
                        : 'DR',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
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
                          Expanded(
                            child: Text(
                              doctor.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          if (doctor.fee > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '₹${doctor.fee}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (doctor.qualifications.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          doctor.qualifications,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        '${doctor.specialty} • ${doctor.experienceYears} yrs exp',
                        style: TextStyle(
                          color: AppColors.mutedForeground,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: doctor.rating > 0 ? AppColors.warning : AppColors.mutedForeground,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            doctor.rating > 0 ? doctor.rating.toStringAsFixed(1) : 'New',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                          if (reviewCount > 0) ...[
                            const SizedBox(width: 4),
                            Text(
                              '($reviewCount)',
                              style: TextStyle(
                                color: AppColors.mutedForeground,
                                fontSize: 11,
                              ),
                            ),
                          ],
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              doctor.clinic,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.mutedForeground,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: onViewDetails,
                  icon: const Icon(Icons.info_outline_rounded, size: 16),
                  label: const Text('Profile & Reviews', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  ),
                ),
                AppButton(
                  label: 'Book Consultation',
                  size: AppButtonSize.small,
                  onPressed: onBook,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void _showDoctorProfileAndReviewsDialog(
  BuildContext context,
  DoctorProfile doctor, {
  required String patientId,
  required String patientName,
  required VoidCallback onBook,
}) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) {
      final repo = context.watch<AppointmentsRepository>();
      final reviews = repo.reviewsForDoctor(doctor.id);
      final reviewCount = doctor.reviewCount > 0 ? doctor.reviewCount : reviews.length;

      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 580, maxHeight: 720),
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
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        doctor.name.isNotEmpty
                            ? doctor.name.substring(0, doctor.name.length >= 2 ? 2 : 1).toUpperCase()
                            : 'DR',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            [
                              if (doctor.qualifications.isNotEmpty) doctor.qualifications,
                              doctor.specialty,
                            ].join(' • '),
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quick credential badges
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.timeline_rounded, size: 14, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Text(
                                  '${doctor.experienceYears} Years Experience',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star_rounded, size: 15, color: AppColors.warning),
                                const SizedBox(width: 4),
                                Text(
                                  doctor.rating > 0 ? doctor.rating.toStringAsFixed(1) : 'New',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                                const SizedBox(width: 4),
                                Text('($reviewCount reviews)', style: const TextStyle(fontSize: 11)),
                              ],
                            ),
                          ),
                          if (doctor.fee > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.muted,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Fee: ₹${doctor.fee}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Clinic and Location
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.muted.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.local_hospital_rounded, size: 16, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    doctor.clinic,
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                            if (doctor.location.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(Icons.location_on_rounded, size: 16, color: AppColors.mutedForeground),
                                  const SizedBox(width: 8),
                                  Text(
                                    doctor.location,
                                    style: TextStyle(color: AppColors.mutedForeground, fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (doctor.bio.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'About Doctor',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          doctor.bio,
                          style: TextStyle(color: AppColors.foreground.withOpacity(0.85), fontSize: 13, height: 1.4),
                        ),
                      ],
                      const SizedBox(height: 20),
                      // Patient Reviews Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Patient Reviews & Feedback',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          Text(
                            '$reviewCount verified',
                            style: TextStyle(fontSize: 12, color: AppColors.mutedForeground),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (reviews.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.muted.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'No reviews yet. Reviews will be submitted by patients after completing their consultations.',
                            style: TextStyle(color: AppColors.mutedForeground, fontSize: 12),
                          ),
                        )
                      else
                        Column(
                          children: reviews.map((r) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.muted.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          r.patientName,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                      ),
                                      Row(
                                        children: List.generate(5, (i) => Icon(
                                          i < r.rating ? Icons.star_rounded : Icons.star_border_rounded,
                                          size: 14,
                                          color: AppColors.warning,
                                        )),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        DateFormat('d MMM').format(r.createdAt),
                                        style: TextStyle(color: AppColors.mutedForeground, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                  if (r.comment.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      r.comment,
                                      style: TextStyle(fontSize: 12, color: AppColors.foreground.withOpacity(0.9)),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ),

              // Footer Action
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
                        child: const Text('Close'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          onBook();
                        },
                        icon: const Icon(Icons.calendar_month_rounded, size: 18),
                        label: const Text('Book Consultation'),
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
}
