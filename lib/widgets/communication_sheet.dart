import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/auth/auth_provider.dart';
import '../shared/communication_helper.dart';
import '../theme/app_colors.dart';
import 'app_button.dart';

class CommunicationSheet extends StatelessWidget {
  const CommunicationSheet({
    super.key,
    required this.recipientName,
    required this.recipientRole,
    required this.phone,
    required this.isScheduled,
    this.senderName,
    this.scheduledTime,
    this.statusText,
    this.meetingLink,
  });

  final String recipientName;
  final String recipientRole;
  final String phone;
  final bool isScheduled;
  final String? senderName;
  final String? scheduledTime;
  final String? statusText;
  final String? meetingLink;

  static Future<void> show(
    BuildContext context, {
    required String recipientName,
    required String recipientRole,
    required String phone,
    required bool isScheduled,
    String? senderName,
    String? scheduledTime,
    String? statusText,
    String? meetingLink,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CommunicationSheet(
        recipientName: recipientName,
        recipientRole: recipientRole,
        phone: phone,
        isScheduled: isScheduled,
        senderName: senderName,
        scheduledTime: scheduledTime,
        statusText: statusText,
        meetingLink: meetingLink,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cleanDigits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final hasPhone = cleanDigits.isNotEmpty;

    return Container(
      constraints: const BoxConstraints(maxWidth: 540),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: AppColors.gradientHero,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Icon(
                  recipientRole.toLowerCase().contains('doctor')
                      ? Icons.medical_services_rounded
                      : Icons.person_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipientName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            recipientRole,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        if (phone.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(
                            phone,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.mutedForeground,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
                color: AppColors.mutedForeground,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Schedule Status Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isScheduled
                  ? AppColors.success.withOpacity(0.08)
                  : AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isScheduled
                    ? AppColors.success.withOpacity(0.3)
                    : AppColors.warning.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isScheduled
                      ? Icons.event_available_rounded
                      : Icons.event_busy_rounded,
                  color: isScheduled ? AppColors.success : AppColors.warning,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isScheduled
                            ? 'Consultation Scheduled'
                            : 'Not Scheduled on Platform',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isScheduled
                              ? AppColors.success
                              : AppColors.warningForeground,
                        ),
                      ),
                      if (statusText != null || scheduledTime != null)
                        Text(
                          statusText ?? 'Time: $scheduledTime',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.mutedForeground,
                          ),
                        ),
                      if (!isScheduled)
                        Text(
                          'Direct calls are unlocked once an appointment or queue token is scheduled.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.mutedForeground,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Communication Actions
          if (!hasPhone)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.muted,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: AppColors.mutedForeground),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'No contact phone number is registered for this user.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            )
          else if (!isScheduled)
            AppButton(
              label: 'Close',
              variant: AppButtonVariant.outline,
              onPressed: () => Navigator.of(context).pop(),
            )
          else ...[
            _CommunicationActionTile(
              icon: Icons.chat_rounded,
              color: const Color(0xFF25D366),
              title: 'WhatsApp Message',
              subtitle: 'Send message or start instant consultation chat',
              onTap: () {
                openWhatsApp(
                  phone,
                  message:
                      'Hi $recipientName, regarding our scheduled consultation on MentiFit.',
                );
              },
            ),
            const SizedBox(height: 12),
            _CommunicationActionTile(
              icon: Icons.video_call_rounded,
              color: const Color(0xFF128C7E),
              title: 'WhatsApp Video Call',
              subtitle: 'Initiate consultation via WhatsApp Call',
              onTap: () {
                openWhatsAppCall(
                  phone,
                  recipientName: recipientName,
                  senderName: senderName,
                  scheduledTime: scheduledTime,
                  isVideo: true,
                );
              },
            ),
            const SizedBox(height: 12),
            _CommunicationActionTile(
              icon: Icons.phone_rounded,
              color: AppColors.primary,
              title: 'Direct Phone Call',
              subtitle: 'Call $phone directly from your phone app',
              onTap: () {
                openPhoneCall(phone);
              },
            ),
            const SizedBox(height: 12),
            _CommunicationActionTile(
              icon: Icons.phone_missed_rounded,
              color: const Color(0xFFE65100),
              title: 'Patient Unavailable? Leave Message',
              subtitle: 'Send "Doctor tried reaching you" WhatsApp alert & note',
              onTap: () {
                final auth = context.read<AuthProvider?>();
                final doctorName = (senderName != null && senderName!.isNotEmpty)
                    ? senderName!
                    : (auth?.profileName.isNotEmpty == true ? auth!.profileName : 'Doctor');
                final noteMessage =
                    'Hello $recipientName, Dr. $doctorName tried reaching you for your consultation on MentiFit, but was unable to connect. Please reply to this message or call back once you are available.';
                openWhatsApp(phone, message: noteMessage);
              },
            ),
            if (meetingLink != null && meetingLink!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _CommunicationActionTile(
                icon: Icons.video_camera_front_rounded,
                color: AppColors.accent,
                title: 'Google Meet',
                subtitle: 'Join video meeting via external link',
                onTap: () => openGoogleMeet(meetingLink!),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _CommunicationActionTile extends StatelessWidget {
  const _CommunicationActionTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(16),
            color: AppColors.background,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
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
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.mutedForeground,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.mutedForeground,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
