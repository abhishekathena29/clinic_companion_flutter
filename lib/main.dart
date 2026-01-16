import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/dashboard_screen.dart';
import 'screens/patients_screen.dart';
import 'screens/queue_screen.dart';
import 'screens/not_found_screen.dart';

void main() {
  runApp(const ClinicCompanionApp());
}

class ClinicCompanionApp extends StatelessWidget {
  const ClinicCompanionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clinic Companion',
      theme: AppTheme.light(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const DashboardScreen(),
        '/patients': (context) => const PatientsScreen(),
        '/queue': (context) => const QueueScreen(),
      },
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (_) => const NotFoundScreen(),
        settings: settings,
      ),
    );
  }
}
