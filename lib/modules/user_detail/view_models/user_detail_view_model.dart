import 'package:flutter/material.dart';
import '../../../core/models/user.dart';
import '../services/user_detail_service.dart';

class UserDetailViewModel extends ChangeNotifier {
  User? _user;
  User? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  final UserDetailService _service = UserDetailService();

  void setUser(User user) {
    _user = user;
    _error = null;
    notifyListeners();
  }

  Future<void> loadUserDetail(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _service.getUserById(userId);
      if (user != null) {
        _user = user;
      } else {
        _error = 'User not found';
      }
    } catch (e) {
      _error = 'Failed to load user: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearState() {
    _user = null;
    _error = null;
    _isLoading = false;
  }
}