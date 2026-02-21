import 'package:clinic_companion/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/onboarding_provider.dart';
import 'providers/patients_provider.dart';
import 'providers/queue_provider.dart';
import 'providers/schedule_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/patients_screen.dart';
import 'screens/queue_screen.dart';
import 'screens/not_found_screen.dart';
import 'screens/schedule_screen.dart';
import 'screens/settings_screen.dart';

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
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => PatientsProvider()),
        ChangeNotifierProvider(create: (_) => QueueProvider()),
        ChangeNotifierProvider(create: (_) => ScheduleProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: MaterialApp(
        title: 'Clinic Companion',
        theme: AppTheme.light(),
        debugShowCheckedModeBanner: false,
        initialRoute: '/onboarding',
        routes: {
          '/onboarding': (context) => const OnboardingScreen(),
          '/auth': (context) => const AuthScreen(),
          '/': (context) => const DashboardScreen(),
          '/patients': (context) => const PatientsScreen(),
          '/queue': (context) => const QueueScreen(),
          '/appointments': (context) => const ScheduleScreen(),
          '/settings': (context) => const SettingsScreen(),
        },
        onUnknownRoute: (settings) => MaterialPageRoute(
          builder: (_) => const NotFoundScreen(),
          settings: settings,
        ),
      ),
    );
  }
}
