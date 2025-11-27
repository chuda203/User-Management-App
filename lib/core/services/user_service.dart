import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/user.dart';

class UserService {
  // Cache to avoid repeated loading
  List<User>? _cachedUsers;

  Future<List<User>> getUsers() async {
    if (_cachedUsers != null) {
      return _cachedUsers!;
    }

    try {
      // Load from JSON file
      final String response = await rootBundle.loadString('lib/core/data/users.json');
      final List<dynamic> userList = json.decode(response);

      // Convert to User objects
      final users = userList.map((json) => User.fromJson(json)).toList();

      // Cache the users for future use
      _cachedUsers = users;
      return users;
    } catch (e) {
      // Return sample data in case of error
      final fallbackUsers = [
        User(
          id: 1,
          name: 'John Doe',
          username: 'johndoe',
          email: 'john.doe@example.com',
          avatar: 'https://randomuser.me/api/portraits/men/1.jpg',
        ),
        User(
          id: 2,
          name: 'Jane Smith',
          username: 'janesmith',
          email: 'jane.smith@example.com',
          avatar: 'https://randomuser.me/api/portraits/women/2.jpg',
        ),
      ];
      _cachedUsers = fallbackUsers;
      return fallbackUsers;
    }
  }

  Future<User?> getUserById(int id) async {
    final users = await getUsers();
    for (final user in users) {
      if (user.id == id) {
        return user;
      }
    }
    return null;
  }

  // Clear cache if needed
  void clearCache() {
    _cachedUsers = null;
  }
}