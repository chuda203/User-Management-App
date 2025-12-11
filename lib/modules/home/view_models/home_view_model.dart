import 'package:flutter/material.dart';
import '../../../core/models/user.dart';
import '../../../core/repository/user_repository.dart';
import '../../../core/services/local_user_service.dart';
import '../../../core/services/remote_user_service.dart';
import '../../../core/services/auth_storage_service.dart';

class HomeViewModel extends ChangeNotifier {
  List<User> _users = [];
  List<User> get users => _users;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final UserRepository _userRepository;

  HomeViewModel({UserRepository? userRepository})
      : _userRepository = userRepository ??
          UserRepositoryImpl(
            localDataSource: LocalUserServiceImpl(),
            remoteDataSource: RemoteUserServiceImpl(),
          );

  Future<void> initializeUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Get all users and return just the first 3 for the home screen
      final allUsers = await _userRepository.getAllUsers();
      final recentUsers = allUsers.take(3).toList();

      // Modify the avatars to show numbered placeholders for home screen only
      for (int i = 0; i < recentUsers.length; i++) {
        recentUsers[i] = User(
          id: recentUsers[i].id,
          name: recentUsers[i].name,
          username: recentUsers[i].username,
          email: recentUsers[i].email,
          avatar: 'https://ui-avatars.com/api/?name=${i+1}&background=800080&color=fff&size=128',
        );
      }

      _users = recentUsers;
    } catch (e) {
      // Set default users in case of error
      _users = [
        User(
          id: 1,
          name: 'Default User',
          username: 'default',
          email: 'default@example.com',
          avatar: 'https://randomuser.me/api/portraits/lego/1.jpg',
        ),
      ];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await AuthStorageService.removeToken();
  }
}