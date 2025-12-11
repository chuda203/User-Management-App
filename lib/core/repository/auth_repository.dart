import '../services/auth_storage_service.dart';
import '../services/authentication_service.dart';

abstract class AuthRepository {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<void> logout();
  Future<String?> getSavedToken();
  Future<bool> hasValidToken();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthenticationService _authService = AuthenticationService.instance;

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    final result = await _authService.login(email, password);

    if (result['success']) {
      await AuthStorageService.saveToken(result['token']);
      return result;
    } else {
      return result;
    }
  }

  @override
  Future<void> logout() async {
    await _authService.logout(); // Call service for any server-side operations
    await AuthStorageService.removeToken(); // Remove local token
  }

  @override
  Future<String?> getSavedToken() async {
    return await AuthStorageService.getToken();
  }

  @override
  Future<bool> hasValidToken() async {
    return await AuthStorageService.hasToken();
  }
}