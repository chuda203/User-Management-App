import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../core/models/user.dart';
import '../../../core/repository/user_repository.dart';
import '../../../core/services/local_user_service.dart';
import '../../../core/services/remote_user_service.dart';
import '../../../core/services/user_service.dart';

class UserListViewModel extends ChangeNotifier {
  List<User> _allUsers = [];
  List<User> get allUsers => _allUsers;

  final UserRepository _userRepository;
  final UserService _userService;

  UserListViewModel()
      : _userRepository = UserRepositoryImpl(
          localDataSource: LocalUserServiceImpl(),
          remoteDataSource: RemoteUserServiceImpl(),
        ),
        _userService = UserService.instance {
    // Set up connectivity change callback for sync
    _userService.connectivityService.setOnConnectivityChangedCallback(_handleConnectivityChange);
  }

  void _handleConnectivityChange() {
    // When connectivity changes, try to sync data
    // Only sync if we're now online
    _attemptSyncWhenOnline();
  }

  Future<void> _attemptSyncWhenOnline() async {
    final connectivityResult = await _userService.connectivityService.getCurrentConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      // We're online, attempt sync
      await syncIfOnline();
    }
  }

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
    // Use the sync service with the sync operation as callback
    // Create a separate repository instance for sync operations to avoid conflict
    final syncRepository = UserRepositoryImpl(
      localDataSource: LocalUserServiceImpl(),
      remoteDataSource: RemoteUserServiceImpl(),
    );

    await _userService.syncService.syncIfOnline(
      syncOperation: () async {
        await syncRepository.syncPendingOperations();
      }
    );
  }
}