import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart'; // For accessing current location

class Dashboard extends StatelessWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF32CD32), // Green theme color
        elevation: 0,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer(); // Open burger menu
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF32CD32)),
              accountName: const Text(
                'Nimesh Poudel',
                style: TextStyle(color: Colors.white),
              ),
              accountEmail: const Text(
                'n@p.com',
                style: TextStyle(color: Colors.white70),
              ),
              currentAccountPicture: const CircleAvatar(
                backgroundImage: AssetImage(
                    'assets/profile_picture.png'), // Replace with the actual profile picture
              ),
            ),
            ListTile(
              leading: const Icon(Icons.support),
              title: const Text('Support'),
              onTap: () {
                // Navigate to Support page
              },
            ),
            ListTile(
              leading: const Icon(Icons.question_answer),
              title: const Text('FAQ'),
              onTap: () {
                // Navigate to FAQ page
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('History'),
              onTap: () {
                // Navigate to History page
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // First Section: Map
          Expanded(
            flex: 5, // 50% of the screen
            child: FlutterMap(
              options: MapOptions(
                initialCenter:
                LatLng(27.7172, 85.3240), // Kathmandu coordinates
                initialZoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                  "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                  userAgentPackageName: 'com.example.app',
                ),
              ],
            ),
          ),
          // Second Section: Location options
          Expanded(
            flex: 5, // 50% of the screen
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Current Location Input
                  GestureDetector(
                    onTap: () => _showLocationOptions(context, "Current Location"),
                    child: TextField(
                      enabled: false, // Disable direct input
                      decoration: InputDecoration(
                        hintText: 'Current Location',
                        filled: true,
                        fillColor: Colors.green[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Final Destination Input
                  GestureDetector(
                    onTap: () => _showLocationOptions(context, "Final Destination"),
                    child: TextField(
                      enabled: false, // Disable direct input
                      decoration: InputDecoration(
                        hintText: 'Final Destination',
                        filled: true,
                        fillColor: Colors.green[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Submit Button
                  ElevatedButton(
                    onPressed: () {
                      // Add navigation logic to calculate routes
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF32CD32),
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Start Journey',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Method to show location options dialog
  void _showLocationOptions(BuildContext context, String locationType) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Choose $locationType'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Image.asset(
                  'assets/map.png', // Replace with the updated icon path
                  width: 24,
                  height: 24,
                ),
                title: const Text('Choose on Map'),
                onTap: () {
                  Navigator.pop(context);
                  // Logic to open map and let the user choose a location
                },
              ),
              ListTile(
                leading: const Icon(Icons.search),
                title: const Text('Search Location'),
                onTap: () {
                  Navigator.pop(context);
                  _showSearchLocation(context, locationType);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Method to show search location input dialog
  void _showSearchLocation(BuildContext context, String locationType) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Search $locationType'),
          content: TextField(
            decoration: InputDecoration(
              hintText: 'Enter $locationType',
              filled: true,
              fillColor: Colors.green[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (value) {
              Navigator.pop(context);
              // Use the entered value for further processing
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Method to get current location using Geolocator
  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, request user to enable them
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, handle appropriately
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied, handle appropriately
      throw Exception('Location permissions are permanently denied.');
    }

    // Retrieve the current position
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }
}