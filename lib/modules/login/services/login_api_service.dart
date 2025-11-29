import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/login_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginApiService {
  static const String _baseUrl = 'https://reqres.in/api/login';

  Future<LoginResponse> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'X-API-Key': 'reqres-free-v1',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        // Login successful - save token to shared preferences
        final data = jsonDecode(response.body);
        String token = data['token'] ?? '';

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        return LoginResponse(
          token: token,
          success: true,
          message: 'Login successful',
        );
      } else {
        // Login failed
        final data = jsonDecode(response.body);
        String message = data['error'] ?? 'Login failed';
        return LoginResponse(token: '', success: false, message: message);
      }
    } catch (e) {
      // Network error or other exception
      return LoginResponse(
        token: '',
        success: false,
        message: 'Network error: $e',
      );
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Future<String?> getSavedToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<bool> hasValidToken() async {
    String? token = await getSavedToken();
    return token != null && token.isNotEmpty;
  }
}
