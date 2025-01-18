import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import 'choice.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  LatLng? currentLocation;
  LatLng? finalDestination;
  final String currentLocationName = "Current Location";
  final String finalDestinationName = "Final Destination";
  late Map<String, LatLng> locationCoordinates = {}; // Map to store locations and their coordinates.

  // Controllers for the TextFields to show the selected location names.
  TextEditingController currentLocationController = TextEditingController();
  TextEditingController finalDestinationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadLocations(); // Load locations from the CSV file.
  }

  Future<void> loadLocations() async {
    try {
      final csvData = await rootBundle.loadString('assets/Routes.csv');
      final List<List<dynamic>> rowsAsListOfValues = const CsvToListConverter().convert(csvData);

      // Populate the map with location names and their coordinates.
      for (var row in rowsAsListOfValues.skip(1)) {
        final String locationName = row[0].toString().trim();
        final double latitude = double.parse(row[1].toString());
        final double longitude = double.parse(row[2].toString());
        locationCoordinates[locationName] = LatLng(latitude, longitude);
      }

      print("Locations loaded: $locationCoordinates"); // Debug: Print loaded locations
    } catch (error) {
      print('Error loading CSV: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF32CD32),
        elevation: 0,
        title: const Text("Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              // Show a modal bottom sheet for the menu options
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.home),
                        title: const Text('Home'),
                        onTap: () {
                          Navigator.pushNamed(context, '/'); // Navigate to home
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.settings),
                        title: const Text('Settings'),
                        onTap: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Settings clicked')),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.history), // Icon for View History
                        title: const Text('View History'), // Title text
                        onTap: () {
                          Navigator.pop(context); // Close the drawer or pop the current context
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('View History clicked')), // Snackbar message
                          );
                        },
                      ),

                      ListTile(
                        leading: const Icon(Icons.logout),
                        title: const Text('Log Out'),
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/signin');
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(27.7172, 85.3240),
                initialZoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                  userAgentPackageName: 'com.example.app',
                ),
                if (currentLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: currentLocation!,
                        width: 40.0,
                        height: 40.0,
                        child: const Icon(Icons.location_pin,
                            color: Colors.blue, size: 40),
                      ),
                    ],
                  ),
                if (finalDestination != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: finalDestination!,
                        width: 40.0,
                        height: 40.0,
                        child: const Icon(Icons.location_pin,
                            color: Colors.red, size: 40),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => _showLocationOptions(context, "current"),
                    child: TextField(
                      controller: currentLocationController,
                      enabled: false,
                      decoration: InputDecoration(
                        hintText: currentLocationName,
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
                  GestureDetector(
                    onTap: () => _showLocationOptions(context, "final"),
                    child: TextField(
                      controller: finalDestinationController,
                      enabled: false,
                      decoration: InputDecoration(
                        hintText: finalDestinationName,
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
                  ElevatedButton(
                    onPressed: () {
                      if (currentLocation != null && finalDestination != null) {
                        print(
                            "Journey started from (${currentLocation!.latitude}, ${currentLocation!.longitude}) to (${finalDestination!.latitude}, ${finalDestination!.longitude})");
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => BusServicePage()), // Create an instance of BusServicePage
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please select both locations."),
                          ),
                        );
                      }
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

  void _showLocationOptions(BuildContext context, String locationType) {
    TextEditingController locationSearchController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Choose ${locationType == "current" ? "Current Location" : "Final Destination"}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Image.asset(
                  'assets/map.png',
                  width: 24,
                  height: 24,
                ),
                title: const Text('Choose on Map'),
                onTap: () async {
                  Navigator.pop(context);
                  final selectedLocation = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapPicker(
                        currentLocation: currentLocation,
                        finalDestination: finalDestination,
                      ),
                    ),
                  );
                  if (selectedLocation != null) {
                    setState(() {
                      if (locationType == "current") {
                        currentLocation = selectedLocation;
                        currentLocationController.text =
                        "(${selectedLocation.latitude}, ${selectedLocation.longitude})";
                      } else {
                        finalDestination = selectedLocation;
                        finalDestinationController.text =
                        "(${selectedLocation.latitude}, ${selectedLocation.longitude})";
                      }
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.search),
                title: const Text('Search Location'),
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Enter Location Name'),
                        content: TypeAheadFormField<String>(
                          textFieldConfiguration: TextFieldConfiguration(
                            controller: locationSearchController,
                            decoration: const InputDecoration(
                              hintText: 'Type a location name',
                            ),
                          ),
                          suggestionsCallback: (pattern) {
                            return locationCoordinates.keys
                                .where((location) => location.toLowerCase().contains(pattern.toLowerCase()))
                                .toList();
                          },
                          itemBuilder: (context, suggestion) {
                            return ListTile(
                              title: Text(suggestion),
                            );
                          },
                          onSuggestionSelected: (suggestion) {
                            Navigator.pop(context);
                            setState(() {
                              if (locationType == "current") {
                                currentLocation = locationCoordinates[suggestion];
                                currentLocationController.text = suggestion;
                              } else {
                                finalDestination = locationCoordinates[suggestion];
                                finalDestinationController.text = suggestion;
                              }
                            });
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class MapPicker extends StatelessWidget {
  final LatLng? currentLocation;
  final LatLng? finalDestination;

  const MapPicker({
    Key? key,
    this.currentLocation,
    this.finalDestination,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF32CD32),
        title: const Text('Select Location'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Goes back to the previous screen
          },
        ),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: currentLocation ?? finalDestination ?? LatLng(27.7172, 85.3240),
          initialZoom: 15.0,
          onTap: (tapPosition, point) {
            Navigator.pop(context, point); // Returning selected point back to previous screen
          },
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
            userAgentPackageName: 'com.example.app',
          ),
        ],
      ),
    );
  }
}
