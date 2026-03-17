import 'package:flutter/material.dart';
import '../../../shared/appointments_repository.dart';

class PatientAppointmentsProvider extends ChangeNotifier {
  PatientAppointmentsProvider(this._repository) {
    _repository.addListener(_handleRepositoryUpdate);
  }

  final AppointmentsRepository _repository;

  List<Appointment> upcomingAppointmentsFor(String patientId) {
    final now = DateTime.now();
    final list = _repository.forPatient(patientId);
    list.sort((a, b) => a.date.compareTo(b.date));
    return list
        .where((a) => !a.date.isBefore(DateTime(now.year, now.month, now.day)))
        .toList();
  }

  Future<void> bookAppointment({
    required String patientId,
    required String patientName,
    required String doctorId,
    required String doctor,
    required String specialty,
    required String clinic,
    required DateTime date,
    required String time,
    required String reason,
  }) {
    return _repository.addAppointment(
      patientId: patientId,
      patient: patientName.trim().isEmpty ? 'You' : patientName.trim(),
      doctorId: doctorId,
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
