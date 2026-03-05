import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../features/auth/auth_provider.dart';
import '../../../shared/appointments_repository.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_decorations.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/patient_layout.dart';
import 'patient_dashboard_provider.dart';

class PatientDashboardScreen extends StatelessWidget {
  const PatientDashboardScreen({super.key});

  bool _isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 768;

  @override
  Widget build(BuildContext context) {
    final isDesktop = _isDesktop(context);
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<PatientDashboardProvider>();
    provider.updatePatientName(auth.profileName);

    final today = DateFormat('d MMMM yyyy', 'en_IN').format(DateTime.now());
    final appointments = provider.upcomingAppointments;

    return PatientLayout(
      routeName: '/patient',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${provider.greeting}, ${provider.patientName}',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            today,
            style: TextStyle(color: AppColors.mutedForeground, fontSize: 15),
          ),
          const SizedBox(height: 24),
          if (isDesktop)
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    title: 'Book Appointment',
                    subtitle: 'Find specialists near you',
                    icon: Icons.event_available_rounded,
                    onTap: () => Navigator.of(context).pushReplacementNamed('/patient/doctors'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _QuickActionCard(
                    title: 'My Doctors',
                    subtitle: 'Revisit your recent visits',
                    icon: Icons.medical_services_rounded,
                    onTap: () => Navigator.of(context).pushReplacementNamed('/patient/doctors'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _QuickActionCard(
                    title: 'Appointments',
                    subtitle: 'Track your upcoming slots',
                    icon: Icons.schedule_rounded,
                    onTap: () =>
                        Navigator.of(context).pushReplacementNamed('/patient/appointments'),
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                _QuickActionCard(
                  title: 'Book Appointment',
                  subtitle: 'Find specialists near you',
                  icon: Icons.event_available_rounded,
                  onTap: () => Navigator.of(context).pushReplacementNamed('/patient/doctors'),
                ),
                const SizedBox(height: 12),
                _QuickActionCard(
                  title: 'My Doctors',
                  subtitle: 'Revisit your recent visits',
                  icon: Icons.medical_services_rounded,
                  onTap: () => Navigator.of(context).pushReplacementNamed('/patient/doctors'),
                ),
                const SizedBox(height: 12),
                _QuickActionCard(
                  title: 'Appointments',
                  subtitle: 'Track your upcoming slots',
                  icon: Icons.schedule_rounded,
                  onTap: () => Navigator.of(context).pushReplacementNamed('/patient/appointments'),
                ),
              ],
            ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Upcoming Appointments',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pushReplacementNamed('/patient/appointments'),
                child: const Text('View all'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (appointments.isEmpty)
            Container(
              decoration: AppDecorations.card(),
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.muted,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.event_busy_rounded,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'No upcoming appointments yet. Book a slot with a specialist.',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  AppButton(
                    label: 'Book',
                    size: AppButtonSize.small,
                    onPressed: () =>
                        Navigator.of(context).pushReplacementNamed('/patient/doctors'),
                  ),
                ],
              ),
            )
          else
            Column(
              children: appointments.take(3).map((appointment) {
                return _AppointmentCard(appointment: appointment);
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: AppDecorations.card(),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: AppColors.gradientPrimary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: AppColors.mutedForeground, fontSize: 13),
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

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({required this.appointment});

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: AppDecorations.card(),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.4),
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
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '${appointment.specialty} • ${appointment.clinic}',
                  style: TextStyle(color: AppColors.mutedForeground, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Text(
                  '${DateFormat('d MMM', 'en_IN').format(appointment.date)} • ${appointment.time}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
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
