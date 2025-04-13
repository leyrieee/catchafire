// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../services/firebase_service.dart';

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

  final List<String> _allSkills = [
    'Graphic Design',
    'Fundraising',
    'Training',
    'Event Planning',
    'Communications'
  ];

  final List<String> _selectedSkills = [];

  Future<void> _pickImage(ImageSource source) async {
    final picked = await picker.pickImage(source: source);
    if (picked != null) {
      setState(() {
        _coverPhoto = File(picked.path);
      });
    }
  }

  Future<String?> _uploadImageToServer(File imageFile) async {
    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('http://10.21.19.245:3000/upload'));
      request.files
          .add(await http.MultipartFile.fromPath('image', imageFile.path));
      var response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final data = json.decode(responseBody);
        return data['viewLink'];
      } else {
        print("Failed to upload image to server.");
        return null;
      }
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  final String _googleMapsApiKey = 'AIzaSyDxjx9fqNNBvvIXs14PKx2mn4g3m3YqJUo';

  Future<void> _submitForm() async {
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

      final imageUrl = await _uploadImageToServer(_coverPhoto!);
      if (imageUrl == null) throw "Image upload failed";

      final coords = await _getLatLngFromAddress(_locationController.text);
      if (coords == null) throw "Location not found";

      final lat = coords['lat'];
      final lng = coords['lng'];

      await FirebaseService.saveEventToFirestore({
        'title': _titleController.text.trim(),
        'organization': _orgController.text.trim(),
        'location': _locationController.text.trim(),
        'date': _selectedDate,
        'imageUrl': imageUrl,
        'latitude': lat,
        'longitude': lng,
        'skills': _selectedSkills,
        'createdAt': DateTime.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event posted successfully!')),
      );

      setState(() {
        _coverPhoto = null;
        _titleController.clear();
        _orgController.clear();
        _locationController.clear();
        _selectedDate = null;
        _selectedSkills.clear();
      });
    } catch (e) {
      debugPrint('❌ ERROR: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to post event. Please try again.')),
      );
    }
  }

  Future<Map<String, double>?> _getLatLngFromAddress(String address) async {
    final encodedAddress = Uri.encodeComponent(address);
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?address=$encodedAddress&key=$_googleMapsApiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          return {
            'lat': location['lat'],
            'lng': location['lng'],
          };
        } else {
          debugPrint('Geocoding failed: ${data['status']}');
          return null;
        }
      } else {
        debugPrint('Geocoding HTTP error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Geocoding error: $e');
      return null;
    }
  }

  void _toggleSkill(String skill) {
    setState(() {
      if (_selectedSkills.contains(skill)) {
        _selectedSkills.remove(skill);
      } else {
        _selectedSkills.add(skill);
      }
    });
  }

  Widget _buildSkillChips() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: _allSkills.map((skill) {
        final isSelected = _selectedSkills.contains(skill);
        return ChoiceChip(
          label: Text(skill),
          selected: isSelected,
          onSelected: (_) => _toggleSkill(skill),
          selectedColor: Colors.brown.shade200,
          backgroundColor: Colors.grey.shade200,
          labelStyle: TextStyle(
            color: isSelected ? Colors.black87 : Colors.grey.shade800,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 6),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color.fromRGBO(41, 37, 37, 1),
          ),
        ),
      );

  InputDecoration _inputStyle(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        hintStyle: const TextStyle(color: Colors.grey),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      );

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
            _buildLabel("Skills Needed"),
            _buildSkillChips(),
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
}
