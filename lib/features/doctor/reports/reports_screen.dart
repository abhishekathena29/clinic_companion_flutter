import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../shared/appointments_repository.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_decorations.dart';
import '../../../widgets/mobile_header.dart';
import '../../auth/auth_provider.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  bool _isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 768;

  @override
  Widget build(BuildContext context) {
    final isDesktop = _isDesktop(context);
    final auth = context.watch<AuthProvider>();
    final repository = context.watch<AppointmentsRepository>();
    final doctorId = auth.user?.uid ?? '';
    final doctorName = auth.profileName.isEmpty ? 'Doctor' : auth.profileName;
    final appointments = repository.forDoctor(doctorId)
      ..sort((a, b) => b.date.compareTo(a.date));
    final patientIds = appointments
        .map((appointment) => appointment.patientId)
        .where((id) => id.isNotEmpty)
        .toSet();
    final patients =
        repository.patients
            .where(
              (patient) =>
                  patientIds.contains(patient.id) ||
                  patientIds.contains(patient.userId),
            )
            .toList()
          ..sort((a, b) => b.lastVisit.compareTo(a.lastVisit));
    final pendingReports = appointments
        .where((appointment) => appointment.status.toLowerCase() == 'pending')
        .length;

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isDesktop)
            const MobileHeader(title: 'Reports', showSearch: false),
          if (isDesktop)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Patient Reports for $doctorName',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Recent reports, follow-ups, and case summaries',
                  style: TextStyle(
                    color: AppColors.mutedForeground,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = isDesktop && constraints.maxWidth >= 980
                  ? (constraints.maxWidth - 32) / 3
                  : constraints.maxWidth;

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: _ReportSummaryCard(
                      title: 'Tracked Patients',
                      value: '${patients.length}',
                      subtitle: 'Patients linked to appointments',
                      icon: Icons.folder_shared_rounded,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _ReportSummaryCard(
                      title: 'Pending Follow-ups',
                      value: '$pendingReports',
                      subtitle: 'Visits that still need action',
                      icon: Icons.assignment_late_rounded,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _ReportSummaryCard(
                      title: 'Appointments Logged',
                      value: '${appointments.length}',
                      subtitle: 'Total visit records for this doctor',
                      icon: Icons.description_rounded,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          Container(
            decoration: AppDecorations.card(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Patient Reports',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
                if (patients.isEmpty)
                  Text(
                    'No patient reports are available yet.',
                    style: TextStyle(color: AppColors.mutedForeground),
                  )
                else
                  Column(
                    children: patients.map((patient) {
                      final patientAppointments = appointments
                          .where(
                            (appointment) =>
                                appointment.patientId == patient.id ||
                                appointment.patientId == patient.userId,
                          )
                          .toList();
                      return _PatientReportTile(
                        patient: patient,
                        latestAppointment: patientAppointments.isEmpty
                            ? null
                            : patientAppointments.first,
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ],
    );
  }
}

class _ReportSummaryCard extends StatelessWidget {
  const _ReportSummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.card(),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.mutedForeground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
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
}

class _PatientReportTile extends StatelessWidget {
  const _PatientReportTile({
    required this.patient,
    required this.latestAppointment,
  });

  final Patient patient;
  final Appointment? latestAppointment;

  @override
  Widget build(BuildContext context) {
    final initials = patient.name
        .split(' ')
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part.substring(0, 1).toUpperCase())
        .join();
    final lastVisit = patient.lastVisit.trim().isEmpty
        ? 'No visits yet'
        : (DateTime.tryParse(patient.lastVisit) == null
              ? patient.lastVisit
              : DateFormat(
                  'd MMM yyyy',
                  'en_IN',
                ).format(DateTime.parse(patient.lastVisit)));

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.muted.withOpacity(0.35),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.primary.withOpacity(0.12),
            foregroundColor: AppColors.primary,
            child: Text(initials.isEmpty ? 'PT' : initials),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${patient.patientId} • Last visit: $lastVisit',
                  style: TextStyle(
                    color: AppColors.mutedForeground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  latestAppointment == null
                      ? 'No appointment note available yet.'
                      : '${latestAppointment!.type} with status ${latestAppointment!.status} on ${DateFormat('d MMM yyyy', 'en_IN').format(latestAppointment!.date)} at ${latestAppointment!.time}',
                  style: TextStyle(color: AppColors.foreground),
                ),
                if (patient.conditions.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: patient.conditions.map((condition) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          condition,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.warningForeground,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
