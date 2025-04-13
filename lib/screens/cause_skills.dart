import 'package:flutter/material.dart';
import 'home.dart';

class CauseAndSkillsPage extends StatefulWidget {
  const CauseAndSkillsPage({super.key});

  @override
  CauseAndSkillsPageState createState() => CauseAndSkillsPageState();
}

class CauseAndSkillsPageState extends State<CauseAndSkillsPage> {
  // Track selected causes and skills
  final Set<String> selectedCauses = {};
  final Set<String> selectedSkills = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(244, 242, 230, 1),
      appBar: AppBar(
        title: const Text('Tell Us About You',
            style: TextStyle(fontFamily: "Inter", fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromRGBO(41, 37, 37, 1),
        foregroundColor: const Color.fromRGBO(244, 242, 230, 1),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0), // Consistent padding
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Introduction Text
              const Text(
                'To help us understand your interests and skills, please select the causes and skills you are most passionate about. This will help match you with relevant volunteer opportunities!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Inter",
                  color: Color.fromRGBO(41, 37, 37, 1),
                ),
              ),
              const SizedBox(height: 20),

              // Causes Section
              const Text(
                'Causes You Care About',
                style: TextStyle(
                    fontFamily: "GT Ultra",
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _buildChips(
                  [
                    'Education',
                    'Environment',
                    'Science & Technology',
                    'Health',
                    'Childcare'
                  ],
                  selectedCauses,
                ),
              ),
              const SizedBox(height: 20),

              // Skills Section
              const Text(
                'Skills You Can Offer',
                style: TextStyle(
                    fontFamily: "GT Ultra",
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _buildChips(
                  [
                    'Graphic Design',
                    'Fundraising',
                    'Training',
                    'Event Planning',
                    'Communications'
                  ],
                  selectedSkills,
                ),
              ),
              const SizedBox(height: 30),

              // Save & Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    // Handle saving and continue logic
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  },
                  child: const Text(
                    'Save & Continue',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build the chips
  List<Widget> _buildChips(List<String> items, Set<String> selectedItems) {
    return items.map((item) {
      return GestureDetector(
        onTap: () {
          setState(() {
            if (selectedItems.contains(item)) {
              selectedItems.remove(item); // Deselect if already selected
            } else {
              selectedItems.add(item); // Select the item
            }
          });
        },
        child: Chip(
          label: Text(
            item,
            style: TextStyle(
              fontSize: 16, // Larger text size
              fontWeight: FontWeight.bold, // Optional: bold text
            ),
          ),
          backgroundColor: selectedItems.contains(item)
              ? const Color.fromRGBO(
                  41, 37, 37, 1) // Dark background when selected
              : Color.fromRGBO(
                  244, 242, 230, 0.7), // Transparent when not selected
          labelStyle: TextStyle(
            color: selectedItems.contains(item)
                ? Colors.white
                : const Color.fromRGBO(
                    41, 37, 37, 1), // White text when selected
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12), // Increase padding for larger chips
          side: BorderSide(
            color: selectedItems.contains(item)
                ? Colors.white // Border color when selected
                : const Color.fromRGBO(41, 37, 37, 1), // Regular border color
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24), // More rounded edges
          ),
        ),
      );
    }).toList();
  }
}
