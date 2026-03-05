import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_decorations.dart';
import '../../../widgets/patient_layout.dart';
import 'patient_settings_provider.dart';

class PatientSettingsScreen extends StatelessWidget {
  const PatientSettingsScreen({super.key});

  bool _isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 768;

  @override
  Widget build(BuildContext context) {
    final isDesktop = _isDesktop(context);
    final provider = context.watch<PatientSettingsProvider>();

    return PatientLayout(
      routeName: '/patient/settings',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Preferences',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            'Personalize how you receive updates from your clinics.',
            style: TextStyle(color: AppColors.mutedForeground, fontSize: 15),
          ),
          const SizedBox(height: 24),
          if (isDesktop)
            Row(
              children: [
                Expanded(child: _NotificationCard(provider: provider)),
                const SizedBox(width: 16),
                Expanded(child: _PrivacyCard(provider: provider)),
              ],
            )
          else ...[
            _NotificationCard(provider: provider),
            const SizedBox(height: 16),
            _PrivacyCard(provider: provider),
          ],
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.provider});

  final PatientSettingsProvider provider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notifications',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            value: provider.appointmentReminders,
            onChanged: provider.toggleAppointmentReminders,
            activeColor: AppColors.primary,
            title: const Text('Appointment reminders'),
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            value: provider.labUpdates,
            onChanged: provider.toggleLabUpdates,
            activeColor: AppColors.primary,
            title: const Text('Lab & reports updates'),
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            value: provider.smsUpdates,
            onChanged: provider.toggleSmsUpdates,
            activeColor: AppColors.primary,
            title: const Text('SMS alerts'),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}

class _PrivacyCard extends StatelessWidget {
  const _PrivacyCard({required this.provider});

  final PatientSettingsProvider provider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Privacy',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            value: provider.shareHealthVault,
            onChanged: provider.toggleShareHealthVault,
            activeColor: AppColors.primary,
            title: const Text('Share health vault with new doctors'),
            subtitle: const Text('Allow doctors to request your records'),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
