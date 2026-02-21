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
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                        color: AppColors.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.event_available_rounded,
                        size: 22,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Text(
                      'Appointments',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Calendar',
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: appointments
                  .map((apt) => _AppointmentItem(apt: apt))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppointmentItem extends StatefulWidget {
  final Map<String, dynamic> apt;

  const _AppointmentItem({required this.apt});

  @override
  State<_AppointmentItem> createState() => _AppointmentItemState();
}

class _AppointmentItemState extends State<_AppointmentItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final apt = widget.apt;
    final isNext = apt['isNext'] as bool;
    final isVideo = apt['type'] == 'video';
    final initials = (apt['patientName'] as String)
        .split(' ')
        .map((word) => word.substring(0, 1))
        .join();

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isNext
              ? AppColors.primaryLight.withOpacity(0.5)
              : _isHovered
              ? AppColors.muted.withOpacity(0.4)
              : AppColors.card,
          borderRadius: BorderRadius.circular(AppColors.borderRadius),
          border: Border.all(
            color: isNext
                ? AppColors.primary
                : AppColors.border.withOpacity(_isHovered ? 0.6 : 0.4),
            width: isNext ? 1.5 : 1.0,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isNext ? AppColors.gradientPrimary : null,
                color: isNext ? null : AppColors.muted,
              ),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: TextStyle(
                  color: isNext
                      ? AppColors.primaryForeground
                      : AppColors.mutedForeground,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              apt['patientName'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              apt['reason'] as String,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.mutedForeground,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isVideo
                              ? AppColors.info.withOpacity(0.12)
                              : AppColors.muted,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isVideo
                                  ? Icons.videocam_rounded
                                  : Icons.location_on_rounded,
                              size: 14,
                              color: isVideo
                                  ? AppColors.info
                                  : AppColors.mutedForeground,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isVideo ? 'Video' : 'In-Person',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isVideo
                                    ? AppColors.info
                                    : AppColors.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color: AppColors.mutedForeground,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        apt['time'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.mutedForeground,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isNext) ...[
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'UP NEXT',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
