import 'package:flutter/material.dart';
import '../../../core/models/user.dart';
import '../../../core/repository/user_repository.dart';
import '../../../core/services/local_user_service.dart';
import '../../../core/services/remote_user_service.dart';
import '../../../core/services/sync_service.dart';

class UserListViewModel extends ChangeNotifier {
  List<User> _allUsers = [];
  List<User> get allUsers => _allUsers;

  final UserRepository _userRepository;

  UserListViewModel()
      : _userRepository = UserRepositoryImpl(
          localDataSource: LocalUserServiceImpl(),
          remoteDataSource: RemoteUserServiceImpl(),
        );

  void setUsers(List<User> users) {
    _allUsers = users;
    notifyListeners();
  }

  // Method to fetch all users directly from the repository
  void initializeUsers() async {
    try {
      _allUsers = await _userRepository.getAllUsers();
    } catch (e) {
      // Set default users in case of error
      _allUsers = [
        User(
          id: 1,
          name: 'Default User',
          username: 'default',
          email: 'default@example.com',
          avatar: 'https://randomuser.me/api/portraits/lego/1.jpg',
        ),
      ];
    }
    notifyListeners();
  }

  // Method to add a user directly through the repository
  Future<User> addUser({String? name, String? email}) async {
    try {
      final newUser = await _userRepository.createUser(name: name, email: email);
      // Add the new user to the local list
      _allUsers.add(newUser);
      notifyListeners();
      return newUser;
    } catch (e) {
      throw Exception('Failed to add user: $e');
    }
  }

  // Method to sync data if online
  Future<void> syncIfOnline() async {
    // Create a sync service with the same repository instance
    final syncService = SyncService(userRepository: _userRepository);
    await syncService.syncIfOnline();
  }
}