import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PatientMobileNav extends StatelessWidget {
  const PatientMobileNav({super.key, required this.currentRoute});

  final String currentRoute;

  static const _routes = [
    '/patient',
    '/patient/doctors',
    '/patient/appointments',
    '/patient/settings',
  ];

  int get _currentIndex {
    final index = _routes.indexOf(currentRoute);
    return index == -1 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        final route = _routes[index];
        if (route != currentRoute) {
          Navigator.of(context).pushReplacementNamed(route);
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.mutedForeground,
      backgroundColor: AppColors.card,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.medical_services_rounded),
          label: 'Doctors',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.event_available_rounded),
          label: 'Appointments',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_rounded),
          label: 'Settings',
        ),
      ],
    );
  }
}
