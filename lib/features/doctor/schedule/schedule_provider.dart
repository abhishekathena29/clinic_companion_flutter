import 'package:flutter/material.dart';
import '../../../shared/appointments_repository.dart';

class ScheduleProvider extends ChangeNotifier {
  ScheduleProvider(this._repository) {
    _repository.addListener(_handleRepositoryUpdate);
  }

  final AppointmentsRepository _repository;
  DateTime _selectedDate = DateTime.now();

  DateTime get selectedDate => _selectedDate;

  List<DateTime> get upcomingDays => List.generate(7, (index) {
        final base = DateTime.now();
        return DateTime(base.year, base.month, base.day + index);
      });

  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  List<Appointment> get appointmentsForSelectedDate {
    return _repository.forDate(_selectedDate);
  }

  void addAppointment({
    required String patient,
    required DateTime date,
    required String time,
    required String type,
    required String duration,
    String status = 'Pending',
  }) {
    _repository.addAppointment(
      patient: patient,
      doctor: 'Dr. Rajesh Mehra',
      specialty: 'Cardiology',
      clinic: 'City Care Clinic',
      date: date,
      time: time,
      type: type,
      duration: duration,
      status: status,
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
