import 'package:flutter/material.dart';
import '../../../shared/communication_helper.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_decorations.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  String _searchQuery = '';

  final List<Map<String, String>> _faqs = [
    {
      'question': 'How do I mark a consultation completed and prescribe medications?',
      'answer':
          'Open the Patients tab or Schedule tab. Under the patient’s entry, tap "Complete Consultation" or "Add Rx / Prescription". Fill in the medications, dosage, and doctor notes, then click "Save & Publish". The prescription instantly appears on the patient\'s portal.',
    },
    {
      'question': 'How does WhatsApp consultation and patient messaging work?',
      'answer':
          'Tap anywhere on the patient box or consultation card to open the Communication Sheet. You can start a WhatsApp chat, voice/video call, or send an automated "Patient Unavailable" alert if they missed your call.',
    },
    {
      'question': 'How do I add a new patient to the clinic?',
      'answer':
          'Go to the Patients screen and click "+ Add Patient". Fill in their name, 10-digit mobile number, age, gender, and medical conditions. A unique Swasthya Vault patient ID (e.g. SV-2026-XXXX) will be generated automatically.',
    },
    {
      'question': 'Can patients see my profile, qualifications, and consultation fee?',
      'answer':
          'Yes. Patients browsing the doctor directory can view your credentials, specialty, qualifications (e.g. MBBS, MD), consultation fee, and verified patient reviews before booking appointments.',
    },
    {
      'question': 'How are patient reviews collected and rated?',
      'answer':
          'After each completed consultation, patients can submit a 1 to 5 star rating and comment on their appointment card. The reviews automatically calibrate your average rating and display on your dashboard and settings.',
    },
    {
      'question': 'How do I manage the daily patient queue in clinic?',
      'answer':
          'Navigate to the Queue tab. You can view all waiting patients, estimated wait times, call the next patient, and update queue tokens in real-time.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredFaqs = _faqs.where((faq) {
      final q = faq['question']!.toLowerCase();
      final a = faq['answer']!.toLowerCase();
      final query = _searchQuery.toLowerCase().trim();
      return query.isEmpty || q.contains(query) || a.contains(query);
    }).toList();

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
          'Help Center & Support',
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
                // Support Hero
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: AppColors.gradientHero,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.support_agent_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'How can we assist you today?',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Explore clinical guides, FAQs, or contact our priority doctor support team.',
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
                      const SizedBox(height: 20),
                      // Search input
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: TextField(
                          onChanged: (val) => setState(() => _searchQuery = val),
                          decoration: const InputDecoration(
                            hintText: 'Search help guides, prescriptions, workflows...',
                            prefixIcon: Icon(Icons.search_rounded),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Quick Support Action Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildActionTile(
                        icon: Icons.chat_rounded,
                        color: const Color(0xFF25D366),
                        title: 'WhatsApp Doctor Support',
                        subtitle: 'Instant chat with support executive',
                        onTap: () {
                          openWhatsApp(
                            '919876543210',
                            message:
                                'Hello MentiFit Support, I am a doctor and need assistance with clinic operations.',
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildActionTile(
                        icon: Icons.phone_in_talk_rounded,
                        color: AppColors.primary,
                        title: 'Phone Helpline',
                        subtitle: 'Mon–Sat (9 AM – 9 PM IST)',
                        onTap: () {
                          openPhoneCall('18001234567');
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // FAQs Header
                const Text(
                  'Frequently Asked Questions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                if (filteredFaqs.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: AppDecorations.card(),
                    alignment: Alignment.center,
                    child: Text(
                      'No articles match "$_searchQuery". Try another search or contact support.',
                      style: TextStyle(color: AppColors.mutedForeground),
                    ),
                  )
                else
                  Column(
                    children: filteredFaqs.map((faq) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: AppDecorations.card(),
                        child: ExpansionTile(
                          shape: const RoundedRectangleBorder(
                            side: BorderSide(color: Colors.transparent),
                          ),
                          title: Text(
                            faq['question']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          childrenPadding:
                              const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          children: [
                            Text(
                              faq['answer']!,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.6,
                                color: AppColors.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: AppDecorations.card(),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
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
    );
  }
}
