import 'package:flutter/material.dart';
import 'api_service.dart'; // Added this import

class SignUpPage extends StatefulWidget { // Changed to StatefulWidget
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameController = TextEditingController(); // Added controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false; // Loading state

  // Function to handle sign-up
  void _signUp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final message = await ApiiService.signup(
        _nameController.text,
        _emailController.text,
        _passwordController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      Navigator.pushNamed(context, '/signin'); // Navigate to Sign-In page
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
        title: const Text('Sign Up'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Name Field
            TextField(
              controller: _nameController, // Added controller
              decoration: InputDecoration(
                labelText: 'Name',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
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
            // Sign Up Button
            ElevatedButton(
              onPressed: _isLoading ? null : _signUp, // Updated onPressed
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
                'Sign Up',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            // Navigate to Sign In
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signin');
              },
              child: const Text(
                'Already have an account? Sign In',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
