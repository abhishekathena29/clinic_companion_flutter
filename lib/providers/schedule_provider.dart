import 'package:flutter/material.dart';

class Appointment {
  const Appointment({
    required this.id,
    required this.patient,
    required this.time,
    required this.type,
    required this.duration,
    required this.status,
    required this.date,
  });

  final String id;
  final String patient;
  final String time;
  final String type;
  final String duration;
  final String status;
  final DateTime date;
}

class ScheduleProvider extends ChangeNotifier {
  DateTime _selectedDate = DateTime.now();

  DateTime get selectedDate => _selectedDate;

  final List<Appointment> _appointments = [
    Appointment(
      id: 'ap-1',
      patient: 'Priya Sharma',
      time: '09:30 AM',
      type: 'Follow-up',
      duration: '20 min',
      status: 'Confirmed',
      date: DateTime.now(),
    ),
    Appointment(
      id: 'ap-2',
      patient: 'Amit Patel',
      time: '10:15 AM',
      type: 'New Consultation',
      duration: '30 min',
      status: 'Checked-in',
      date: DateTime.now(),
    ),
    Appointment(
      id: 'ap-3',
      patient: 'Sunita Devi',
      time: '11:45 AM',
      type: 'Vitals Review',
      duration: '15 min',
      status: 'Pending',
      date: DateTime.now(),
    ),
    Appointment(
      id: 'ap-4',
      patient: 'Rahul Singh',
      time: '02:00 PM',
      type: 'Diagnostics',
      duration: '40 min',
      status: 'Confirmed',
      date: DateTime.now(),
    ),
    Appointment(
      id: 'ap-5',
      patient: 'Meera Joshi',
      time: '03:30 PM',
      type: 'Follow-up',
      duration: '20 min',
      status: 'Pending',
      date: DateTime.now().add(const Duration(days: 1)),
    ),
    Appointment(
      id: 'ap-6',
      patient: 'Vikram Rao',
      time: '04:10 PM',
      type: 'Lab Review',
      duration: '15 min',
      status: 'Confirmed',
      date: DateTime.now().add(const Duration(days: 2)),
    ),
  ];

  List<DateTime> get upcomingDays => List.generate(7, (index) {
        final base = DateTime.now();
        return DateTime(base.year, base.month, base.day + index);
      });

  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  List<Appointment> get appointmentsForSelectedDate {
    return _appointments.where((appointment) {
      return appointment.date.year == _selectedDate.year &&
          appointment.date.month == _selectedDate.month &&
          appointment.date.day == _selectedDate.day;
    }).toList();
  }

  void addAppointment({
    required String patient,
    required DateTime date,
    required String time,
    required String type,
    required String duration,
    String status = 'Pending',
  }) {
    _appointments.insert(
      0,
      Appointment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        patient: patient,
        time: time,
        type: type,
        duration: duration,
        status: status,
        date: date,
      ),
    );
    notifyListeners();
  }
}
