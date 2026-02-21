import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';
import '../widgets/app_button.dart';
import '../widgets/dashboard_layout.dart';
import '../widgets/mobile_header.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  bool _isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 768;

  @override
  Widget build(BuildContext context) {
    final isDesktop = _isDesktop(context);
    final provider = context.watch<SettingsProvider>();

    return DashboardLayout(
      routeName: '/settings',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isDesktop)
            const MobileHeader(title: 'Settings', showSearch: false),
          if (isDesktop)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Settings & Security',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Clinic preferences, notifications, and security controls',
                      style: TextStyle(
                        color: AppColors.mutedForeground,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const AppButton(
                  label: 'Save Changes',
                  icon: Icons.check_circle_rounded,
                ),
              ],
            ),
          const SizedBox(height: 24),
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: _SettingsColumn(provider: provider)),
                const SizedBox(width: 32),
                Expanded(flex: 3, child: _ProfileCard()),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ProfileCard(),
                const SizedBox(height: 24),
                _SettingsColumn(provider: provider),
              ],
            ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.card(),
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  gradient: AppColors.gradientPrimary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Text(
                  'DR',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
                child: Icon(
                  Icons.camera_alt_rounded,
                  size: 16,
                  color: AppColors.mutedForeground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Dr. Rajesh Kumar',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.muted,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'City Care Clinic',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.mutedForeground,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: const [
              Expanded(
                child: AppButton(
                  label: 'Edit Profile',
                  icon: Icons.edit_rounded,
                  variant: AppButtonVariant.outline,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  label: 'Invite Staff',
                  icon: Icons.group_add_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Divider(height: 1),
          const SizedBox(height: 16),
          _SupportTile(
            icon: Icons.help_outline_rounded,
            title: 'Help Center & Support',
            subtitle: 'Get guidance on daily workflows',
          ),
          const SizedBox(height: 8),
          _SupportTile(
            icon: Icons.shield_rounded,
            title: 'Privacy & Compliance',
            subtitle: 'Manage patient consent rules',
          ),
        ],
      ),
    );
  }
}

class _SupportTile extends StatefulWidget {
  const _SupportTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  State<_SupportTile> createState() => _SupportTileState();
}

class _SupportTileState extends State<_SupportTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _isHovered
              ? AppColors.muted.withOpacity(0.8)
              : AppColors.muted.withOpacity(0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.border.withOpacity(_isHovered ? 1 : 0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
              child: Icon(widget.icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.mutedForeground,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.mutedForeground),
          ],
        ),
      ),
    );
  }
}

class _SettingsColumn extends StatelessWidget {
  const _SettingsColumn({required this.provider});

  final SettingsProvider provider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SectionCard(
          title: 'Notifications & Alerts',
          subtitle: 'Stay ahead of daily clinic activities and updates',
          icon: Icons.notifications_active_rounded,
          children: [
            _SwitchRow(
              label: 'Smart reminders',
              description: 'AI-driven push alerts for upcoming queues',
              value: provider.smartReminders,
              onChanged: provider.toggleSmartReminders,
            ),
            const Divider(height: 24),
            _SwitchRow(
              label: 'Lab & Diagnostics alerts',
              description: 'Notify immediately when external reports arrive',
              value: provider.labAlerts,
              onChanged: provider.toggleLabAlerts,
            ),
            const Divider(height: 24),
            _SwitchRow(
              label: 'Daily Email summaries',
              description: 'Receive an EOD breakdown of appointments',
              value: provider.emailSummaries,
              onChanged: provider.toggleEmailSummaries,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _SectionCard(
          title: 'Patient Communication',
          subtitle: 'Automated updates, templates, and confirmations',
          icon: Icons.chat_rounded,
          children: [
            _SwitchRow(
              label: 'Automated SMS updates',
              description: 'Send SMS on check-in and delays',
              value: provider.smsUpdates,
              onChanged: provider.toggleSmsUpdates,
            ),
            const Divider(height: 24),
            _TileRow(
              icon: Icons.alternate_email_rounded,
              title: 'Default Email Template',
              subtitle: 'Manage clinic branding and doctor signatures',
            ),
          ],
        ),
        const SizedBox(height: 24),
        _SectionCard(
          title: 'Security & Backup Storage',
          subtitle: 'Data protection and HIPAA configuration',
          icon: Icons.security_rounded,
          children: [
            _SwitchRow(
              label: 'Biometric sign in',
              description: 'Require FaceID or TouchID when opening app',
              value: provider.biometric,
              onChanged: provider.toggleBiometric,
            ),
            const Divider(height: 24),
            _SwitchRow(
              label: 'Auto-backup health records',
              description: 'Sync local data to encrypted cloud storage',
              value: provider.autoBackup,
              onChanged: provider.toggleAutoBackup,
            ),
            const Divider(height: 24),
            _TileRow(
              icon: Icons.admin_panel_settings_rounded,
              title: 'Role-Based Access Control',
              subtitle: 'Limit access for receptionists vs. assistants',
            ),
          ],
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.children,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.card(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.mutedForeground,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(fontSize: 13, color: AppColors.mutedForeground),
            ),
          ],
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
          activeTrackColor: AppColors.primary.withOpacity(0.4),
        ),
      ],
    );
  }
}

class _TileRow extends StatefulWidget {
  const _TileRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  State<_TileRow> createState() => _TileRowState();
}

class _TileRowState extends State<_TileRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _isHovered
              ? AppColors.muted.withOpacity(0.8)
              : AppColors.muted.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.border.withOpacity(_isHovered ? 1 : 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(widget.icon, color: AppColors.primary, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.mutedForeground,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedSlide(
              duration: const Duration(milliseconds: 200),
              offset: _isHovered ? const Offset(0.2, 0) : Offset.zero,
              child: Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
