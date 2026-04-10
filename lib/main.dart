import 'package:clinic_companion/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'features/auth/auth_provider.dart';
import 'features/auth/auth_screen.dart';
import 'features/common/not_found_screen.dart';
import 'features/doctor/dashboard/dashboard_provider.dart';
import 'features/doctor/doctor_shell.dart';
import 'features/doctor/documents/doctor_documents_provider.dart';
import 'features/doctor/patients/patients_provider.dart';
import 'features/doctor/queue/queue_provider.dart';
import 'features/doctor/schedule/schedule_provider.dart';
import 'features/doctor/settings/settings_provider.dart';
import 'features/onboarding/onboarding_provider.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/patient/appointments/patient_appointments_provider.dart';
import 'features/patient/dashboard/patient_dashboard_provider.dart';
import 'features/patient/doctors/patient_doctors_provider.dart';
import 'features/patient/documents/patient_documents_provider.dart';
import 'features/patient/patient_shell.dart';
import 'features/patient/settings/patient_settings_provider.dart';
import 'theme/app_theme.dart';
import 'shared/appointments_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting();
  runApp(const ClinicCompanionApp());
}

class ClinicCompanionApp extends StatelessWidget {
  const ClinicCompanionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentsRepository()),
        ChangeNotifierProxyProvider<AppointmentsRepository, DashboardProvider>(
          create: (context) =>
              DashboardProvider(context.read<AppointmentsRepository>()),
          update: (context, repository, previous) =>
              previous ?? DashboardProvider(repository),
        ),
        ChangeNotifierProxyProvider<AppointmentsRepository, PatientsProvider>(
          create: (context) =>
              PatientsProvider(context.read<AppointmentsRepository>()),
          update: (context, repository, previous) =>
              previous ?? PatientsProvider(repository),
        ),
        ChangeNotifierProxyProvider<AppointmentsRepository, QueueProvider>(
          create: (context) =>
              QueueProvider(context.read<AppointmentsRepository>()),
          update: (context, repository, previous) =>
              previous ?? QueueProvider(repository),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              ScheduleProvider(context.read<AppointmentsRepository>()),
        ),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(
          create: (context) =>
              DoctorDocumentsProvider(context.read<AppointmentsRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              PatientDashboardProvider(context.read<AppointmentsRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              PatientDoctorsProvider(context.read<AppointmentsRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) => PatientAppointmentsProvider(
            context.read<AppointmentsRepository>(),
          ),
        ),
        ChangeNotifierProvider(create: (_) => PatientSettingsProvider()),
        ChangeNotifierProvider(
          create: (context) =>
              PatientDocumentsProvider(context.read<AppointmentsRepository>()),
        ),
      ],
      child: MaterialApp(
        title: 'Clinic Companion',
        theme: AppTheme.light(),
        debugShowCheckedModeBanner: false,
        // home: const _AuthGate(),
        routes: {
          '/': (context) => const _AuthGate(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/auth': (context) => const AuthScreen(),
          '/doctor': (context) => const DoctorShell(),
          '/patient': (context) => const PatientShell(),
          '/patient/doctors': (context) => const PatientShell(),
          '/patient/appointments': (context) => const PatientShell(),
          '/patient/settings': (context) => const PatientShell(),
        },
        onUnknownRoute: (settings) => MaterialPageRoute(
          builder: (_) => const NotFoundScreen(),
          settings: settings,
        ),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isInitializing) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!auth.isAuthenticated) {
      return const OnboardingScreen();
    }

    if (auth.userType == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return auth.homeRoute == '/doctor'
        ? const DoctorShell()
        : const PatientShell();
  }
}
