import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/login_response.dart';
import '../../../core/services/auth_storage_service.dart';

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

        await AuthStorageService.saveToken(token);

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
    await AuthStorageService.removeToken();
  }

  Future<String?> getSavedToken() async {
    return await AuthStorageService.getToken();
  }

  Future<bool> hasValidToken() async {
    return await AuthStorageService.hasToken();
  }
}
