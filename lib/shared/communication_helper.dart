import 'package:url_launcher/url_launcher.dart';

/// Opens a Google Meet (or any video-call) link in an external browser/app.
/// The link itself is created externally by the doctor (e.g. from their own
/// Google Calendar) and pasted into the appointment — this app does not call
/// the Google Calendar API.
Future<bool> openGoogleMeet(String link) async {
  final trimmed = link.trim();
  if (trimmed.isEmpty) return false;

  final uri = Uri.tryParse(
    trimmed.startsWith('http') ? trimmed : 'https://$trimmed',
  );
  if (uri == null) return false;

  return launchUrl(uri, mode: LaunchMode.externalApplication);
}

/// Opens a WhatsApp chat/video-call with the given phone number via a
/// `wa.me` deep link. WhatsApp has no public API to start a video call
/// directly, so this opens the chat and the call is started manually from
/// there.
Future<bool> openWhatsApp(String phone, {String? message}) async {
  final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) return false;

  final uri = Uri.https('wa.me', '/$digits', {
    if (message != null && message.isNotEmpty) 'text': message,
  });

  return launchUrl(uri, mode: LaunchMode.externalApplication);
}
