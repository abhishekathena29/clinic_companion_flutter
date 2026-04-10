import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/appointments_repository.dart';
import '../../../widgets/stat_card.dart';

class DashboardStat {
  const DashboardStat({
    required this.title,
    required this.value,
    required this.change,
    required this.changeType,
    required this.icon,
    required this.variant,
  });

  final String title;
  final String value;
  final String change;
  final StatChangeType changeType;
  final IconData icon;
  final StatVariant variant;
}

class DashboardProvider extends ChangeNotifier {
  DashboardProvider(this._repository) {
    _repository.addListener(_handleRepositoryUpdate);
  }

  final AppointmentsRepository _repository;

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String get today =>
      DateFormat('EEEE, d MMMM yyyy', 'en_IN').format(DateTime.now());
  String get shortDate =>
      DateFormat('EEE, d MMM', 'en_IN').format(DateTime.now());

  List<DashboardStat> statsForDoctor(String doctorId) {
    final doctorAppointments = _repository.forDoctor(doctorId);
    final doctorQueue = _repository.queueForDoctor(doctorId);
    final todayStart = DateTime.now();
    final todayAppointments = doctorAppointments.where((appointment) {
      return appointment.date.year == todayStart.year &&
          appointment.date.month == todayStart.month &&
          appointment.date.day == todayStart.day;
    }).toList();
    final patientIds = doctorAppointments
        .map((appointment) => appointment.patientId)
        .where((value) => value.isNotEmpty)
        .toSet();
    final todayPatientIds = todayAppointments
        .map((appointment) => appointment.patientId)
        .where((value) => value.isNotEmpty)
        .toSet();
    final linkedPatients = _repository.patients.where((patient) {
      return patientIds.contains(patient.id) || patientIds.contains(patient.userId);
    }).toList();
    final todayLinkedPatients = _repository.patients.where((patient) {
      return todayPatientIds.contains(patient.id) ||
          todayPatientIds.contains(patient.userId);
    }).toList();
    final waitingEntries = doctorQueue
        .where((entry) => entry.status == QueueStatus.waiting)
        .toList();
    final pendingFollowUps = doctorAppointments
        .where((appointment) => appointment.status.toLowerCase() == 'pending')
        .length;
    final pendingTodayAppointments = todayAppointments
        .where((appointment) => appointment.status.toLowerCase() == 'pending')
        .length;
    final averageWait = waitingEntries.isEmpty
        ? 0
        : (waitingEntries.fold<int>(0, (sum, entry) => sum + entry.waitTime) /
                  waitingEntries.length)
              .round();

    return [
      DashboardStat(
        title: "Today's Patients",
        value: '${todayLinkedPatients.length}',
        change: '${linkedPatients.length} total tracked',
        changeType: StatChangeType.positive,
        icon: Icons.people,
        variant: StatVariant.primary,
      ),
      DashboardStat(
        title: 'Appointments',
        value: '${todayAppointments.length}',
        change: '$pendingTodayAppointments pending today',
        changeType: StatChangeType.neutral,
        icon: Icons.calendar_today,
        variant: StatVariant.info,
      ),
      DashboardStat(
        title: 'Avg. Wait Time',
        value: '$averageWait min',
        change: '${waitingEntries.length} patients in queue',
        changeType: averageWait <= 15
            ? StatChangeType.positive
            : StatChangeType.neutral,
        icon: Icons.access_time,
        variant: StatVariant.success,
      ),
      DashboardStat(
        title: 'Pending Follow-ups',
        value: '$pendingFollowUps',
        change: '${doctorAppointments.length} total scheduled',
        changeType: pendingFollowUps > 0
            ? StatChangeType.negative
            : StatChangeType.positive,
        icon: Icons.warning_amber,
        variant: StatVariant.warning,
      ),
    ];
  }

  void _handleRepositoryUpdate() {
    notifyListeners();
  }

  @override
  void dispose() {
    _repository.removeListener(_handleRepositoryUpdate);
    super.dispose();
  }
}
