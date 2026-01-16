import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';

class QueueList extends StatelessWidget {
  const QueueList({super.key});

  @override
  Widget build(BuildContext context) {
    final queueData = [
      {
        'id': '1',
        'patientName': 'Priya Sharma',
        'patientId': 'SV-2024-001',
        'time': '09:30 AM',
        'waitTime': '25 min',
        'status': 'in-progress',
        'reason': 'Follow-up - Diabetes',
      },
      {
        'id': '2',
        'patientName': 'Amit Patel',
        'patientId': 'SV-2024-042',
        'time': '09:45 AM',
        'waitTime': '15 min',
        'status': 'waiting',
        'reason': 'Fever & Cold',
      },
      {
        'id': '3',
        'patientName': 'Sunita Devi',
        'patientId': 'SV-2024-089',
        'time': '10:00 AM',
        'waitTime': '5 min',
        'status': 'waiting',
        'reason': 'BP Check',
      },
      {
        'id': '4',
        'patientName': 'Rahul Singh',
        'patientId': 'SV-2024-156',
        'time': '10:15 AM',
        'waitTime': 'Just arrived',
        'status': 'waiting',
        'reason': 'New Patient',
      },
    ];

    return Container(
      decoration: AppDecorations.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Today's Queue",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  '${queueData.length} patients',
                  style: TextStyle(fontSize: 12, color: AppColors.mutedForeground),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Column(
            children: queueData.map((item) {
              final isInProgress = item['status'] == 'in-progress';
              final statusLabel = isInProgress ? 'With Doctor' : 'Waiting';
              final statusColor = isInProgress ? AppColors.info : AppColors.warning;
              return InkWell(
                onTap: () {
                  Navigator.of(context).pushReplacementNamed('/queue');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border(
                      top: BorderSide(color: AppColors.border, width: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isInProgress
                              ? AppColors.info
                              : AppColors.muted,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          item['id'] as String,
                          style: TextStyle(
                            color: isInProgress
                                ? AppColors.infoForeground
                                : AppColors.mutedForeground,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                Text(
                                  item['patientName'] as String,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    statusLabel,
                                    style: TextStyle(fontSize: 11, color: statusColor),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['reason'] as String,
                              style: TextStyle(fontSize: 12, color: AppColors.mutedForeground),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            item['time'] as String,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.access_time, size: 12, color: AppColors.mutedForeground),
                              const SizedBox(width: 4),
                              Text(
                                item['waitTime'] as String,
                                style: TextStyle(fontSize: 11, color: AppColors.mutedForeground),
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/queue');
              },
              child: Text(
                'View All Queue ->',
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
