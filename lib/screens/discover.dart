import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/location_service.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  late GoogleMapController mapController;
  LatLng? _currentLocation;
  final _locationService = LocationService();

  final List<Map<String, dynamic>> _events = [
    {
      'title': 'Tech for Good Conference',
      'position': LatLng(5.5600, -0.2050),
    },
    {
      'title': 'Community Design Jam',
      'position': LatLng(6.6900, -1.6300),
    },
    {
      'title': 'Green Ghana Cleanup',
      'position': LatLng(5.6500, -0.1600),
    },
  ];

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
  try {
    final pos = await _locationService.getCurrentPosition();
    if (pos != null) {
      print("Location retrieved: ${pos.latitude}, ${pos.longitude}");
      setState(() {
        _currentLocation = LatLng(pos.latitude, pos.longitude);
      });

      await _locationService.saveLocation(pos);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location updated and saved")),
      );
    }
  } catch (e) {
    print("Error getting location: $e");
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
                      ..._events.map(
                        (event) => Marker(
                          markerId: MarkerId(event['title']),
                          position: event['position'],
                          infoWindow: InfoWindow(title: event['title']),
                        ),
                      ),
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

