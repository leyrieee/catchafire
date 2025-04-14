// ignore_for_file: avoid_print

import 'package:catchafire/screens/discover.dart';
import 'package:catchafire/screens/search.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile.dart';
import 'event_details.dart';
import 'post.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeContent(),
    SearchPage(),
    const SizedBox.shrink(),
    DiscoverPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(244, 242, 230, 1),
      body: SafeArea(child: _screens[_currentIndex]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PostPage()),
          );
        },
        backgroundColor: const Color.fromRGBO(41, 37, 37, 1),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromRGBO(244, 242, 230, 1),
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index != 2) {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        selectedItemColor: const Color.fromRGBO(41, 37, 37, 1),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: SizedBox.shrink(),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_rounded),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  final ScrollController _scrollController = ScrollController();

  HomeContent({super.key});

  Future<List<String>> _getUserSkills() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (userDoc.exists && userDoc.data()!.containsKey('skills')) {
      List<dynamic> skills = userDoc['skills'];
      return skills.cast<String>();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: FutureBuilder<List<String>>(
            future: _getUserSkills(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final skills = snapshot.data!;
              if (skills.isEmpty) {
                return const Center(child: Text('No skills selected.'));
              }

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('events')
                    .where('skills', arrayContainsAny: skills)
                    .snapshots(),
                builder: (context, eventSnapshot) {
                  if (eventSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (eventSnapshot.hasError) {
                    return Center(child: Text('Error: ${eventSnapshot.error}'));
                  }

                  if (!eventSnapshot.hasData ||
                      eventSnapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text('No matching events found.'));
                  }

                  print("Fetched Events: ${eventSnapshot.data!.docs.length}");

                  return ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(bottom: 80),
                    children: [
                      _buildWelcomeSection(),
                      ...eventSnapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;

                        return _buildEventCard(
                          context,
                          image: data['imageUrl'] ?? 'assets/default_event.jpg',
                          title: data['title'] ?? 'No Title',
                          organization: data['organization'] ?? 'Unknown Org',
                          location: data['location'] ?? 'Unknown Location',
                          date: data['date'] ?? '',
                          skills: List<String>.from(data['skills'] ?? []),
                          description: data['description'] ?? '',
                          organizerPhone: data['organizerPhone'] ?? '',
                          eventId: doc.id,
                        );
                      }),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEventCard(
    BuildContext context, {
    required String eventId,
    required String image,
    required String title,
    required String organization,
    required String location,
    required dynamic date,
    required List<String> skills,
    required String description,
    required String organizerPhone,
  }) {
    String formattedDate = '';
    if (date is Timestamp) {
      DateTime dateTime = date.toDate();
      formattedDate = DateFormat('MMM dd, yyyy').format(dateTime);
    } else if (date is String) {
      formattedDate = date;
    }

    Widget imageWidget;
    if (image.startsWith('https://drive.google.com/')) {
      final regex = RegExp(r'\/d\/([a-zA-Z0-9-_]+)\/');
      final match = regex.firstMatch(image);

      if (match != null) {
        final fileId = match.group(1);
        final directUrl = 'https://drive.google.com/uc?export=view&id=$fileId';
        imageWidget = Image.network(
          directUrl,
          height: 180,
          width: double.infinity,
          fit: BoxFit.cover,
        );
      } else {
        imageWidget = Image.asset(
          'assets/default_event.jpg',
          height: 180,
          width: double.infinity,
          fit: BoxFit.cover,
        );
      }
    } else if (image.startsWith('http') || image.startsWith('https')) {
      imageWidget = Image.network(
        image,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } else {
      imageWidget = Image.asset(
        image,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailPage(
              eventId: eventId,
              eventTitle: title,
              eventDate: formattedDate,
              eventLocation: location,
              eventDescription: description,
              organizerPhone: organizerPhone,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: imageWidget,
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
                      Text(formattedDate,
                          style: const TextStyle(
                              color: Color.fromRGBO(244, 242, 230, 1))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: skills
                        .map((skill) => Chip(
                              label: Text(skill),
                              backgroundColor:
                                  const Color.fromRGBO(244, 242, 230, 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide.none,
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset('assets/logo.png', width: 120),
          const CircleAvatar(
            backgroundColor: Color.fromRGBO(41, 37, 37, 1),
            radius: 18,
            child:
                Icon(Icons.notifications_none, color: Colors.white, size: 20),
          )
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              String greeting = 'Hello 👋';

              if (snapshot.connectionState == ConnectionState.waiting) {
                greeting = 'Hello 👋';
              } else if (snapshot.hasData && snapshot.data != null) {
                try {
                  // Get the full name from Firestore
                  String fullName = snapshot.data!.get('fullName') ?? '';

                  // Extract the first name (everything before the first space)
                  String firstName = fullName.split(' ').first;

                  if (firstName.isNotEmpty) {
                    greeting = 'Hello, $firstName 👋';
                  }
                } catch (e) {
                  greeting = 'Hello 👋';
                }
              }

              return Text(
                greeting,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(41, 37, 37, 1)),
              );
            },
          ),
          const SizedBox(height: 8),
          const Text(
            'Find events and opportunities to contribute to causes you care about.',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Color.fromRGBO(41, 37, 37, 1)),
          ),
        ],
      ),
    );
  }
}
