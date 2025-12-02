import 'package:flutter/foundation.dart';
import '../../../core/services/auth_storage_service.dart';

// View model for splash screen
// Handles authentication checks and navigation logic
class SplashViewModel extends ChangeNotifier {
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  Future<bool> hasValidToken() async {
    return await AuthStorageService.hasToken();
  }

  Future<bool> checkAuthentication() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Add a small delay to ensure UI renders properly
      await Future.delayed(const Duration(milliseconds: 500));

      // Check authentication status directly using AuthStorageService
      bool isAuthenticated = await hasValidToken();

      _isLoading = false;
      notifyListeners();

      return isAuthenticated;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}