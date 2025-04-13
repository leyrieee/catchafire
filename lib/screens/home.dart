import 'package:catchafire/screens/discover.dart';
import 'package:catchafire/screens/search.dart';
import 'package:flutter/material.dart';
import 'profile.dart';
import 'event_details.dart';
import 'post.dart';

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
    const SizedBox.shrink(), // middle FAB button — skip
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.only(bottom: 80),
            children: [
              _buildWelcomeSection(),
              _buildEventCard(
                context,
                image: 'assets/community_garden.jpeg',
                title: 'Community Garden Cleanup',
                organization: 'Green City Initiative',
                location: 'Central Park, NY',
                date: 'April 15, 2025',
                skills: ['Gardening', 'Physical labor'],
              ),
              _buildEventCard(
                context,
                image: 'assets/teach_coding.jpeg',
                title: 'Teach Coding to Kids',
                organization: 'Tech for All',
                location: 'Downtown Library',
                date: 'April 18, 2025',
                skills: ['Programming', 'Teaching'],
              ),
              _buildEventCard(
                context,
                image: 'assets/food_drive.jpeg',
                title: 'Food Drive Volunteers',
                organization: 'Food for Families',
                location: 'Community Center',
                date: 'April 22, 2025',
                skills: ['Organization', 'Communication'],
              ),
              _buildEventCard(
                context,
                image: 'assets/elderly_care.jpeg',
                title: 'Elderly Care Assistance',
                organization: 'Golden Years Foundation',
                location: 'Sunset Homes',
                date: 'April 25, 2025',
                skills: ['Healthcare', 'Compassion'],
              ),
            ],
          ),
        ),
      ],
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
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello, Maya 👋',
            style: TextStyle(
                fontFamily: 'GT Ultra',
                fontSize: 26,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6),
          Text(
            'Volunteer opportunities, handpicked for you!',
            style: TextStyle(
                fontFamily: 'Inter', fontSize: 16, color: Colors.grey),
          ),
          SizedBox(height: 12),
        ],
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
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
}
