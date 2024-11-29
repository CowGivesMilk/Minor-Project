import 'package:flutter/material.dart';
import 'sign_up_page.dart'; // Import the SignUpPage
import 'dashboard.dart'; // Import the Dashboard page
import 'api_service.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // Function to handle sign-in logic
  void _signIn() async {
    setState(() => _isLoading = true); // Show loading indicator
    try {
      // Attempt login via the ApiService
      final response = await ApiService.login(
        _emailController.text,
        _passwordController.text,
      );

      // If login is successful, show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login Successful!')),
      );

      // Navigate to the Dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Dashboard()), // Replace the current page with Dashboard
      );
    } catch (error) {
      // If login fails, show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login Failed: $error')),
      );
    } finally {
      setState(() => _isLoading = false); // Stop the loading indicator
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In'), backgroundColor: Colors.green),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Align children to stretch
          children: [
            // Email TextField
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            // Password TextField
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 30),
            // Sign In Button
            ElevatedButton(
              onPressed: _isLoading ? null : _signIn, // Disable button when loading
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white) // Show loading spinner
                  : const Text('Sign In', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 20),
            // Text for navigating to the SignUpPage
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUpPage()), // Navigate to SignUpPage
                  );
                },
                child: const Text(
                  "Don't have an Account?",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
