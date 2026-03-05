import 'package:flutter/material.dart';
import '../../../shared/appointments_repository.dart';

class PatientAppointmentsProvider extends ChangeNotifier {
  PatientAppointmentsProvider(this._repository) {
    _repository.addListener(_handleRepositoryUpdate);
  }

  final AppointmentsRepository _repository;
  String _patientName = 'You';

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

  void bookAppointment({
    required String doctor,
    required String specialty,
    required String clinic,
    required DateTime date,
    required String time,
    required String reason,
  }) {
    _repository.addAppointment(
      patient: _patientName,
      doctor: doctor,
      specialty: specialty,
      clinic: clinic,
      date: date,
      time: time,
      type: reason,
      duration: '20 min',
      status: 'Pending',
    );
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
