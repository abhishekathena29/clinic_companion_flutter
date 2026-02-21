import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  bool _smartReminders = true;
  bool _labAlerts = true;
  bool _emailSummaries = false;
  bool _smsUpdates = true;
  bool _biometric = false;
  bool _autoBackup = true;

  bool get smartReminders => _smartReminders;
  bool get labAlerts => _labAlerts;
  bool get emailSummaries => _emailSummaries;
  bool get smsUpdates => _smsUpdates;
  bool get biometric => _biometric;
  bool get autoBackup => _autoBackup;

  void toggleSmartReminders(bool value) {
    _smartReminders = value;
    notifyListeners();
  }

  void toggleLabAlerts(bool value) {
    _labAlerts = value;
    notifyListeners();
  }

  void toggleEmailSummaries(bool value) {
    _emailSummaries = value;
    notifyListeners();
  }

  void toggleSmsUpdates(bool value) {
    _smsUpdates = value;
    notifyListeners();
  }

  void toggleBiometric(bool value) {
    _biometric = value;
    notifyListeners();
  }

  void toggleAutoBackup(bool value) {
    _autoBackup = value;
    notifyListeners();
  }
}
