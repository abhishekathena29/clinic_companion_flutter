import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../shared/appointments_repository.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_decorations.dart';
import '../../../widgets/dashboard_layout.dart';
import '../../../widgets/header.dart';
import '../../../widgets/mobile_header.dart';
import '../../../widgets/stat_card.dart';
import '../../auth/auth_provider.dart';
import 'dashboard_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  bool _isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 768;

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
    final patientIds = appointments.map((item) => item.patientId).toSet();
    final patients =
        repository.patients
            .where((patient) => patientIds.contains(patient.id))
            .toList()
          ..sort((a, b) => b.lastVisit.compareTo(a.lastVisit));

    return DashboardLayout(
      routeName: '/doctor',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isDesktop)
            MobileHeader(title: '$greeting, $doctorName', subtitle: shortDate),
          if (isDesktop)
            Header(title: '$greeting, $doctorName', subtitle: today),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: isDesktop ? 4 : 2,
            mainAxisSpacing: isDesktop ? 24 : 12,
            crossAxisSpacing: isDesktop ? 24 : 12,
            childAspectRatio: isDesktop ? 1.6 : 1.35,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: provider
                .statsForDoctor(doctorId)
                .map(
                  (stat) => StatCard(
                    title: stat.title,
                    value: stat.value,
                    change: stat.change,
                    changeType: stat.changeType,
                    icon: stat.icon,
                    variant: stat.variant,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _QueuePreview(entries: queue.take(4).toList())),
                const SizedBox(width: 24),
                Expanded(
                  child: _AppointmentPreview(
                    appointments: appointments.take(5).toList(),
                  ),
                ),
              ],
            )
          else ...[
            _QueuePreview(entries: queue.take(4).toList()),
            const SizedBox(height: 16),
            _AppointmentPreview(appointments: appointments.take(5).toList()),
          ],
          const SizedBox(height: 24),
          _RecentPatientsCard(patients: patients.take(5).toList()),
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
          const Text(
            "Today's Queue",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
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
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              entry.reason,
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

class _AppointmentPreview extends StatelessWidget {
  const _AppointmentPreview({required this.appointments});

  final List<Appointment> appointments;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.card(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upcoming Appointments',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          if (appointments.isEmpty)
            Text(
              'No upcoming appointments yet.',
              style: TextStyle(color: AppColors.mutedForeground),
            )
          else
            Column(
              children: appointments.map((appointment) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.calendar_month_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  title: Text(
                    appointment.patient,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    '${DateFormat('d MMM', 'en_IN').format(appointment.date)} • ${appointment.time} • ${appointment.type}',
                    style: TextStyle(color: AppColors.mutedForeground),
                  ),
                  trailing: Text(
                    appointment.status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: appointment.status == 'Confirmed'
                          ? AppColors.success
                          : AppColors.warning,
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
          const Text(
            'Recent Patients',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          if (patients.isEmpty)
            Text(
              'Patient data will appear here once appointments are booked.',
              style: TextStyle(color: AppColors.mutedForeground),
            )
          else
            Column(
              children: patients.map((patient) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: AppColors.accent.withValues(alpha: 0.14),
                    foregroundColor: AppColors.accent,
                    child: Text(patient.name.substring(0, 1).toUpperCase()),
                  ),
                  title: Text(
                    patient.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    '${patient.patientId} • ${patient.phone.isEmpty ? 'No phone' : patient.phone}',
                    style: TextStyle(color: AppColors.mutedForeground),
                  ),
                  trailing: Text(
                    patient.lastVisit.isEmpty ? 'New' : patient.lastVisit,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.mutedForeground,
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
