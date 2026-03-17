import 'package:flutter/material.dart';
import 'floating_bottom_nav.dart';

class PatientMobileNav extends StatelessWidget {
  const PatientMobileNav({super.key, required this.currentRoute});

  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    const items = [
      BottomNavItemData(
        label: 'Home',
        icon: Icons.home_rounded,
        route: '/patient',
      ),
      BottomNavItemData(
        label: 'Doctors',
        icon: Icons.medical_services_rounded,
        route: '/patient/doctors',
      ),
      BottomNavItemData(
        label: 'Appointments',
        icon: Icons.event_available_rounded,
        route: '/patient/appointments',
      ),
      BottomNavItemData(
        label: 'Settings',
        icon: Icons.settings_rounded,
        route: '/patient/settings',
      ),
    ];

    return FloatingBottomNav(currentRoute: currentRoute, items: items);
  }
}
