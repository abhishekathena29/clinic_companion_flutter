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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.info.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.history_rounded,
                        size: 22,
                        color: AppColors.info,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Text(
                      'Recent Patients',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/patients');
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: Text(
                    'View All',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Column(
            children: patients
                .map((patient) => _RecentPatientItem(patient: patient))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _RecentPatientItem extends StatefulWidget {
  final Map<String, dynamic> patient;

  const _RecentPatientItem({required this.patient});

  @override
  State<_RecentPatientItem> createState() => _RecentPatientItemState();
}

class _RecentPatientItemState extends State<_RecentPatientItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final patient = widget.patient;
    final initials = (patient['name'] as String)
        .split(' ')
        .map((part) => part.substring(0, 1))
        .join();
    final conditions = patient['conditions'] as List<String>;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushReplacementNamed('/patients');
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: _isHovered
                ? AppColors.muted.withOpacity(0.5)
                : Colors.transparent,
            border: Border(
              top: BorderSide(color: AppColors.border, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.12),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          patient['name'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${patient['age']}y • ${patient['gender']}',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.mutedForeground,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.muted,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            patient['patientId'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.mutedForeground,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (conditions.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              conditions.first,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.warningForeground,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        if (conditions.length > 1)
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 4),
                            child: Text(
                              '+${conditions.length - 1} more',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.mutedForeground,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
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
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: AppColors.mutedForeground,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        patient['lastVisit'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.mutedForeground,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 12),
              AnimatedSlide(
                duration: const Duration(milliseconds: 200),
                offset: _isHovered ? const Offset(0.2, 0) : Offset.zero,
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
