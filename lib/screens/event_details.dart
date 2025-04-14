import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventDetailPage extends StatelessWidget {
  final String eventId;
  final String eventTitle;
  final String eventDate;
  final String eventLocation;
  final String eventDescription;
  final String organizerPhone;
  final String? imageUrl;
  final List<String>? skills;

  const EventDetailPage({
    super.key,
    required this.eventId,
    required this.eventTitle,
    required this.eventDate,
    required this.eventLocation,
    required this.eventDescription,
    required this.organizerPhone,
    this.imageUrl,
    this.skills,
  });

  void _rsvp(BuildContext context, String eventId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final eventRef =
          FirebaseFirestore.instance.collection('events').doc(eventId);

      // Add the user to the rsvps array (if not already added)
      await eventRef.update({
        'rsvps': FieldValue.arrayUnion([uid])
      });

      // Show confirmation dialog
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("RSVP Confirmed"),
          content: const Text("Thanks for your interest! You're on the list."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Optionally trigger a refresh in ProfilePage if needed
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Added to your Upcoming Events.")),
                );
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to RSVP. Please try again.")),
      );
    }
  }

  Future<void> _callOrganizer() async {
    final Uri callUri = Uri(scheme: 'tel', path: organizerPhone);
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      debugPrint("Could not launch phone dialer");
    }
  }

  Future<void> _openInMaps() async {
    final Uri mapUri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(eventLocation)}');
    if (await canLaunchUrl(mapUri)) {
      await launchUrl(mapUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(250, 249, 245, 1),
      appBar: AppBar(
        title: Text(eventTitle),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(244, 242, 230, 1),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 20),
              Text(
                eventTitle,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 18),
                  const SizedBox(width: 6),
                  Text(eventDate, style: const TextStyle(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                      child: Text(eventLocation,
                          style: const TextStyle(fontSize: 16))),
                  IconButton(
                    icon: const Icon(Icons.map_outlined),
                    onPressed: _openInMaps,
                    tooltip: 'Open in Maps',
                  ),
                ],
              ),
              if (skills != null && skills!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: skills!
                      .map((skill) => Chip(
                            label: Text(skill),
                            backgroundColor: Colors.teal.shade100,
                          ))
                      .toList(),
                ),
              ],
              const SizedBox(height: 20),
              const Text(
                'About this event',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                eventDescription,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _rsvp(context, eventId),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('RSVP'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _callOrganizer,
                      icon: const Icon(Icons.call),
                      label: const Text('Call'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[700],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
