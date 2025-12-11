import 'package:flutter/material.dart';
import '../../../core/models/user.dart';
import '../../../core/repository/user_repository.dart';
import '../../../core/services/local_user_service.dart';
import '../../../core/services/remote_user_service.dart';

class UserDetailViewModel extends ChangeNotifier {
  User? _user;
  User? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  final UserRepository _userRepository;

  UserDetailViewModel()
      : _userRepository = UserRepositoryImpl(
          localDataSource: LocalUserServiceImpl(),
          remoteDataSource: RemoteUserServiceImpl(),
        );

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
      final user = await _userRepository.getUserById(userId);
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

  Future<bool> deleteUser(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _userRepository.deleteUser(userId);
      if (result) {
        _user = null;
        _error = null;
      }
      return result;
    } catch (e) {
      _error = 'Failed to delete user: ${e.toString()}';
      return false;
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