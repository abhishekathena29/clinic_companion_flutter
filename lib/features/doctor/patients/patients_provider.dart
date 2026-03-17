import 'package:flutter/material.dart';

import '../../../shared/appointments_repository.dart';

export '../../../shared/appointments_repository.dart' show Patient;

enum PatientFilter { all, chronic, newPatient }

class PatientsProvider extends ChangeNotifier {
  PatientsProvider(this._repository) {
    _repository.addListener(_handleRepositoryUpdate);
  }

  final AppointmentsRepository _repository;

  String _searchQuery = '';
  PatientFilter _filter = PatientFilter.all;

  String get searchQuery => _searchQuery;
  PatientFilter get filter => _filter;
  List<Patient> get patients => _repository.patients;

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
    return patients.where((patient) {
      final matchesSearch =
          patient.name.toLowerCase().contains(query) ||
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

  Future<void> addPatient({
    required String name,
    required int age,
    required String gender,
    required String phone,
    required List<String> conditions,
    String status = 'active',
  }) {
    return _repository.addPatient(
      name: name,
      age: age,
      gender: gender,
      phone: phone,
      conditions: conditions,
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
