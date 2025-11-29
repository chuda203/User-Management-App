import 'package:flutter/material.dart';
import '../models/login_response.dart';
import '../services/login_api_service.dart';

class LoginViewModel extends ChangeNotifier {
  final LoginApiService _loginService = LoginApiService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<LoginResponse> loginUser(String email, String password) async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      final response = await _loginService.login(email, password);
      if (response.success) {
        _setErrorMessage(null);
      } else {
        _setErrorMessage(response.message);
      }
      return response;
    } catch (e) {
      _setErrorMessage('An error occurred: ${e.toString()}');
      return LoginResponse(
        token: '',
        success: false,
        message: 'An error occurred: ${e.toString()}',
      );
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _setErrorMessage(null);
  }

  Future<void> logout() async {
    await _loginService.logout();
  }

  Future<String?> getSavedToken() async {
    return await _loginService.getSavedToken();
  }

  Future<bool> hasValidToken() async {
    return await _loginService.hasValidToken();
  }
}