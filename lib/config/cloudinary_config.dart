/// Cloudinary config for unsigned client-side uploads.
///
/// To enable real uploads:
/// 1. Create a free account at https://cloudinary.com and note your
///    "Cloud name" from the dashboard.
/// 2. Go to Settings -> Upload -> Upload presets -> Add upload preset,
///    set "Signing Mode" to "Unsigned", and note the preset name.
/// 3. Replace the placeholders below with those two values.
class CloudinaryConfig {
  static const String cloudName = 'dffmjd5tv';
  static const String uploadPreset = 'MediConnect_MyraBHandari';

  static bool get isConfigured =>
      cloudName != 'YOUR_CLOUD_NAME' && uploadPreset != 'YOUR_UNSIGNED_UPLOAD_PRESET';
}
