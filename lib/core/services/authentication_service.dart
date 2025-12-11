import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthenticationService {
  static AuthenticationService? _instance;
  static const String _baseUrl = 'https://reqres.in/api/login';

  // Singleton pattern implementation
  static AuthenticationService get instance {
    _instance ??= AuthenticationService._internal();
    return _instance!;
  }

  factory AuthenticationService() {
    return instance;
  }

  AuthenticationService._internal();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'X-API-Key': 'reqres_8b13e904674a414790a1d0115cd034d8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        // Login successful
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'token': data['token'] ?? '',
          'message': 'Login successful'
        };
      } else {
        // Login failed
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'token': '',
          'message': data['error'] ?? 'Login failed'
        };
      }
    } catch (e) {
      // Network error or other exception
      return {
        'success': false,
        'token': '',
        'message': 'Network error: $e'
      };
    }
  }

  Future<void> logout() async {
    // No API call needed for logout, but could be added if server-side invalidation is needed
  }
}