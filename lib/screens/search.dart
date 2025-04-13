import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'event_details.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String searchQuery = '';
  List<Map<String, dynamic>> allEvents = [];
  List<Map<String, dynamic>> filteredEvents = [];

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('events').get();
    final events = querySnapshot.docs.map((doc) => doc.data()).toList();

    setState(() {
      allEvents = events;
      filteredEvents = events;
    });
  }

  void _searchEvents(String query) {
    final lowerQuery = query.toLowerCase();

    setState(() {
      searchQuery = query;
      filteredEvents = allEvents.where((event) {
        final title = event['title']?.toLowerCase() ?? '';
        final skills = List<String>.from(event['skills'] ?? []);
        final skillMatch =
            skills.any((s) => s.toLowerCase().contains(lowerQuery));
        return title.contains(lowerQuery) || skillMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(244, 242, 230, 1),
      appBar: AppBar(
        title: const Text(
          'Search',
          style: TextStyle(fontFamily: "GT Ultra", fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromRGBO(244, 242, 230, 1),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Field
            TextField(
              onChanged: _searchEvents,
              decoration: InputDecoration(
                hintText: 'Search events, skills...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Recommended Events',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  fontFamily: "GT Ultra"),
            ),
            const SizedBox(height: 12),

            // Event Results
            Expanded(
              child: filteredEvents.isEmpty
                  ? const Center(child: Text('No events found.'))
                  : ListView.builder(
                      itemCount: filteredEvents.length,
                      itemBuilder: (context, index) {
                        final event = filteredEvents[index];
                        return _buildEventCard(
                          context,
                          image: event['image'] ?? 'assets/default_event.jpg',
                          title: event['title'] ?? 'No Title',
                          organization: event['organization'] ?? 'Unknown Org',
                          location: event['location'] ?? 'Unknown Location',
                          date: event['date'] ?? 'TBD',
                          skills: List<String>.from(event['skills'] ?? []),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(
    BuildContext context, {
    required String image,
    required String title,
    required String organization,
    required String location,
    required String date,
    required List<String> skills,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => EventDetailPage(eventTitle: title)),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 12, offset: Offset(0, 6)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.asset(image,
                  height: 180, width: double.infinity, fit: BoxFit.cover),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color.fromRGBO(41, 37, 37, 1),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 18,
                          color: Color.fromRGBO(244, 242, 230, 1),
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(organization,
                      style: const TextStyle(
                          color: Color.fromRGBO(244, 242, 230, 1),
                          fontSize: 14)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 16, color: Color.fromRGBO(244, 242, 230, 1)),
                      const SizedBox(width: 4),
                      Text(location,
                          style: const TextStyle(
                              color: Color.fromRGBO(244, 242, 230, 1))),
                      const SizedBox(width: 16),
                      const Icon(Icons.calendar_today,
                          size: 16, color: Color.fromRGBO(244, 242, 230, 1)),
                      const SizedBox(width: 4),
                      Text(date,
                          style: const TextStyle(
                              color: Color.fromRGBO(244, 242, 230, 1))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        skills.map((skill) => _customChip(skill)).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _customChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: const Color.fromRGBO(244, 242, 230, 1),
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
