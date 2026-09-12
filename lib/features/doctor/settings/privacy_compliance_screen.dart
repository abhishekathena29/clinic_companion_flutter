import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_decorations.dart';

class PrivacyComplianceScreen extends StatelessWidget {
  const PrivacyComplianceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Privacy & Compliance',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Banner
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppColors.gradientHero,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.verified_user_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 18),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Healthcare Data Protection & Standards',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Compliant with ABDM (Ayushman Bharat Digital Mission) & DPDP Act guidelines.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Compliance Standards
                _buildComplianceCard(
                  icon: Icons.shield_rounded,
                  title: 'ABDM Health Data Guidelines',
                  subtitle:
                      'All consultation notes, prescriptions, and health records are stored in compliance with India’s National Health Data Management policies.',
                  status: 'Active & Compliant',
                  statusColor: AppColors.success,
                ),
                const SizedBox(height: 16),

                _buildComplianceCard(
                  icon: Icons.lock_outline_rounded,
                  title: '256-Bit End-to-End Encryption',
                  subtitle:
                      'Patient medical records, communication histories, and prescriptions are encrypted in transit (TLS 1.3) and at rest (AES-256).',
                  status: 'Enforced',
                  statusColor: AppColors.primary,
                ),
                const SizedBox(height: 16),

                _buildComplianceCard(
                  icon: Icons.assignment_turned_in_rounded,
                  title: 'Patient Consent Management',
                  subtitle:
                      'Patients retain full ownership of their health data. Consultations, prescriptions, and vault records are shared strictly based on explicit digital consent.',
                  status: 'Managed',
                  statusColor: AppColors.accent,
                ),
                const SizedBox(height: 16),

                _buildComplianceCard(
                  icon: Icons.history_rounded,
                  title: 'Audit Trail & Access Logs',
                  subtitle:
                      'Every view, prescription issuance, and update is logged with doctor identity and timestamp for regulatory inspection and legal compliance.',
                  status: 'Logging Enabled',
                  statusColor: AppColors.info,
                ),
                const SizedBox(height: 28),

                // Consent Rules Section
                Container(
                  decoration: AppDecorations.card(),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Data Retention & Deletion Policy',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '• Clinical records and prescriptions are retained for the legally mandated period as per the Medical Council / NMC regulations.\n'
                        '• Patients can request an export of their complete health summary via Swasthya Vault.\n'
                        '• Account deletion requests can be submitted to privacy@mentifit.com and are verified within 48 hours.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildComplianceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      decoration: AppDecorations.card(),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: statusColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.mutedForeground,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
