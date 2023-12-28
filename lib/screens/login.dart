import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/user_provider.dart'; // Update the import path

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double textFieldWidth = MediaQuery.of(context).size.width * 1.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
            child: const Text('Home'),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: textFieldWidth,
                child: TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
              ),
              const SizedBox(height: 16.0),
              Container(
                width: textFieldWidth,
                child: TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  _login();
                },
                child: const Text('Login'),
              ),
              const SizedBox(height: 16.0),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/register');
                },
                child: const Text('Don\'t have an account? Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _login() async {
    final String email = emailController.text;
    final String password = passwordController.text;

    final Uri apiUrl =
        Uri.parse('https://auspicious-life-401200.et.r.appspot.com/auth/login');
    final http.Response response = await http.post(
      apiUrl,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      // Successfully logged in, extract the session token from the response
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final String sessionToken = responseData['token'];
      final String userId = responseData['_id'];
      final String userName = responseData['username'];

      print(userId);

      saveAuthToken(sessionToken);

      // Pass the session token to the login method
      Provider.of<UserProvider>(context, listen: false)
          .login(sessionToken, userId, userName);

      // Navigate to the home page
      Navigator.pushReplacementNamed(context, '/');
    } else {
      // Handle login failure and show a dialog
      print('Login failed: ${response.statusCode}');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Login Failed'),
          content: Text(
              'Login failed. Please check your email and password and try again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  // Common method to save the authentication token locally
  Future<void> saveAuthToken(String authToken) async {
    // Use shared_preferences for mobile
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('authToken', authToken);
  }
}
