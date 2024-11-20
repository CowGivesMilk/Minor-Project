import 'package:flutter/material.dart';
import 'api_service.dart'; // Added this import

class SignInPage extends StatefulWidget { // Changed from StatelessWidget to StatefulWidget
  const SignInPage({super.key});

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailController = TextEditingController(); // Added controllers
  final _passwordController = TextEditingController();

  bool _isLoading = false; // Added a loading state

  // Function to handle sign-in
  void _signIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.login(
        _emailController.text,
        _passwordController.text,
      );
      // Navigate or show success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Welcome, ${response['user']['username']}!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Email Field
            TextField(
              controller: _emailController, // Added controller
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            // Password Field
            TextField(
              controller: _passwordController, // Added controller
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 30),
            // Sign In Button
            ElevatedButton(
              onPressed: _isLoading ? null : _signIn, // Updated onPressed
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white) // Loading indicator
                  : const Text(
                'Sign In',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            // Navigate to Sign Up
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signup');
              },
              child: const Text(
                'Don\'t have an account? Sign Up',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
