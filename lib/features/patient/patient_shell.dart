import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/patient_sidebar.dart';
import 'appointments/patient_appointments_screen.dart';
import 'dashboard/patient_dashboard_screen.dart';
import 'doctors/patient_doctors_screen.dart';
import 'documents/patient_documents_screen.dart';
import 'settings/patient_settings_screen.dart';

class PatientShell extends StatefulWidget {
  const PatientShell({super.key});

  /// Switch to a tab by index from any descendant widget.
  static void switchTab(BuildContext context, int index) {
    context.findAncestorStateOfType<_PatientShellState>()?._setIndex(index);
  }

  @override
  State<PatientShell> createState() => _PatientShellState();
}

class _PatientShellState extends State<PatientShell> {
  int _currentIndex = 0;

  // Page indices: 0=Dashboard, 1=Doctors, 2=Appointments, 3=Documents, 4=Settings
  static const _pages = <Widget>[
    PatientDashboardScreen(),
    PatientDoctorsScreen(),
    PatientAppointmentsScreen(),
    PatientDocumentsScreen(),
    PatientSettingsScreen(),
  ];

  static const _sidebarRoutes = [
    '/patient',
    '/patient/doctors',
    '/patient/appointments',
    '/patient/documents',
    '/patient/settings',
  ];

  void _setIndex(int index) {
    if (index != _currentIndex) {
      setState(() => _currentIndex = index);
    }
  }

  bool _isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 768;

  @override
  Widget build(BuildContext context) {
    final isDesktop = _isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: isDesktop
          ? null
          : AppBottomNav(
              currentIndex: _currentIndex,
              onTap: _setIndex,
              items: const [
                AppBottomNavItem(icon: Icons.home_rounded, label: 'Home'),
                AppBottomNavItem(
                  icon: Icons.medical_services_rounded,
                  label: 'Doctors',
                ),
                AppBottomNavItem(
                  icon: Icons.event_available_rounded,
                  label: 'Appointments',
                ),
                AppBottomNavItem(
                  icon: Icons.folder_shared_rounded,
                  label: 'Documents',
                ),
                AppBottomNavItem(
                  icon: Icons.settings_rounded,
                  label: 'Settings',
                ),
              ],
            ),
      body: SafeArea(
        bottom: !isDesktop,
        child: Row(
          children: [
            if (isDesktop)
              PatientSidebar(
                currentRoute: _sidebarRoutes[_currentIndex],
                onRouteSelected: (route) {
                  final idx = _sidebarRoutes.indexOf(route);
                  if (idx != -1) _setIndex(idx);
                },
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  isDesktop ? 32 : 16,
                  16,
                  isDesktop ? 32 : 16,
                  isDesktop ? 24 : 16,
                ),
                child: _pages[_currentIndex],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
