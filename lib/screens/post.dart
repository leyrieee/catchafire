 import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart';
import 'dart:convert';

class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  File? _coverPhoto;
  final picker = ImagePicker();
  
  final _titleController = TextEditingController();
  final _orgController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime? _selectedDate;

  final _clientId = ClientId("YOUR_CLIENT_ID", "YOUR_CLIENT_SECRET"); // Replace with your credentials
  late AuthClient _authClient;

  Future<void> _authenticate() async {
    final credentials = await obtainCredentials(_clientId);
    _authClient = credentials.authClient;
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await picker.pickImage(source: source);
    if (picked != null) {
      setState(() {
        _coverPhoto = File(picked.path);
      });
    }
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _uploadImageToDrive() async {
    if (_coverPhoto == null) return;

    final driveApi = drive.DriveApi(_authClient);
    final file = drive.File();
    final media = drive.Media(_coverPhoto!.openRead(), _coverPhoto!.lengthSync());

    final response = await driveApi.files.create(file, uploadMedia: media);
    final fileUrl = response.webViewLink;
    debugPrint("File uploaded: $fileUrl");
  }

  void _submitForm() async {
    if (_coverPhoto == null ||
        _titleController.text.isEmpty ||
        _orgController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uploading... Please wait')),
      );

      await _authenticate();
      await _uploadImageToDrive();

      // Now save your event data as needed (perhaps in Firebase or Firestore)

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event posted successfully!')),
      );

      setState(() {
        _coverPhoto = null;
        _titleController.clear();
        _orgController.clear();
        _locationController.clear();
        _selectedDate = null;
      });
    } catch (e) {
      debugPrint('Error uploading: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to post event. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(244, 242, 230, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(244, 242, 230, 1),
        foregroundColor: const Color.fromRGBO(41, 37, 37, 1),
        elevation: 0,
        title: const Text(
          'Post New Event',
          style: TextStyle(
            fontFamily: 'GT Ultra',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Cover Photo"),
            GestureDetector(
              onTap: () => _pickImage(ImageSource.gallery),
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(16),
                  image: _coverPhoto != null
                      ? DecorationImage(
                          image: FileImage(_coverPhoto!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _coverPhoto == null
                    ? const Center(
                        child: Text(
                          "Tap to upload or take a photo",
                          style: TextStyle(color: Colors.black54),
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Take Photo"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color.fromRGBO(41, 37, 37, 1),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text("Upload"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color.fromRGBO(41, 37, 37, 1),
                  ),
                ),
              ],
            ),
            _buildLabel("Event Title"),
            TextField(
              controller: _titleController,
              decoration: _inputStyle("e.g. Coding Bootcamp"),
            ),
            _buildLabel("Organization"),
            TextField(
              controller: _orgController,
              decoration: _inputStyle("e.g. TechForChange"),
            ),
            _buildLabel("Location"),
            TextField(
              controller: _locationController,
              decoration: _inputStyle("e.g. Legon Campus"),
            ),
            _buildLabel("Date"),
            GestureDetector(
              onTap: _selectDate,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  _selectedDate == null
                      ? "Select a date"
                      : _selectedDate!.toLocal().toString().split(' ')[0],
                  style: TextStyle(
                    fontSize: 16,
                    color: _selectedDate == null ? Colors.grey : Colors.black87,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: _submitForm,
                icon: const Icon(Icons.send),
                label: const Text("Post Event"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(41, 37, 37, 1),
                  foregroundColor: const Color.fromRGBO(244, 242, 230, 1),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
