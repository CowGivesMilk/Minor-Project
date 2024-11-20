import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.1.69:5000';

  // Login function
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['error']);
    }
  }
}

//signup ko lagi
class ApiiService {
  static const String baseUrl = 'http://192.168.1.69:5000'; // Adjust to your backend URL

  // Sign-Up method
  static Future<String> signup(String username, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'email': email, 'password': password}),
    );

    if (response.statusCode == 201) {
      return 'User registered successfully!';
    } else {
      throw Exception(jsonDecode(response.body)['error']);
    }
  }
}