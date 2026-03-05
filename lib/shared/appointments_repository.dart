import 'package:flutter/material.dart';

class Appointment {
  const Appointment({
    required this.id,
    required this.patient,
    required this.doctor,
    required this.time,
    required this.type,
    required this.duration,
    required this.status,
    required this.date,
    required this.specialty,
    required this.clinic,
  });

  final String id;
  final String patient;
  final String doctor;
  final String time;
  final String type;
  final String duration;
  final String status;
  final DateTime date;
  final String specialty;
  final String clinic;
}

class AppointmentsRepository extends ChangeNotifier {
  final List<Appointment> _appointments = [
    Appointment(
      id: 'ap-1',
      patient: 'Priya Sharma',
      doctor: 'Dr. Rajesh Mehra',
      time: '09:30 AM',
      type: 'Follow-up',
      duration: '20 min',
      status: 'Confirmed',
      date: DateTime.now(),
      specialty: 'Cardiology',
      clinic: 'City Care Clinic',
    ),
    Appointment(
      id: 'ap-2',
      patient: 'Amit Patel',
      doctor: 'Dr. Rajesh Mehra',
      time: '10:15 AM',
      type: 'New Consultation',
      duration: '30 min',
      status: 'Checked-in',
      date: DateTime.now(),
      specialty: 'Cardiology',
      clinic: 'City Care Clinic',
    ),
    Appointment(
      id: 'ap-3',
      patient: 'Sunita Devi',
      doctor: 'Dr. Rajesh Mehra',
      time: '11:45 AM',
      type: 'Vitals Review',
      duration: '15 min',
      status: 'Pending',
      date: DateTime.now(),
      specialty: 'Cardiology',
      clinic: 'City Care Clinic',
    ),
    Appointment(
      id: 'ap-4',
      patient: 'Rahul Singh',
      doctor: 'Dr. Rajesh Mehra',
      time: '02:00 PM',
      type: 'Diagnostics',
      duration: '40 min',
      status: 'Confirmed',
      date: DateTime.now(),
      specialty: 'Cardiology',
      clinic: 'City Care Clinic',
    ),
    Appointment(
      id: 'ap-5',
      patient: 'Meera Joshi',
      doctor: 'Dr. Rajesh Mehra',
      time: '03:30 PM',
      type: 'Follow-up',
      duration: '20 min',
      status: 'Pending',
      date: DateTime.now().add(const Duration(days: 1)),
      specialty: 'Cardiology',
      clinic: 'City Care Clinic',
    ),
    Appointment(
      id: 'ap-6',
      patient: 'Vikram Rao',
      doctor: 'Dr. Rajesh Mehra',
      time: '04:10 PM',
      type: 'Lab Review',
      duration: '15 min',
      status: 'Confirmed',
      date: DateTime.now().add(const Duration(days: 2)),
      specialty: 'Cardiology',
      clinic: 'City Care Clinic',
    ),
  ];

  List<Appointment> get all => List.unmodifiable(_appointments);

  List<Appointment> forDate(DateTime date) {
    return _appointments.where((appointment) {
      return appointment.date.year == date.year &&
          appointment.date.month == date.month &&
          appointment.date.day == date.day;
    }).toList();
  }

  List<Appointment> forPatient(String patientName) {
    return _appointments
        .where(
          (appointment) => appointment.patient.toLowerCase() == patientName.toLowerCase(),
        )
        .toList();
  }

  void addAppointment({
    required String patient,
    required String doctor,
    required String specialty,
    required String clinic,
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
        doctor: doctor,
        time: time,
        type: type,
        duration: duration,
        status: status,
        date: date,
        specialty: specialty,
        clinic: clinic,
      ),
    );
    notifyListeners();
  }
}
