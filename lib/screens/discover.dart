// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/location_service.dart';
import 'event_details.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  late GoogleMapController mapController;
  LatLng? _currentLocation;
  final _locationService = LocationService();

  List<Map<String, dynamic>> _eventsFromDB = [];

  @override
  void initState() {
    super.initState();
    _initPage();
  }

  Future<void> _initPage() async {
    await _initLocation();
    await _loadEventsFromFirestore();
  }

  Future<void> _initLocation() async {
    try {
      final pos = await _locationService.getCurrentPosition();
      if (pos != null) {
        setState(() {
          _currentLocation = LatLng(pos.latitude, pos.longitude);
        });

        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await _saveLocationToFirestore(user.uid, pos.latitude, pos.longitude);
        }

        await _locationService.saveLocation(pos);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location updated and saved")),
        );
      }
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  Future<void> _saveLocationToFirestore(
      String userId, double latitude, double longitude) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'location': {
          'latitude': latitude,
          'longitude': longitude,
          'lastUpdated': FieldValue.serverTimestamp(),
        },
      });
    } catch (e) {
      if (e is FirebaseException && e.code == 'not-found') {
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'location': {
            'latitude': latitude,
            'longitude': longitude,
            'lastUpdated': FieldValue.serverTimestamp(),
          },
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        print('Error saving location to Firestore: $e');
      }
    }
  }

  Future<void> _loadEventsFromFirestore() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('events').get();
      final events = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'title': data['title'],
          'latitude': data['latitude'],
          'longitude': data['longitude'],
          'organization': data['organization'],
          'date': (data['date'] as Timestamp).toDate(),
          'skills': data['skills'],
          'location': data['location'],
          'description': data['description'],
          'organizerPhone': data['organizerPhone'],
        };
      }).toList();

      setState(() {
        _eventsFromDB = events;
      });
    } catch (e) {
      print('Error fetching events: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Discover Nearby',
          style: TextStyle(fontFamily: "GT Ultra", fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromRGBO(244, 242, 230, 1),
        centerTitle: true,
      ),
      body: _currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Discover events and activities happening near you. Tap a marker to learn more!",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Expanded(
                  child: GoogleMap(
                    onMapCreated: (controller) => mapController = controller,
                    initialCameraPosition: CameraPosition(
                      target: _currentLocation!,
                      zoom: 10,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId('currentLocation'),
                        position: _currentLocation!,
                        infoWindow: const InfoWindow(title: 'You Are Here'),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueAzure),
                      ),
                      ..._eventsFromDB.map((event) {
                        return Marker(
                          markerId: MarkerId(event['id']),
                          position:
                              LatLng(event['latitude'], event['longitude']),
                          infoWindow: InfoWindow(
                            title: event['title'],
                            onTap: () {
                              _showEventDetailsSheet(event);
                            },
                          ),
                        );
                      }),
                    },
                  ),
                ),
              ],
            ),
    );
  }

  void _showEventDetailsSheet(Map<String, dynamic> event) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: const Color.fromRGBO(255, 255, 255, 0.98),
      builder: (context) {
        final DateTime date = event['date'];
        final String formattedDate =
            "${date.day}/${date.month}/${date.year} • ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event['title'],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  fontFamily: "GT Ultra",
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Hosted by: ${event['organization']}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 18, color: Colors.grey),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      event['location'],
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 18, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(formattedDate, style: const TextStyle(fontSize: 14)),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close bottom sheet
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventDetailPage(
                          eventId: event['id'],
                          eventTitle: event['title'],
                          eventDate: event['date'],
                          eventLocation: event['location'],
                          eventDescription: event['description'],
                          organizerPhone: event['organizerPhone'],
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(244, 242, 230, 1),
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: const Text(
                    "View Details",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
