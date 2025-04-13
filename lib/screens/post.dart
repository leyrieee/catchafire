import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';

class FirebaseService {
  static Future<String> uploadImageToStorage(File imageFile) async {
    // Step 1: Load service account credentials from assets
    final serviceAccountJson = await rootBundle.loadString('assets/credentials.json');
    final credentials = ServiceAccountCredentials.fromJson(serviceAccountJson);

    // Step 2: Define required scopes
    const scopes = [drive.DriveApi.driveFileScope];

    // Step 3: Get AuthClient
    final client = await clientViaServiceAccount(credentials, scopes);

    try {
      final driveApi = drive.DriveApi(client);

      // Step 4: Upload the file
      final fileToUpload = drive.File();
      fileToUpload.name = imageFile.path.split('/').last;

      final media = drive.Media(imageFile.openRead(), imageFile.lengthSync());
      final uploadedFile = await driveApi.files.create(
        fileToUpload,
        uploadMedia: media,
      );

      // Step 5: Make it publicly accessible
      await driveApi.permissions.create(
        drive.Permission()
          ..type = 'anyone'
          ..role = 'reader',
        uploadedFile.id!,
      );

      final url = "https://drive.google.com/uc?export=view&id=${uploadedFile.id}";
      return url;
    } catch (e) {
      print("❌ Google Drive Upload Error: $e");
      rethrow;
    } finally {
      client.close();
    }
  }

  static Future<void> saveEventToFirestore(Map<String, dynamic> eventData) async {
    // Your Firestore save logic (assuming Firebase has been initialized already)
    // Example:
    // await FirebaseFirestore.instance.collection('events').add(eventData);
  }
}
