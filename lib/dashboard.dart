import 'package:flutter/material.dart';

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
                'John Doe',
                style: TextStyle(color: Colors.white),
              ), // Replace with the actual username
              accountEmail: const Text(
                'johndoe@example.com',
                style: TextStyle(color: Colors.white70),
              ), // Replace with the user's email
              currentAccountPicture: CircleAvatar(
                backgroundImage: AssetImage('assets/profile_picture.png'), // Replace with the actual profile picture
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
            child: Container(
              color: Colors.grey[200], // Placeholder color
              child: const Center(
                child: Text(
                  'Map goes here',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ), // Replace this with OpenStreetMap integration
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
                  TextField(
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
                  const SizedBox(height: 20),
                  // Final Destination Input
                  TextField(
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
}
