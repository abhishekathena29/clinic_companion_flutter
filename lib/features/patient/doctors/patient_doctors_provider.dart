import 'package:flutter/material.dart';

class DoctorProfile {
  const DoctorProfile({
    required this.name,
    required this.specialty,
    required this.rating,
    required this.experienceYears,
    required this.clinic,
    required this.location,
    required this.fee,
    required this.nextAvailable,
  });

  final String name;
  final String specialty;
  final double rating;
  final int experienceYears;
  final String clinic;
  final String location;
  final int fee;
  final String nextAvailable;
}

class PatientDoctorsProvider extends ChangeNotifier {
  final List<DoctorProfile> _doctors = const [
    DoctorProfile(
      name: 'Dr. Rajesh Mehra',
      specialty: 'Cardiology',
      rating: 4.8,
      experienceYears: 14,
      clinic: 'City Care Clinic',
      location: 'Indiranagar',
      fee: 600,
      nextAvailable: 'Today, 4:30 PM',
    ),
    DoctorProfile(
      name: 'Dr. Ananya Gupta',
      specialty: 'Dermatology',
      rating: 4.7,
      experienceYears: 9,
      clinic: 'Glow Health Studio',
      location: 'Koramangala',
      fee: 500,
      nextAvailable: 'Tomorrow, 11:00 AM',
    ),
    DoctorProfile(
      name: 'Dr. Sameer Rao',
      specialty: 'Orthopedics',
      rating: 4.6,
      experienceYears: 12,
      clinic: 'Axis Orthopedic Center',
      location: 'HSR Layout',
      fee: 700,
      nextAvailable: 'Today, 6:15 PM',
    ),
    DoctorProfile(
      name: 'Dr. Kavya Iyer',
      specialty: 'Pediatrics',
      rating: 4.9,
      experienceYears: 11,
      clinic: 'Little Steps Clinic',
      location: 'Whitefield',
      fee: 450,
      nextAvailable: 'Saturday, 10:00 AM',
    ),
  ];

  List<DoctorProfile> get doctors => List.unmodifiable(_doctors);
}
