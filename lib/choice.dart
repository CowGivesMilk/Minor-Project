import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove debug banner
      theme: ThemeData(
        primarySwatch: Colors.green, // Green theme
      ),
      home: BusServicePage(),
    );
  }
}

class BusServicePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[900], // Dark green AppBar
        title: Text(
          'Driver Sign In',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/dashboard'); // Redirect to dashboard.dart
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green[400]!, Colors.green[200]!], // Updated gradient
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Choose your Option Accordingly",
                style: TextStyle(
                  fontSize: 27, // Increased font size (1.5 times the original 18)
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Changed font color to white
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Implement action for "Search By Fastest"
                      },
                      child: Text('Search By Fastest'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white, // Changed text color inside button to white
                        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32), // Increased button size
                        textStyle: TextStyle(fontSize: 18), // Slightly larger text
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Implement action for "Search By Shortest Path"
                      },
                      child: Text('Search By Shortest Path'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white, // Changed text color inside button to white
                        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32), // Increased button size
                        textStyle: TextStyle(fontSize: 18), // Slightly larger text
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Implement action for "Search By Cheapest"
                      },
                      child: Text('Search By Cheapest'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[500],
                        foregroundColor: Colors.white, // Changed text color inside button to white
                        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32), // Increased button size
                        textStyle: TextStyle(fontSize: 18), // Slightly larger text
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
