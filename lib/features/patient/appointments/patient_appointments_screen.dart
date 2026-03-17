import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../features/auth/auth_provider.dart';
import '../../../shared/appointments_repository.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_decorations.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/patient_layout.dart';
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

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: const Text('Request Appointment'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
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
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => selected = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: reasonController,
                      decoration: const InputDecoration(
                        labelText: 'Reason',
                        prefixIcon: Icon(Icons.edit_note_rounded),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: timeController,
                      decoration: const InputDecoration(
                        labelText: 'Preferred time',
                        prefixIcon: Icon(Icons.access_time_rounded),
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: dialogContext,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 60),
                          ),
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
                  label: 'Request',
                  onPressed: () {
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
                    );
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
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<PatientAppointmentsProvider>();
    final patient = context.read<AppointmentsRepository>().patientForUser(
      auth.user?.uid,
    );
    final patientId = patient?.id ?? auth.user?.uid ?? '';
    final patientName = auth.profileName;

    final appointments = provider.upcomingAppointmentsFor(patientId);

    return PatientLayout(
      routeName: '/patient/appointments',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Appointments',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
              ),
              AppButton(
                label: 'Request Slot',
                icon: Icons.add_rounded,
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
            GridView.count(
              crossAxisCount: isDesktop ? 2 : 1,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isDesktop ? 2.6 : 1.9,
              children: appointments.map((appointment) {
                return _AppointmentTile(appointment: appointment);
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _AppointmentTile extends StatelessWidget {
  const _AppointmentTile({required this.appointment});

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.card(),
      child: Row(
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
        ],
      ),
    );
  }
}
