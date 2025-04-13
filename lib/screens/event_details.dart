//rework

import 'package:flutter/material.dart';

class EventDetailPage extends StatelessWidget {
  final String eventTitle;

  const EventDetailPage({super.key, required this.eventTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(eventTitle)),
      body: Center(
        child: Text('More details about $eventTitle'),
      ),
    );
  }
}
