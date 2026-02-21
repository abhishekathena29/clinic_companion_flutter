import 'package:flutter/material.dart';

enum PatientFilter { all, chronic, newPatient }

class Patient {
  const Patient({
    required this.id,
    required this.patientId,
    required this.name,
    required this.age,
    required this.gender,
    required this.phone,
    required this.lastVisit,
    required this.totalVisits,
    required this.conditions,
    required this.status,
  });

  final String id;
  final String patientId;
  final String name;
  final int age;
  final String gender;
  final String phone;
  final String lastVisit;
  final int totalVisits;
  final List<String> conditions;
  final String status;
}

class PatientsProvider extends ChangeNotifier {
  final List<Patient> _patients = [
    const Patient(
      id: '1',
      patientId: 'SV-2024-001',
      name: 'Priya Sharma',
      age: 45,
      gender: 'F',
      phone: '+91 98765 43210',
      lastVisit: '2024-01-15',
      totalVisits: 12,
      conditions: ['Diabetes Type 2', 'Hypertension'],
      status: 'active',
    ),
    const Patient(
      id: '2',
      patientId: 'SV-2024-042',
      name: 'Amit Patel',
      age: 32,
      gender: 'M',
      phone: '+91 87654 32109',
      lastVisit: '2024-01-14',
      totalVisits: 5,
      conditions: ['Asthma'],
      status: 'active',
    ),
    const Patient(
      id: '3',
      patientId: 'SV-2024-089',
      name: 'Sunita Devi',
      age: 58,
      gender: 'F',
      phone: '+91 76543 21098',
      lastVisit: '2024-01-12',
      totalVisits: 28,
      conditions: ['Hypertension', 'Arthritis', 'Thyroid'],
      status: 'active',
    ),
    const Patient(
      id: '4',
      patientId: 'SV-2024-156',
      name: 'Rahul Singh',
      age: 28,
      gender: 'M',
      phone: '+91 65432 10987',
      lastVisit: '2024-01-10',
      totalVisits: 2,
      conditions: <String>[],
      status: 'active',
    ),
    const Patient(
      id: '5',
      patientId: 'SV-2024-203',
      name: 'Meera Joshi',
      age: 52,
      gender: 'F',
      phone: '+91 54321 09876',
      lastVisit: '2024-01-08',
      totalVisits: 15,
      conditions: ['Diabetes Type 2'],
      status: 'active',
    ),
    const Patient(
      id: '6',
      patientId: 'SV-2024-267',
      name: 'Vikram Rao',
      age: 41,
      gender: 'M',
      phone: '+91 43210 98765',
      lastVisit: '2023-12-20',
      totalVisits: 8,
      conditions: ['High Cholesterol'],
      status: 'inactive',
    ),
  ];

  String _searchQuery = '';
  PatientFilter _filter = PatientFilter.all;

  String get searchQuery => _searchQuery;
  PatientFilter get filter => _filter;
  List<Patient> get patients => List.unmodifiable(_patients);

  void updateSearch(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void updateFilter(PatientFilter filter) {
    _filter = filter;
    notifyListeners();
  }

  List<Patient> get filteredPatients {
    final query = _searchQuery.toLowerCase();
    return _patients.where((patient) {
      final matchesSearch = patient.name.toLowerCase().contains(query) ||
          patient.patientId.toLowerCase().contains(query) ||
          patient.phone.contains(query);

      if (_filter == PatientFilter.chronic) {
        return matchesSearch && patient.conditions.isNotEmpty;
      }
      if (_filter == PatientFilter.newPatient) {
        return matchesSearch && patient.totalVisits <= 2;
      }
      return matchesSearch;
    }).toList();
  }

  void addPatient({
    required String name,
    required int age,
    required String gender,
    required String phone,
    required List<String> conditions,
    String status = 'active',
  }) {
    final nextIndex = _patients.length + 1;
    final patientId = 'SV-2024-${nextIndex.toString().padLeft(3, '0')}';
    final now = DateTime.now();
    final lastVisit = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    _patients.insert(
      0,
      Patient(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        patientId: patientId,
        name: name,
        age: age,
        gender: gender,
        phone: phone,
        lastVisit: lastVisit,
        totalVisits: 1,
        conditions: conditions,
        status: status,
      ),
    );
    notifyListeners();
  }
}
