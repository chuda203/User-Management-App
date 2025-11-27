import 'package:flutter/material.dart';
import '../../../core/models/user.dart';
import '../services/home_service.dart';

class HomeViewModel extends ChangeNotifier {
  List<User> _users = [];
  List<User> get users => _users;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final HomeService _homeService = HomeService();

  void initializeUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _users = await _homeService.getRecentUsers();
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
}