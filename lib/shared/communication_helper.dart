import 'package:url_launcher/url_launcher.dart';

/// Cleans phone numbers to numeric digits, automatically adding '91' if a 10-digit number is provided.
String sanitizePhoneNumber(String phone) {
  final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.length == 10) {
    return '91$digits';
  }
  return digits;
}

/// Initiates a direct cellular / standard phone call via `tel:`.
Future<bool> openPhoneCall(String phone) async {
  final digits = phone.replaceAll(RegExp(r'[^0-9+]'), '');
  if (digits.isEmpty) return false;

  final uri = Uri(scheme: 'tel', path: digits);
  if (await canLaunchUrl(uri)) {
    return launchUrl(uri);
  }
  return false;
}

/// Opens a Google Meet (or any external video-call) link in browser/app.
Future<bool> openGoogleMeet(String link) async {
  final trimmed = link.trim();
  if (trimmed.isEmpty) return false;

  final uri = Uri.tryParse(
    trimmed.startsWith('http') ? trimmed : 'https://$trimmed',
  );
  if (uri == null) return false;

  return launchUrl(uri, mode: LaunchMode.externalApplication);
}

/// Opens a WhatsApp chat with the given phone number via `wa.me` deep link.
Future<bool> openWhatsApp(String phone, {String? message}) async {
  final clean = sanitizePhoneNumber(phone);
  if (clean.isEmpty) return false;

  final uri = Uri.https('wa.me', '/$clean', {
    if (message != null && message.isNotEmpty) 'text': message,
  });

  return launchUrl(uri, mode: LaunchMode.externalApplication);
}

/// Initiates WhatsApp communication for a scheduled call with a contextual greeting.
Future<bool> openWhatsAppCall(
  String phone, {
  String? recipientName,
  String? senderName,
  String? scheduledTime,
  bool isVideo = false,
}) async {
  final clean = sanitizePhoneNumber(phone);
  if (clean.isEmpty) return false;

  final buffer = StringBuffer();
  buffer.write('Hello');
  if (recipientName != null && recipientName.isNotEmpty) {
    buffer.write(' $recipientName');
  }
  buffer.write('! ');
  if (senderName != null && senderName.isNotEmpty) {
    buffer.write('This is $senderName from MentiFit. ');
  }
  if (scheduledTime != null && scheduledTime.isNotEmpty) {
    buffer.write('Regarding our consultation scheduled for $scheduledTime: ');
  }
  buffer.write(
    isVideo
        ? 'I am initiating our scheduled WhatsApp Video Call. Please join when ready.'
        : 'I am calling for our scheduled consultation. Please connect when ready.',
  );

  return openWhatsApp(clean, message: buffer.toString());
}
