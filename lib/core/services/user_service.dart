import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'api_service.dart';

class UserService {
  // Cache to avoid repeated loading
  List<User>? _cachedUsers;
  final ApiService _apiService = ApiService();

  Future<List<User>> getUsers() async {
    if (_cachedUsers != null) {
      // Return cached users if available
      return _cachedUsers!;
    }

    try {
      // Try to fetch from API first
      print('Attempting to fetch users from API...');
      final users = await _apiService.getAllUsers();
      print('Successfully fetched ${users.length} users from API');
      _cachedUsers = users;
      return users;
    } catch (e) {
      print('API call failed: $e. Falling back to local JSON.');
      // Fallback to local JSON file if API fails
      try {
        final String response = await rootBundle.loadString('lib/core/data/users.json');
        final List<dynamic> userList = json.decode(response);

        final users = userList.map((json) => User.fromJson(json)).toList();

        print('Successfully loaded ${users.length} users from local JSON');
        // Cache the users for future use
        _cachedUsers = users;
        return users;
      } catch (jsonError) {
        print('Local JSON loading failed: $jsonError');
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
  }

  Future<User?> getUserById(int id) async {
    try {
      // Try to fetch from API first
      print('Attempting to fetch user $id from API...');
      final user = await _apiService.getUserById(id);
      if (user != null) {
        print('Successfully fetched user $id from API');
        return user;
      }
    } catch (e) {
      print('API call for user $id failed: $e');
      // If API fails, look in cached users
    }

    if (_cachedUsers != null) {
      for (final user in _cachedUsers!) {
        if (user.id == id) {
          return user;
        }
      }
    }

    // If not found in cache, try local JSON as fallback
    try {
      final users = await getUsers();
      for (final user in users) {
        if (user.id == id) {
          return user;
        }
      }
    } catch (e) {
    }

    return null;
  }

  // Clear cache if needed
  void clearCache() {
    _cachedUsers = null;
  }
}