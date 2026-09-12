import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/sidebar.dart';
import 'dashboard/dashboard_screen.dart';
import 'documents/doctor_documents_screen.dart';
import 'patients/patients_screen.dart';
import 'schedule/schedule_queue_screen.dart';
import 'settings/settings_screen.dart';

class DoctorNavScope extends InheritedWidget {
  const DoctorNavScope({
    super.key,
    required this.currentIndex,
    required this.onSelectTab,
    required super.child,
  });

  final int currentIndex;
  final ValueChanged<int> onSelectTab;

  static DoctorNavScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DoctorNavScope>();
  }

  static DoctorNavScope of(BuildContext context) {
    final scope = maybeOf(context);
    assert(scope != null, 'No DoctorNavScope found in context');
    return scope!;
  }

  @override
  bool updateShouldNotify(DoctorNavScope oldWidget) =>
      currentIndex != oldWidget.currentIndex;
}

class DoctorShell extends StatefulWidget {
  const DoctorShell({super.key});

  @override
  State<DoctorShell> createState() => _DoctorShellState();
}

class _DoctorShellState extends State<DoctorShell> {
  int _currentIndex = 0;

  // Page indices: 0=Dashboard, 1=Patients, 2=Schedule & Queue, 3=Documents, 4=Settings
  static const _pages = <Widget>[
    DashboardScreen(),
    PatientsScreen(),
    ScheduleQueueScreen(),
    DoctorDocumentsScreen(),
    SettingsScreen(),
  ];

  int get _bottomNavIndex => _currentIndex.clamp(0, _pages.length - 1);

  bool _isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 768;

  @override
  Widget build(BuildContext context) {
    final isDesktop = _isDesktop(context);

    return DoctorNavScope(
      currentIndex: _currentIndex,
      onSelectTab: (i) => setState(() => _currentIndex = i),
      child: Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: isDesktop
          ? null
          : AppBottomNav(
              currentIndex: _bottomNavIndex,
              onTap: (i) => setState(() => _currentIndex = i),
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
                  icon: Icons.calendar_month_rounded,
                  label: 'Schedule & Queue',
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
    ),
  );
}
}
