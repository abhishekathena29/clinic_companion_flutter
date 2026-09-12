import 'package:flutter/material.dart';

import '../shared/appointments_repository.dart';
import '../shared/communication_helper.dart';
import '../theme/app_colors.dart';

/// A small "Video consultation" badge plus Join-Meet/WhatsApp buttons,
/// shown on an appointment card when [appointment.isVideoConsultation].
class VideoConsultationActions extends StatelessWidget {
  const VideoConsultationActions({
    super.key,
    required this.appointment,
    required this.contactPhone,
  });

  final Appointment appointment;

  /// The other party's phone number (doctor's for a patient view, patient's
  /// for a doctor view) used for the WhatsApp deep link.
  final String contactPhone;

  @override
  Widget build(BuildContext context) {
    if (!appointment.isVideoConsultation) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.accentLight,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.videocam_rounded, size: 14, color: AppColors.accent),
              const SizedBox(width: 6),
              Text(
                'Video consultation',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
        ),
        if (appointment.meetingLink.isNotEmpty)
          OutlinedButton.icon(
            onPressed: () => openGoogleMeet(appointment.meetingLink),
            icon: const Icon(Icons.video_camera_front_rounded, size: 16),
            label: const Text('Join Google Meet'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        if (contactPhone.isNotEmpty)
          OutlinedButton.icon(
            onPressed: () => openWhatsApp(
              contactPhone,
              message:
                  'Hi, regarding our video consultation on ${appointment.time}.',
            ),
            icon: const Icon(Icons.chat_rounded, size: 16),
            label: const Text('WhatsApp'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.success,
              side: BorderSide(color: AppColors.success.withValues(alpha: 0.4)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
      ],
    );
  }
}
