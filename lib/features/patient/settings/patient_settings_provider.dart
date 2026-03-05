import 'package:flutter/material.dart';

class PatientSettingsProvider extends ChangeNotifier {
  bool _appointmentReminders = true;
  bool _labUpdates = true;
  bool _smsUpdates = true;
  bool _shareHealthVault = false;

  bool get appointmentReminders => _appointmentReminders;
  bool get labUpdates => _labUpdates;
  bool get smsUpdates => _smsUpdates;
  bool get shareHealthVault => _shareHealthVault;

  void toggleAppointmentReminders(bool value) {
    _appointmentReminders = value;
    notifyListeners();
  }

  void toggleLabUpdates(bool value) {
    _labUpdates = value;
    notifyListeners();
  }

  void toggleSmsUpdates(bool value) {
    _smsUpdates = value;
    notifyListeners();
  }

  void toggleShareHealthVault(bool value) {
    _shareHealthVault = value;
    notifyListeners();
  }
}
