import 'package:flutter/material.dart';
import 'event_details.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Field
            TextField(
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

            // Trending Tags / Filters
            const Text(
              'Trending Skills',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  fontFamily: "GT Ultra"),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _customChip('Leadership'),
                _customChip('Fundraising'),
                _customChip('Design'),
                _customChip('Marketing'),
              ],
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

            _buildEventCard(
              context,
              image: 'assets/tech_conference.jpeg',
              title: 'Tech for Good Conference',
              organization: 'Impact Ghana',
              location: 'Accra Digital Centre',
              date: 'April 20, 2025',
              skills: ['Programming', 'Leadership'],
            ),
            _buildEventCard(
              context,
              image: 'assets/design_jam.jpeg',
              title: 'Community Design Jam',
              organization: 'Design Lab GH',
              location: 'Kumasi Hive',
              date: 'April 25, 2025',
              skills: ['Design', 'Collaboration'],
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
}
