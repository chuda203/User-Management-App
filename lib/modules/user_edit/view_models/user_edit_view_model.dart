import 'package:flutter/material.dart';
import '../services/user_edit_service.dart';
import '../../../core/models/user.dart';

class UserEditViewModel extends ChangeNotifier {
  final UserEditService _userEditService = UserEditService.instance;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<User> updateUser(int id, {String? name, String? email}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedUser = await _userEditService.updateUser(
        id,
        name: name,
        email: email,
      );
      _error = null;
      return updatedUser;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}