import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/sidebar.dart';
import 'dashboard/dashboard_screen.dart';
import 'documents/doctor_documents_screen.dart';
import 'patients/patients_screen.dart';
import 'queue/queue_screen.dart';
import 'reports/reports_screen.dart';
import 'schedule/schedule_screen.dart';
import 'settings/settings_screen.dart';

class DoctorShell extends StatefulWidget {
  const DoctorShell({super.key});

  @override
  State<DoctorShell> createState() => _DoctorShellState();
}

class _DoctorShellState extends State<DoctorShell> {
  int _currentIndex = 0;

  // Page indices: 0=Dashboard, 1=Patients, 2=Queue, 3=Schedule, 4=Reports, 5=Documents, 6=Settings
  static const _pages = <Widget>[
    DashboardScreen(),
    PatientsScreen(),
    QueueScreen(),
    ScheduleScreen(),
    ReportsScreen(),
    DoctorDocumentsScreen(),
    SettingsScreen(),
  ];

  // Bottom nav shows 5 items; maps bottom-nav tap index → page index
  static const _bottomNavToPage = [0, 1, 2, 5, 6];

  int get _bottomNavIndex {
    final idx = _bottomNavToPage.indexOf(_currentIndex);
    return idx == -1 ? 0 : idx;
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
              currentIndex: _bottomNavIndex,
              onTap: (i) => setState(() => _currentIndex = _bottomNavToPage[i]),
              items: const [
                AppBottomNavItem(
                  icon: Icons.dashboard_rounded,
                  label: 'Home',
                ),
                AppBottomNavItem(
                  icon: Icons.people_alt_rounded,
                  label: 'Patients',
                ),
                AppBottomNavItem(
                  icon: Icons.list_alt_rounded,
                  label: 'Queue',
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
              Sidebar(
                currentIndex: _currentIndex,
                onSelected: (i) => setState(() => _currentIndex = i),
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
