import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../config/cloudinary_config.dart';

class CloudinaryUploadException implements Exception {
  CloudinaryUploadException(this.message);
  final String message;

  @override
  String toString() => message;
}

class CloudinaryService {
  /// Uploads [bytes] to Cloudinary via an unsigned upload preset and
  /// returns the resulting `secure_url`.
  static Future<String> uploadBytes(Uint8List bytes, String fileName) async {
    if (!CloudinaryConfig.isConfigured) {
      throw CloudinaryUploadException(
        'Cloudinary is not configured yet. Set cloudName and uploadPreset '
        'in lib/config/cloudinary_config.dart.',
      );
    }

    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/${CloudinaryConfig.cloudName}/auto/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = CloudinaryConfig.uploadPreset
      ..files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: fileName),
      );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw CloudinaryUploadException(
        'Cloudinary upload failed (${response.statusCode}): ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final secureUrl = data['secure_url']?.toString();
    if (secureUrl == null || secureUrl.isEmpty) {
      throw CloudinaryUploadException(
        'Cloudinary upload did not return a URL.',
      );
    }
    return secureUrl;
  }
}
