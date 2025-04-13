import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;
  List<Map<String, dynamic>> userEvents = [];
  List<Map<String, dynamic>> rsvpEvents = [];

  int totalEvents = 0;
  int totalSkills = 0;
  int totalCauses = 0;
  File? _profileImage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
    });

    await Future.wait([
      fetchUserInfo(),
      fetchUserEvents(),
      fetchRsvpEvents(),
    ]);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> fetchUserInfo() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (!mounted) return;

      if (doc.exists) {
        setState(() {
          userData = doc.data();
          totalSkills = (userData?['skills']?.length ?? 0);
          totalEvents = (userData?['events']?.length ?? 0);
          totalCauses = (userData?['causes']?.length ?? 0);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading profile: ${e.toString()}")),
      );
    }
  }

  Future<void> fetchRsvpEvents() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      // Get today's date at midnight to compare with event dates
      final today = DateTime.now();
      final todayMidnight = DateTime(today.year, today.month, today.day);
      final todayTimestamp = Timestamp.fromDate(todayMidnight);

      final snapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('rsvps', arrayContains: uid)
          .where('date', isGreaterThanOrEqualTo: todayTimestamp)
          .orderBy('date', descending: false)
          .get();

      if (!mounted) return;

      setState(() {
        rsvpEvents = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id; // Add document ID to the data
          return data;
        }).toList();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Error loading upcoming events: ${e.toString()}")),
      );
    }
  }

  Future<void> fetchUserEvents() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('userId', isEqualTo: uid)
          .orderBy('date', descending: true)
          .get();

      if (!mounted) return;

      setState(() {
        userEvents = querySnapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id; // Add document ID to the data
          return data;
        }).toList();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading your events: ${e.toString()}")),
      );
    }
  }

  Future<void> _updateProfilePicture() async {
    final picker = ImagePicker();

    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });

        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return;

        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_pictures/${user.uid}.jpg');

        await storageRef.putFile(_profileImage!);
        final url = await storageRef.getDownloadURL();

        if (!mounted) return;

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'profilePicture': url});

        setState(() {
          if (userData != null) {
            userData!['profilePicture'] = url;
          }
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Error updating profile picture: ${e.toString()}")),
      );
    }
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Account"),
        content: const Text(
            "Are you sure you want to delete your account? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  Navigator.of(context).pop();
                  return;
                }

                // Delete user data from Firestore first
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .delete();

                // Then delete the account
                await user.delete();

                if (!mounted) return;
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).popUntil((route) => route.isFirst);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Account deleted successfully")),
                );
              } catch (e) {
                if (!mounted) return;
                Navigator.of(context).pop(); // Close dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text("Error deleting account: ${e.toString()}")),
                );
              }
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(244, 242, 230, 1),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : (userData == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Could not load profile data"),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadAllData,
                          child: const Text("Retry"),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      _buildHeader(),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: _loadAllData,
                          child: ListView(
                            padding: const EdgeInsets.all(20),
                            children: [
                              _buildStatsCard(),
                              const SizedBox(height: 20),
                              _buildCausesSection(),
                              const SizedBox(height: 20),
                              _buildSkillsSection(),
                              const SizedBox(height: 20),
                              _buildUpcomingEventsSection(),
                              const SizedBox(height: 20),
                              _buildPastEventsSection(),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Row(
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: _updateProfilePicture,
                child: CircleAvatar(
                  radius: 35,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : (userData?['profilePicture'] != null
                          ? NetworkImage(userData!['profilePicture'])
                          : const AssetImage('assets/default_avatar.png')
                              as ImageProvider),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add_a_photo, size: 18),
                    onPressed: _updateProfilePicture,
                    color: Colors.blue,
                    constraints: const BoxConstraints(
                      minWidth: 30,
                      minHeight: 30,
                    ),
                    padding: const EdgeInsets.all(6),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userData?['fullName'] ?? 'Unknown User',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'GT Ultra',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Joined ${_formatJoinDate(userData?['createdAt'])}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                try {
                  await FirebaseAuth.instance.signOut();
                  if (!mounted) return;
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Logged out successfully")),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text("Error logging out: ${e.toString()}")),
                  );
                }
              } else if (value == 'delete') {
                _showDeleteConfirmationDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'logout', child: Text('Log Out')),
              const PopupMenuItem(
                  value: 'delete', child: Text('Delete Account')),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatJoinDate(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return '${_monthName(date.month)} ${date.year}';
    }
    return 'Unknown';
  }

  static String _monthName(int month) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month];
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(41, 37, 37, 1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatColumn(label: 'Events', value: '$totalEvents'),
          _StatColumn(label: 'Skills', value: '$totalSkills'),
          _StatColumn(label: 'Causes', value: '$totalCauses'),
        ],
      ),
    );
  }

  Widget _buildCausesSection() {
    final causes = List<String>.from(userData?['causes'] ?? []);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My Causes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'GT Ultra',
          ),
        ),
        const SizedBox(height: 12),
        causes.isEmpty
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'No causes selected yet.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            : Wrap(
                spacing: 10,
                runSpacing: 10,
                children: causes.map((cause) => _customChip(cause)).toList(),
              ),
      ],
    );
  }

  Widget _buildSkillsSection() {
    final skills = List<String>.from(userData?['skills'] ?? []);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My Skills',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'GT Ultra',
          ),
        ),
        const SizedBox(height: 12),
        skills.isEmpty
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'No skills selected yet.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            : Wrap(
                spacing: 10,
                runSpacing: 10,
                children: skills.map((skill) => _customChip(skill)).toList(),
              ),
      ],
    );
  }

  Widget _buildPastEventsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My Events',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'GT Ultra',
          ),
        ),
        const SizedBox(height: 12),
        userEvents.isEmpty
            ? Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                alignment: Alignment.center,
                child: const Text(
                  'No events posted yet.\nClick the "+" button to post an event!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            : Column(
                children:
                    userEvents.map((event) => _buildEventItem(event)).toList(),
              ),
      ],
    );
  }

  Widget _buildUpcomingEventsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upcoming Events',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'GT Ultra',
          ),
        ),
        const SizedBox(height: 12),
        rsvpEvents.isEmpty
            ? Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                alignment: Alignment.center,
                child: const Text(
                  'No upcoming events.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            : Column(
                children:
                    rsvpEvents.map((event) => _buildEventItem(event)).toList(),
              ),
      ],
    );
  }

  Widget _buildEventItem(Map<String, dynamic> event) {
    final title = event['title'] ?? 'Untitled Event';

    // Handle date formatting safely
    DateTime? date;
    if (event['date'] is Timestamp) {
      date = (event['date'] as Timestamp).toDate();
    }

    final formattedDate = date != null
        ? '${date.day} ${_monthName(date.month)}, ${date.year}'
        : 'No date';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  event['location'] ?? 'No location',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formattedDate,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _customChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: const Color.fromRGBO(200, 196, 180, 0.7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide.none,
      ),
      labelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;

  const _StatColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(244, 242, 230, 1),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
