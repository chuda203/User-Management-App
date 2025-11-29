import 'package:flutter/foundation.dart';

// View model for splash screen
// Handles authentication checks and navigation logic
class SplashViewModel extends ChangeNotifier {
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  Future<bool> checkAuthentication() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Add a small delay to ensure UI renders properly
      await Future.delayed(const Duration(milliseconds: 500));

      _isLoading = false;
      notifyListeners();

      // This method will be implemented with LoginViewModel passed from the view
      return false; // Default implementation - will be overridden in the view
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}