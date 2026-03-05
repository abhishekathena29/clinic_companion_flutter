import 'package:clinic_companion/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'features/auth/auth_provider.dart';
import 'features/auth/auth_screen.dart';
import 'features/common/not_found_screen.dart';
import 'features/doctor/dashboard/dashboard_provider.dart';
import 'features/doctor/dashboard/dashboard_screen.dart';
import 'features/doctor/patients/patients_provider.dart';
import 'features/doctor/patients/patients_screen.dart';
import 'features/doctor/queue/queue_provider.dart';
import 'features/doctor/queue/queue_screen.dart';
import 'features/doctor/schedule/schedule_provider.dart';
import 'features/doctor/schedule/schedule_screen.dart';
import 'features/doctor/settings/settings_provider.dart';
import 'features/doctor/settings/settings_screen.dart';
import 'features/onboarding/onboarding_provider.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/patient/appointments/patient_appointments_provider.dart';
import 'features/patient/appointments/patient_appointments_screen.dart';
import 'features/patient/dashboard/patient_dashboard_provider.dart';
import 'features/patient/dashboard/patient_dashboard_screen.dart';
import 'features/patient/doctors/patient_doctors_provider.dart';
import 'features/patient/doctors/patient_doctors_screen.dart';
import 'features/patient/settings/patient_settings_provider.dart';
import 'features/patient/settings/patient_settings_screen.dart';
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
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => PatientsProvider()),
        ChangeNotifierProvider(create: (_) => QueueProvider()),
        ChangeNotifierProvider(
          create: (context) => ScheduleProvider(context.read<AppointmentsRepository>()),
        ),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(
          create: (context) => PatientDashboardProvider(context.read<AppointmentsRepository>()),
        ),
        ChangeNotifierProvider(create: (_) => PatientDoctorsProvider()),
        ChangeNotifierProvider(
          create: (context) =>
              PatientAppointmentsProvider(context.read<AppointmentsRepository>()),
        ),
        ChangeNotifierProvider(create: (_) => PatientSettingsProvider()),
      ],
      child: MaterialApp(
        title: 'Clinic Companion',
        theme: AppTheme.light(),
        debugShowCheckedModeBanner: false,
        initialRoute: '/onboarding',
        routes: {
          '/onboarding': (context) => const OnboardingScreen(),
          '/auth': (context) => const AuthScreen(),
          '/doctor': (context) => const DashboardScreen(),
          '/doctor/patients': (context) => const PatientsScreen(),
          '/doctor/queue': (context) => const QueueScreen(),
          '/doctor/appointments': (context) => const ScheduleScreen(),
          '/doctor/settings': (context) => const SettingsScreen(),
          '/patient': (context) => const PatientDashboardScreen(),
          '/patient/doctors': (context) => const PatientDoctorsScreen(),
          '/patient/appointments': (context) => const PatientAppointmentsScreen(),
          '/patient/settings': (context) => const PatientSettingsScreen(),
        },
        onUnknownRoute: (settings) => MaterialPageRoute(
          builder: (_) => const NotFoundScreen(),
          settings: settings,
        ),
      ),
    );
  }
}
