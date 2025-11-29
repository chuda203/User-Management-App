import '../models/login_response.dart';

class LoginMockService {
  Future<LoginResponse> login(String email, String password) async {
    // Simulate network delay (reduced for better UX)
    await Future.delayed(const Duration(milliseconds: 300));

    // Mock validation - check if email and password are not empty and email is valid
    bool isValidEmail = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
    if (email.isNotEmpty && password.isNotEmpty && isValidEmail) {
      return LoginResponse(
        token: 'mock_token_12345',
        success: true,
        message: 'Login successful',
      );
    } else {
      return LoginResponse(
        token: '',
        success: false,
        message: 'Invalid credentials',
      );
    }
  }
}