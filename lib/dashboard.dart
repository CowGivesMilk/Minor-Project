import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';

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
  late List<String> locations = []; // List to store unique locations from the CSV file.

  @override
  void initState() {
    super.initState();
    loadLocations(); // Load locations from the CSV file.
  }

  Future<void> loadLocations() async {
    try {
      final csvData = await rootBundle.loadString('assets/Routes.csv');
      final List<List<dynamic>> rowsAsListOfValues =
      const CsvToListConverter().convert(csvData);

      // Use a Set to store unique locations
      final Set<String> uniqueLocations = rowsAsListOfValues
          .skip(1) // Skip the header row
          .map((row) => row[0].toString().trim()) // Extract the first column
          .toSet();

      setState(() {
        locations = uniqueLocations.toList(); // Convert back to a list
      });

      print("Unique locations loaded: $locations"); // Debug: Print loaded locations
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
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer();
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
              accountName:
              const Text('Nimesh Poudel', style: TextStyle(color: Colors.white)),
              accountEmail: const Text('n@p.com', style: TextStyle(color: Colors.white70)),
              currentAccountPicture: const CircleAvatar(
                backgroundImage: AssetImage('assets/profile_picture.png'),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.support),
              title: const Text('Support'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.question_answer),
              title: const Text('FAQ'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('History'),
              onTap: () {},
            ),
          ],
        ),
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
          title:
          Text('Choose ${locationType == "current" ? "Current Location" : "Final Destination"}'),
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
                      } else {
                        finalDestination = selectedLocation;
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
                        content: TypeAheadFormField(
                          textFieldConfiguration: TextFieldConfiguration(
                            controller: locationSearchController,
                            decoration: const InputDecoration(
                              hintText: 'Type a location name',
                            ),
                          ),
                          suggestionsCallback: (pattern) {
                            final suggestions = locations.where(
                                  (location) => location
                                  .toLowerCase()
                                  .contains(pattern.toLowerCase()),
                            );
                            print(
                                "Suggestions for '$pattern': ${suggestions.toList()}"); // Debugging
                            return suggestions;
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
                                print("Selected Current Location: $suggestion");
                                // Add logic to convert suggestion to LatLng.
                              } else {
                                print("Selected Final Destination: $suggestion");
                                // Add logic to convert suggestion to LatLng.
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

class MapPicker extends StatefulWidget {
  final LatLng? currentLocation;
  final LatLng? finalDestination;

  const MapPicker({
    Key? key,
    this.currentLocation,
    this.finalDestination,
  }) : super(key: key);

  @override
  State<MapPicker> createState() => _MapPickerState();
}

class _MapPickerState extends State<MapPicker> {
  LatLng? selectedLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF32CD32),
        title: const Text('Select Location'),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter:
          widget.currentLocation ?? widget.finalDestination ?? LatLng(27.7172, 85.3240),
          initialZoom: 15.0,
          onTap: (tapPosition, point) {
            setState(() {
              selectedLocation = point;
            });
          },
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
            userAgentPackageName: 'com.example.app',
          ),
          if (widget.currentLocation != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: widget.currentLocation!,
                  width: 40.0,
                  height: 40.0,
                  child: const Icon(Icons.location_pin, color: Colors.blue, size: 40),
                ),
              ],
            ),
          if (widget.finalDestination != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: widget.finalDestination!,
                  width: 40.0,
                  height: 40.0,
                  child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                ),
              ],
            ),
          if (selectedLocation != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: selectedLocation!,
                  width: 40.0,
                  height: 40.0,
                  child: const Icon(Icons.location_pin, color: Colors.orange, size: 40),
                ),
              ],
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context, selectedLocation);
        },
        backgroundColor: const Color(0xFF32CD32),
        child: const Icon(Icons.check),
      ),
    );
  }
}
