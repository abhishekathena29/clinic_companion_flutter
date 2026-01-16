import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '/';

    return Container(
      width: 256,
      decoration: BoxDecoration(gradient: AppColors.gradientPrimary),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.favorite, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Swasthya',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Health Vault',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  children: [
                    _NavItem(
                      label: 'Dashboard',
                      icon: Icons.dashboard,
                      route: '/',
                      isActive: currentRoute == '/',
                    ),
                    _NavItem(
                      label: 'Patients',
                      icon: Icons.people,
                      route: '/patients',
                      isActive: currentRoute == '/patients',
                    ),
                    _NavItem(
                      label: 'Queue',
                      icon: Icons.list_alt,
                      route: '/queue',
                      isActive: currentRoute == '/queue',
                    ),
                    _NavItem(
                      label: 'Appointments',
                      icon: Icons.calendar_today,
                      route: '/appointments',
                      isActive: currentRoute == '/appointments',
                    ),
                    _NavItem(
                      label: 'Reports',
                      icon: Icons.insert_drive_file,
                      route: '/reports',
                      isActive: currentRoute == '/reports',
                    ),
                    _NavItem(
                      label: 'Settings',
                      icon: Icons.settings,
                      route: '/settings',
                      isActive: currentRoute == '/settings',
                    ),
                  ],
                ),
              ),
            ),
            const Divider(color: Color.fromRGBO(255, 255, 255, 0.2)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppColors.borderRadius),
                  ),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.qr_code_scanner, size: 18),
                    SizedBox(width: 10),
                    Text('Scan Patient QR', style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
            ),
            const Divider(color: Color.fromRGBO(255, 255, 255, 0.2)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'DR',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Dr. Rajesh Kumar',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2),
                        Text(
                          'City Care Clinic',
                          style: TextStyle(fontSize: 11, color: Colors.white70),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.logout, size: 18, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.route,
    required this.isActive,
  });

  final String label;
  final IconData icon;
  final String route;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isActive
        ? Colors.white.withOpacity(0.15)
        : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppColors.borderRadius),
        onTap: () {
          final current = ModalRoute.of(context)?.settings.name ?? '/';
          if (current != route) {
            Navigator.of(context).pushReplacementNamed(route);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppColors.borderRadius),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: Colors.white.withOpacity(isActive ? 1 : 0.8)),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
