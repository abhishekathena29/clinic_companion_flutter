import 'package:flutter/material.dart';
import 'floating_bottom_nav.dart';

class MobileNav extends StatelessWidget {
  const MobileNav({super.key, required this.currentRoute});

  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    const items = [
      BottomNavItemData(label: 'Home', icon: Icons.dashboard, route: '/doctor'),
      BottomNavItemData(
        label: 'Patients',
        icon: Icons.people,
        route: '/doctor/patients',
      ),
      BottomNavItemData(
        label: 'Queue',
        icon: Icons.list_alt,
        route: '/doctor/queue',
      ),
      BottomNavItemData(
        label: 'Schedule',
        icon: Icons.calendar_today,
        route: '/doctor/appointments',
      ),
      BottomNavItemData(
        label: 'Settings',
        icon: Icons.settings_rounded,
        route: '/doctor/settings',
      ),
    ];

    return FloatingBottomNav(currentRoute: currentRoute, items: items);
  }
}
