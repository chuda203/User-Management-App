import 'package:flutter/material.dart';
import '../../../core/services/user_service.dart';
import '../../../core/models/user.dart';

class UserAddViewModel extends ChangeNotifier {
  final UserService _userService = UserService();
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<User> addUser({String? name, String? email}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newUser = await _userService.createUser(
        name: name,
        email: email,
      );
      _error = null;
      return newUser;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}