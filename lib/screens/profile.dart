//rework
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(244, 242, 230, 1),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildStatsCard(),
                  const SizedBox(height: 20),
                  _buildCausesSection(),
                  const SizedBox(height: 20),
                  _buildSkillsSection(),
                  const SizedBox(height: 20),
                  _buildPastEventsSection(),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 35,
            backgroundImage:
                AssetImage('assets/profile_pic.jpg'), // Placeholder
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Maya Thompson',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'GT Ultra',
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Joined January 2025', //check later
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
        children: const [
          _StatColumn(label: 'Events', value: '12'),
          _StatColumn(label: 'Hours', value: '48'),
          _StatColumn(label: 'Skills', value: '5'),
        ],
      ),
    );
  }

  Widget _buildCausesSection() {
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
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _customChip('Childcare'),
            _customChip('Technology'),
            _customChip('Healthcare'),
            _customChip('Business'),
          ],
        ),
      ],
    );
  }

  Widget _buildSkillsSection() {
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
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _customChip('Gardening'),
            _customChip('Communication'),
            _customChip('Teaching'),
            _customChip('Cooking'),
          ],
        ),
      ],
    );
  }

  Widget _buildPastEventsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Completed Events',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'GT Ultra',
          ),
        ),
        const SizedBox(height: 12),
        _buildEventItem('Community Garden Cleanup', 'April 15, 2025'),
        _buildEventItem('Food Drive Volunteers', 'March 30, 2025'),
        _buildEventItem('Elderly Care Assistance', 'March 10, 2025'),
      ],
    );
  }

  Widget _buildEventItem(String title, String date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          Text(date, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _customChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: Color.fromRGBO(244, 242, 230, 0.7),
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
