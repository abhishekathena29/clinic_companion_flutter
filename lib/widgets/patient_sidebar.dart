import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/auth/auth_provider.dart';
import '../theme/app_colors.dart';

class PatientSidebar extends StatelessWidget {
  const PatientSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '/patient';
    final auth = context.watch<AuthProvider>();
    final name = auth.profileName.isEmpty ? 'Patient' : auth.profileName;

    return Container(
      width: 280,
      decoration: BoxDecoration(
        gradient: AppColors.gradientDark,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 24,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: AppColors.gradientPrimary,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.5),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Swasthya',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Care Portal',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _NavItem(
                      label: 'Dashboard',
                      icon: Icons.home_rounded,
                      route: '/patient',
                      isActive: currentRoute == '/patient',
                    ),
                    _NavItem(
                      label: 'Doctors',
                      icon: Icons.medical_services_rounded,
                      route: '/patient/doctors',
                      isActive: currentRoute == '/patient/doctors',
                    ),
                    _NavItem(
                      label: 'Appointments',
                      icon: Icons.event_available_rounded,
                      route: '/patient/appointments',
                      isActive: currentRoute == '/patient/appointments',
                    ),
                    _NavItem(
                      label: 'Settings',
                      icon: Icons.settings_rounded,
                      route: '/patient/settings',
                      isActive: currentRoute == '/patient/settings',
                    ),
                  ],
                ),
              ),
            ),
            const Divider(color: Color.fromRGBO(255, 255, 255, 0.1), height: 1),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: AppColors.gradientHero,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      name.isEmpty ? 'PT' : name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Patient Profile',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        await context.read<AuthProvider>().signOut();
                        if (context.mounted) {
                          Navigator.of(context).pushReplacementNamed('/auth');
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.logout_rounded,
                          size: 20,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
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
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.isActive;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            final current = ModalRoute.of(context)?.settings.name ?? '/patient';
            if (current != widget.route) {
              Navigator.of(context).pushReplacementNamed(widget.route);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : _isHovered
                      ? Colors.white.withOpacity(0.08)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              children: [
                Icon(
                  widget.icon,
                  size: 24,
                  color: isSelected
                      ? Colors.white
                      : _isHovered
                          ? Colors.white
                          : Colors.white.withOpacity(0.7),
                ),
                const SizedBox(width: 16),
                Text(
                  widget.label,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : _isHovered
                            ? Colors.white
                            : Colors.white.withOpacity(0.8),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                if (isSelected) ...[
                  const Spacer(),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.white, blurRadius: 4),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
