import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';

class UpcomingAppointments extends StatelessWidget {
  const UpcomingAppointments({super.key});

  @override
  Widget build(BuildContext context) {
    final appointments = [
      {
        'id': '1',
        'patientName': 'Meera Joshi',
        'time': '11:00 AM',
        'type': 'in-person',
        'reason': 'Chronic Disease Review',
        'isNext': true,
      },
      {
        'id': '2',
        'patientName': 'Vikram Rao',
        'time': '11:30 AM',
        'type': 'video',
        'reason': 'Lab Results Discussion',
        'isNext': false,
      },
      {
        'id': '3',
        'patientName': 'Lakshmi Nair',
        'time': '12:00 PM',
        'type': 'in-person',
        'reason': 'Vaccination',
        'isNext': false,
      },
      {
        'id': '4',
        'patientName': 'Deepak Kumar',
        'time': '02:30 PM',
        'type': 'in-person',
        'reason': 'Dental Consultation',
        'isNext': false,
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
                  'Appointments',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Calendar',
                    style: TextStyle(color: AppColors.primary, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: appointments.map((apt) {
                final isNext = apt['isNext'] as bool;
                final isVideo = apt['type'] == 'video';
                final initials = (apt['patientName'] as String)
                    .split(' ')
                    .map((word) => word.substring(0, 1))
                    .join();

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isNext ? AppColors.primaryLight : AppColors.card,
                    borderRadius: BorderRadius.circular(AppColors.borderRadius),
                    border: Border.all(
                      color: isNext ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isNext ? AppColors.primary : AppColors.muted,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initials,
                          style: TextStyle(
                            color: isNext
                                ? AppColors.primaryForeground
                                : AppColors.mutedForeground,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        apt['patientName'] as String,
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        apt['reason'] as String,
                                        style: TextStyle(fontSize: 12, color: AppColors.mutedForeground),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isVideo
                                        ? AppColors.info.withOpacity(0.1)
                                        : AppColors.muted,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isVideo ? Icons.videocam : Icons.location_on,
                                        size: 12,
                                        color: isVideo ? AppColors.info : AppColors.mutedForeground,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        isVideo ? 'Video' : 'In-Person',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isVideo ? AppColors.info : AppColors.mutedForeground,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.access_time, size: 14, color: AppColors.mutedForeground),
                                const SizedBox(width: 6),
                                Text(
                                  apt['time'] as String,
                                  style: TextStyle(fontSize: 12, color: AppColors.mutedForeground),
                                ),
                                if (isNext) ...[
                                  const SizedBox(width: 12),
                                  Text(
                                    'Next',
                                    style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
