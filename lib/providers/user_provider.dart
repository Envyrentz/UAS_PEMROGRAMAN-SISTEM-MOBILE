

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _token = "";
  String _gatau = "";
  String _authorId = "";
  String _authorName = "";

  bool get isLoggedIn => _isLoggedIn;
  String get token => _token;
  String get gatau => _gatau;
  String get authorId => _authorId;
  String get authorName => _authorName;

  Future<void> checkAuthStatus() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? authToken = prefs.getString('authToken');
      final String? gatau = prefs.getString('gatau');

      

      // Update the local variable with the value from SharedPreferences
      _gatau = gatau ?? ""; // Use the null-aware operator to handle null values

      if (authToken != null) {
        // User is authenticated, set the global state to true
        _isLoggedIn = true;
        notifyListeners();
      } else {
        // If there is no stored token, attempt to fetch it from cookies
        final Uri apiUrl = Uri.parse('https://auspicious-life-401200.et.r.appspot.com/checkAuth');
        final http.Response response = await http.get(
          apiUrl,
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          // Extract the auth token from response cookies
          final String? authTokenFromCookies = extractAuthTokenFromCookies(response.headers);

          if (authTokenFromCookies != null) {
            // Save the token in shared preferences
            prefs.setString('authToken', authTokenFromCookies);
            _isLoggedIn = true;
            notifyListeners();
          } else {
            // User is not authenticated
            _isLoggedIn = false;
            notifyListeners();
          }
        } else {
          // User is not authenticated
          _isLoggedIn = false;
          notifyListeners();
        }
      }
    } catch (error) {
      print('Authentication check error: $error');
    }
  }

  // Helper method to extract the auth token from set-cookie headers
  String? extractAuthTokenFromCookies(Map<String, String>? headers) {
    if (headers != null) {
      final String? setCookieHeader = headers['set-cookie'];
      if (setCookieHeader != null && setCookieHeader.contains('ANTONIO-AUTH')) {
        final List<String> parts = setCookieHeader.split(';');
        final String authToken = parts.first.split('=')[1];
        return authToken;
      }
    }
    return null;
  }

 Future<void> login(String authToken,String authorId,String authorName) async {
  try {
    // Perform login logic, and if successful:
    // Save authentication token and "gatau" in shared preferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('authToken', authToken);
    prefs.setString('gatau', "gatau");
    _token = authToken;
    _authorId = authorId;
    _authorName = authorName;

    _isLoggedIn = true;
    notifyListeners();
  } catch (error) {
    print('Login error: $error');
  }
}


  Future<void> logout() async {
    try {
      // Perform logout logic, and if successful:
      // Remove authentication token and "gatau" from shared preferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove('authToken');
      prefs.remove('gatau');

      _isLoggedIn = false;
      notifyListeners();
    } catch (error) {
      print('Logout error: $error');
    }
  }
}
