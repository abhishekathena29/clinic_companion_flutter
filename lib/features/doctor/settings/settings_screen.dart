import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../shared/appointments_repository.dart';
import '../../auth/auth_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_decorations.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/mobile_header.dart';
import '../../../widgets/responsive_page_header.dart';
import 'help_center_screen.dart';
import 'privacy_compliance_screen.dart';
import 'settings_provider.dart';

Future<void> _showEditProfileDialog(BuildContext context) async {
  final auth = context.read<AuthProvider>();
  final nameController = TextEditingController(text: auth.profileName);
  final clinicController = TextEditingController(text: auth.profileClinic);
  final specialtyController = TextEditingController(
    text: auth.profileSpecialty,
  );
  final phoneController = TextEditingController(text: auth.profilePhone);
  final experienceController = TextEditingController(
    text: auth.profileExperienceYears > 0 ? auth.profileExperienceYears.toString() : '5',
  );
  final qualificationsController = TextEditingController(
    text: auth.profileQualifications.isNotEmpty ? auth.profileQualifications : 'MBBS, MD',
  );
  final feeController = TextEditingController(
    text: auth.profileFee > 0 ? auth.profileFee.toString() : '500',
  );
  final bioController = TextEditingController(text: auth.profileBio);
  final formKey = GlobalKey<FormState>();

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: 520,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.14),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withOpacity(0.85)],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Edit Doctor Profile',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Update your clinic, credentials & contact details',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    onPressed: () => Navigator.of(dialogContext).pop(),
                  ),
                ],
              ),
            ),

            // Form inputs
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: nameController,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Doctor name is required';
                          }
                          if (val.trim().length < 2) {
                            return 'Name must be at least 2 characters';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Doctor Name *',
                          prefixIcon: const Icon(Icons.person_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: clinicController,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Clinic / Hospital name is required';
                          }
                          if (val.trim().length < 2) {
                            return 'Clinic name must be at least 2 characters';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Clinic / Hospital Name *',
                          prefixIcon: const Icon(Icons.local_hospital_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: specialtyController,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Specialty is required';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Medical Specialty / Expertise *',
                          prefixIcon: const Icon(Icons.medical_services_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: experienceController,
                              keyboardType: TextInputType.number,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Experience is required';
                                }
                                final yrs = int.tryParse(val.trim());
                                if (yrs == null || yrs < 1 || yrs > 70) {
                                  return 'Enter 1-70';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: 'Experience (Years) *',
                                prefixIcon: const Icon(Icons.timeline_rounded),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: feeController,
                              keyboardType: TextInputType.number,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Fee required';
                                }
                                final fee = int.tryParse(val.trim());
                                if (fee == null || fee < 0) return 'Invalid';
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: 'Consultation Fee (₹) *',
                                prefixIcon: const Icon(Icons.currency_rupee_rounded),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: qualificationsController,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Degrees / Qualifications required';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Qualifications / Degrees *',
                          hintText: 'e.g. MBBS, MD, DNB',
                          prefixIcon: const Icon(Icons.school_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Phone number is required';
                          }
                          final digits = val.replaceAll(RegExp(r'[^0-9]'), '');
                          if (digits.length < 10) {
                            return 'Enter a valid 10-digit mobile number';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Phone Number (for patient calls & WhatsApp) *',
                          prefixIcon: const Icon(Icons.phone_rounded),
                          helperText: 'Used for scheduled patient communication',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: bioController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'About / Medical Bio',
                          hintText: 'Brief summary of clinical focus, timings, etc.',
                          prefixIcon: const Icon(Icons.info_outline_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: const Text(
                        'Save Changes',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        await auth.updateDoctorProfile(
                          name: nameController.text,
                          clinic: clinicController.text,
                          specialty: specialtyController.text,
                          phone: phoneController.text,
                          experienceYears: int.tryParse(experienceController.text.trim()) ?? 1,
                          qualifications: qualificationsController.text.trim(),
                          fee: int.tryParse(feeController.text.trim()) ?? 500,
                          bio: bioController.text.trim(),
                          profileCompleted: true,
                        );
                        if (dialogContext.mounted) {
                          Navigator.of(dialogContext).pop();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  bool _isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 768;

  @override
  Widget build(BuildContext context) {
    final isDesktop = _isDesktop(context);
    final provider = context.watch<SettingsProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isDesktop)
          const MobileHeader(title: 'Settings', showSearch: false),
        if (isDesktop)
          ResponsivePageHeader(
            title: 'Settings & Security',
            subtitle: 'Clinic preferences, notifications, and security controls',
            actions: [
              AppButton(
                label: 'Sign Out',
                icon: Icons.logout_rounded,
                variant: AppButtonVariant.outline,
                onPressed: () async {
                  await context.read<AuthProvider>().signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed('/auth');
                  }
                },
              ),
            ],
          ),
        if (!isDesktop) ...[
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppButton(
                label: 'Sign Out',
                icon: Icons.logout_rounded,
                variant: AppButtonVariant.outline,
                onPressed: () async {
                  await context.read<AuthProvider>().signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed('/auth');
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
        ] else
          const SizedBox(height: 24),
        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 5, child: _SettingsColumn(provider: provider)),
              const SizedBox(width: 32),
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    _ProfileCard(),
                    const SizedBox(height: 24),
                    _DoctorReviewsSettingsCard(
                      doctorId: context.watch<AuthProvider>().user?.uid ?? '',
                    ),
                  ],
                ),
              ),
            ],
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ProfileCard(),
              const SizedBox(height: 24),
              _DoctorReviewsSettingsCard(
                doctorId: context.watch<AuthProvider>().user?.uid ?? '',
              ),
              const SizedBox(height: 24),
              _SettingsColumn(provider: provider),
            ],
          ),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final name = auth.profileName.trim().isEmpty ? 'Doctor' : auth.profileName;
    final clinic = auth.profileClinic.trim().isEmpty
        ? 'MentiFit'
        : auth.profileClinic;
    final initials = name
        .split(' ')
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part.substring(0, 1).toUpperCase())
        .join();

    return Container(
      decoration: AppDecorations.card(),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
            child: Text(
              initials.isEmpty ? 'DR' : initials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 32,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.muted,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                clinic,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.mutedForeground,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            [
              if (auth.profileQualifications.isNotEmpty) auth.profileQualifications,
              if (auth.profileSpecialty.isNotEmpty) auth.profileSpecialty else 'General Medicine',
            ].join(' • '),
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            [
              if (auth.profileExperienceYears > 0) '${auth.profileExperienceYears} yrs experience',
              if (auth.profileFee > 0) '₹${auth.profileFee} / session',
            ].join(' • '),
            style: TextStyle(color: AppColors.mutedForeground, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          if (auth.profilePhone.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.phone_rounded, size: 13, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  auth.profilePhone,
                  style: TextStyle(color: AppColors.mutedForeground, fontSize: 12),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 360) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppButton(
                      label: 'Edit Profile',
                      icon: Icons.edit_rounded,
                      variant: AppButtonVariant.outline,
                      onPressed: () => _showEditProfileDialog(context),
                    ),
                    const SizedBox(height: 12),
                    const AppButton(
                      label: 'Invite Staff',
                      icon: Icons.group_add_rounded,
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Edit Profile',
                      icon: Icons.edit_rounded,
                      variant: AppButtonVariant.outline,
                      onPressed: () => _showEditProfileDialog(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: AppButton(
                      label: 'Invite Staff',
                      icon: Icons.group_add_rounded,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),
          const Divider(height: 1),
          const SizedBox(height: 16),
          _SupportTile(
            icon: Icons.help_outline_rounded,
            title: 'Help Center & Support',
            subtitle: 'Get guidance on daily workflows',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HelpCenterScreen()),
              );
            },
          ),
          const SizedBox(height: 8),
          _SupportTile(
            icon: Icons.shield_rounded,
            title: 'Privacy & Compliance',
            subtitle: 'Manage patient consent rules',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PrivacyComplianceScreen()),
              );
            },
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
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: widget.onTap,
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
              Expanded(
                child: Column(
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
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
          activeTrackColor: AppColors.primary.withValues(alpha: 0.4),
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

class _DoctorReviewsSettingsCard extends StatelessWidget {
  const _DoctorReviewsSettingsCard({required this.doctorId});

  final String doctorId;

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<AppointmentsRepository>();
    final reviews = repo.reviewsForDoctor(doctorId);
    final doctor = repo.doctorById(doctorId);
    final rating = doctor?.rating ?? 5.0;

    return Container(
      decoration: AppDecorations.card(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Patient Reviews & Feedback',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              if (reviews.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_rounded, size: 16, color: AppColors.warning),
                      const SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${reviews.length})',
                        style: TextStyle(color: AppColors.mutedForeground, fontSize: 11),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (reviews.isEmpty)
            Text(
              'No patient reviews received yet. Reviews will appear here as patients complete consultations.',
              style: TextStyle(color: AppColors.mutedForeground, fontSize: 13),
            )
          else
            Column(
              children: reviews.map((r) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.muted.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              r.patientName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                          Row(
                            children: List.generate(5, (i) => Icon(
                              i < r.rating ? Icons.star_rounded : Icons.star_border_rounded,
                              size: 14,
                              color: AppColors.warning,
                            )),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            DateFormat('d MMM').format(r.createdAt),
                            style: TextStyle(color: AppColors.mutedForeground, fontSize: 11),
                          ),
                        ],
                      ),
                      if (r.comment.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          r.comment,
                          style: TextStyle(fontSize: 12, color: AppColors.foreground.withOpacity(0.9)),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
