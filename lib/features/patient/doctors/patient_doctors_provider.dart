import 'package:flutter/material.dart';

import '../../../shared/appointments_repository.dart';

export '../../../shared/appointments_repository.dart' show DoctorProfile;

class PatientDoctorsProvider extends ChangeNotifier {
  PatientDoctorsProvider(this._repository) {
    _repository.addListener(_handleRepositoryUpdate);
  }

  final AppointmentsRepository _repository;

  List<DoctorProfile> get doctors => _repository.doctors;

  void _handleRepositoryUpdate() {
    notifyListeners();
  }

  @override
  void dispose() {
    _repository.removeListener(_handleRepositoryUpdate);
    super.dispose();
  }
}
