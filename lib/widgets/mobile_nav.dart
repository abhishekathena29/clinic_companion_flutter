import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class MobileNav extends StatelessWidget {
  const MobileNav({super.key, required this.currentRoute});

  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem('Home', Icons.dashboard, '/'),
      _NavItem('Patients', Icons.people, '/patients'),
      _NavItem('Queue', Icons.list_alt, '/queue'),
      _NavItem('Schedule', Icons.calendar_today, '/appointments'),
      _NavItem('More', Icons.menu, '/settings'),
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
