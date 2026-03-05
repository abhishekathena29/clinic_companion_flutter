import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_decorations.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/patient_layout.dart';
import '../appointments/patient_appointments_provider.dart';
import 'patient_doctors_provider.dart';

class PatientDoctorsScreen extends StatelessWidget {
  const PatientDoctorsScreen({super.key});

  bool _isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 768;

  Future<void> _showBookingDialog(
    BuildContext context,
    DoctorProfile doctor,
  ) async {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    final timeController = TextEditingController(text: '10:30 AM');
    final reasonController = TextEditingController(text: 'Consultation');

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text('Book with ${doctor.name}'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
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
                          lastDate: DateTime.now().add(const Duration(days: 60)),
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
                            DateFormat('d MMM yyyy', 'en_IN').format(selectedDate),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                AppButton(
                  label: 'Request Slot',
                  onPressed: () {
                    context.read<PatientAppointmentsProvider>().bookAppointment(
                          doctor: doctor.name,
                          specialty: doctor.specialty,
                          clinic: doctor.clinic,
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
    final provider = context.watch<PatientDoctorsProvider>();
    final doctors = provider.doctors;

    return PatientLayout(
      routeName: '/patient/doctors',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Find Doctors',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            'Browse specialists and book consultations in minutes.',
            style: TextStyle(color: AppColors.mutedForeground, fontSize: 15),
          ),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: isDesktop ? 2 : 1,
            shrinkWrap: true,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: isDesktop ? 2.7 : 1.8,
            children: doctors.map((doctor) {
              return _DoctorCard(
                doctor: doctor,
                onBook: () => _showBookingDialog(context, doctor),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  const _DoctorCard({required this.doctor, required this.onBook});

  final DoctorProfile doctor;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.card(),
      child: Row(
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
              doctor.name.substring(0, 2).toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  '${doctor.specialty} • ${doctor.experienceYears} yrs exp',
                  style: TextStyle(color: AppColors.mutedForeground, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.star_rounded, size: 16, color: AppColors.warning),
                    const SizedBox(width: 4),
                    Text(
                      doctor.rating.toStringAsFixed(1),
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      doctor.clinic,
                      style: TextStyle(color: AppColors.mutedForeground, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${doctor.location} • ₹${doctor.fee}',
                  style: TextStyle(color: AppColors.mutedForeground, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                doctor.nextAvailable,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Book',
                size: AppButtonSize.small,
                onPressed: onBook,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
