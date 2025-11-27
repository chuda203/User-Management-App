import 'package:flutter/material.dart';
import '../../../core/models/user.dart';
import '../services/user_list_service.dart';

class UserListViewModel extends ChangeNotifier {
  List<User> _allUsers = [];
  List<User> get allUsers => _allUsers;

  final UserListService _userListService = UserListService();

  void setUsers(List<User> users) {
    _allUsers = users;
    notifyListeners();
  }

  // Method to fetch all users from the service
  void initializeUsers() async {
    try {
      _allUsers = await _userListService.getAllUsers();
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
}