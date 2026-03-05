import 'package:flutter/material.dart';
import '../../../shared/appointments_repository.dart';

class PatientDashboardProvider extends ChangeNotifier {
  PatientDashboardProvider(this._repository) {
    _repository.addListener(_handleRepositoryUpdate);
  }

  final AppointmentsRepository _repository;
  String _patientName = 'You';

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String get patientName => _patientName;

  void updatePatientName(String value) {
    final name = value.trim().isEmpty ? 'You' : value.trim();
    if (_patientName == name) return;
    _patientName = name;
    notifyListeners();
  }

  List<Appointment> get upcomingAppointments {
    final now = DateTime.now();
    final list = _repository.forPatient(_patientName);
    list.sort((a, b) => a.date.compareTo(b.date));
    return list.where((a) => !a.date.isBefore(DateTime(now.year, now.month, now.day))).toList();
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
