import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';

class RecentPatients extends StatelessWidget {
  const RecentPatients({super.key});

  @override
  Widget build(BuildContext context) {
    final patients = [
      {
        'id': '1',
        'patientId': 'SV-2024-001',
        'name': 'Priya Sharma',
        'age': 45,
        'gender': 'F',
        'phone': '+91 98765 43210',
        'lastVisit': 'Today',
        'conditions': ['Diabetes', 'Hypertension'],
      },
      {
        'id': '2',
        'patientId': 'SV-2024-042',
        'name': 'Amit Patel',
        'age': 32,
        'gender': 'M',
        'phone': '+91 87654 32109',
        'lastVisit': 'Yesterday',
        'conditions': ['Asthma'],
      },
      {
        'id': '3',
        'patientId': 'SV-2024-089',
        'name': 'Sunita Devi',
        'age': 58,
        'gender': 'F',
        'phone': '+91 76543 21098',
        'lastVisit': '2 days ago',
        'conditions': ['Hypertension', 'Arthritis'],
      },
      {
        'id': '4',
        'patientId': 'SV-2024-156',
        'name': 'Rahul Singh',
        'age': 28,
        'gender': 'M',
        'phone': '+91 65432 10987',
        'lastVisit': '3 days ago',
        'conditions': <String>[],
      },
    ];

    return Container(
      decoration: AppDecorations.card(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Patients',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/patients');
                  },
                  child: Text(
                    'View All',
                    style: TextStyle(color: AppColors.primary, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Column(
            children: patients.map((patient) {
              final initials = (patient['name'] as String)
                  .split(' ')
                  .map((part) => part.substring(0, 1))
                  .join();
              final conditions = patient['conditions'] as List<String>;

              return InkWell(
                onTap: () {
                  Navigator.of(context).pushReplacementNamed('/patients');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppColors.border, width: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withOpacity(0.1),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initials,
                          style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  patient['name'] as String,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${patient['age']}y - ${patient['gender']}',
                                  style: TextStyle(fontSize: 12, color: AppColors.mutedForeground),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.muted,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    patient['patientId'] as String,
                                    style: TextStyle(fontSize: 11, color: AppColors.mutedForeground),
                                  ),
                                ),
                                if (conditions.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.warning.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      conditions.first,
                                      style: TextStyle(fontSize: 11, color: AppColors.warning),
                                    ),
                                  ),
                                if (conditions.length > 1)
                                  Text(
                                    '+${conditions.length - 1}',
                                    style: TextStyle(fontSize: 11, color: AppColors.mutedForeground),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 12, color: AppColors.mutedForeground),
                              const SizedBox(width: 4),
                              Text(
                                patient['lastVisit'] as String,
                                style: TextStyle(fontSize: 12, color: AppColors.mutedForeground),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.chevron_right, color: AppColors.mutedForeground),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
