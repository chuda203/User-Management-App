import '../models/login_model.dart';

class LoginMockService {
  Future<LoginResponse> login(String username, String password) async {
    // Simulate network delay (reduced for better UX)
    await Future.delayed(const Duration(milliseconds: 300));

    // Mock validation - any non-empty username and password is valid
    if (username.isNotEmpty && password.isNotEmpty) {
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