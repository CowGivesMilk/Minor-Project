 import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart'; // For getting the user's current location

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Current location of the user (Defaulting to Kathmandu)
  LatLng _currentLocation = LatLng(27.7172, 85.324);
  // Controller for the map
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _getCurrentLocation(); // Get user's current location on init
  }

  // Function to get the current location using Geolocator package
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Handle if the location service is disabled
      return;
    }

    // Check for permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Handle if permission is denied
        return;
      }
    }

    // Get the current position
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _mapController.move(_currentLocation, 15.0); // Move map to current location
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(), // Open burger menu
        ),
      ),
      drawer: Drawer(
        // Drawer for burger menu containing profile and options
        child: ListView(
          children: <Widget>[
            // Drawer Header with user info (Picture + Name)
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30.0,
                    backgroundImage: AssetImage('assets/bus.png'), // Default profile image
                  ),
                  SizedBox(height: 10),
                  Text(
                    'User Name', // Display the username
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
            // List of options in the drawer
            ListTile(
              title: const Text('Support'),
              onTap: () {
                // Navigate to support page
              },
            ),
            ListTile(
              title: const Text('FAQ'),
              onTap: () {
                // Navigate to FAQ page
              },
            ),
            ListTile(
              title: const Text('History'),
              onTap: () {
                // Navigate to history page
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Map section: Occupying 50% of the screen height
          Expanded(
            flex: 2,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                //center: _currentLocation, // Set map center to current location
                //zoom: 15.0, // Zoom level
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                  userAgentPackageName: 'com.example.sahayatri',
                ),
              ],
            ),
          ),
          // Second section: For current and final destination
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current location label and button
                  Row(
                    children: [
                      Icon(Icons.my_location, color: Colors.blue),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          // Action for "Current Location"
                        },
                        child: const Text('Current Location'),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Final destination label and button
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.blue),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          // Action for "Final Destination"
                        },
                        child: const Text('Final Destination'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
