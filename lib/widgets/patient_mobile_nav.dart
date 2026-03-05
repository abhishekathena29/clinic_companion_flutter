import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PatientMobileNav extends StatelessWidget {
  const PatientMobileNav({super.key, required this.currentRoute});

  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem('Home', Icons.home_rounded, '/patient'),
      _NavItem('Doctors', Icons.medical_services_rounded, '/patient/doctors'),
      _NavItem('Appointments', Icons.event_available_rounded, '/patient/appointments'),
      _NavItem('Settings', Icons.settings_rounded, '/patient/settings'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: items.map((item) {
              final isActive = currentRoute == item.route;
              return Expanded(
                child: InkWell(
                  onTap: () {
                    if (currentRoute != item.route) {
                      Navigator.of(context).pushReplacementNamed(item.route);
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item.icon,
                        size: isActive ? 22 : 20,
                        color: isActive ? AppColors.primary : AppColors.mutedForeground,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                          color: isActive ? AppColors.primary : AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  _NavItem(this.label, this.icon, this.route);

  final String label;
  final IconData icon;
  final String route;
}
