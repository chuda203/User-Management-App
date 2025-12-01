import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class ApiService {
  static const String _baseUrl = 'https://reqres.in/api';

  // Get all users from the external API
  Future<List<User>> getAllUsers({int page = 1}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users?page=$page'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': 'reqres-free-v1',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final usersData = data['data'] as List;

        return usersData.map((userData) => User(
          id: userData['id'] as int,
          name: '${userData['first_name'] as String} ${userData['last_name'] as String}',
          username: (userData['first_name'] as String).toLowerCase(),
          email: userData['email'] as String,
          avatar: userData['avatar'] as String,
        )).toList();
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load users from API: $e');
    }
  }

  // Get a single user by ID from the external API
  Future<User?> getUserById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users/$id'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': 'reqres-free-v1',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final userData = data['data'];

        return User(
          id: userData['id'] as int,
          name: '${userData['first_name'] as String} ${userData['last_name'] as String}',
          username: (userData['first_name'] as String).toLowerCase(),
          email: userData['email'] as String,
          avatar: userData['avatar'] as String,
        );
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load user from API: $e');
    }
  }

  // Update a user by ID
  Future<User> updateUser(int id, {String? name, String? job, String? email}) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/users/$id'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': 'reqres-free-v1',
        },
        body: json.encode({
          if (name != null) 'name': name,
          if (job != null) 'job': job,
          if (email != null) 'email': email,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Note: ReqRes API returns different format for update response
        // For demo purposes, construct a user from the response
        return User(
          id: id,
          name: data['name'] ?? name ?? '',
          username: data['updatedAt'] != null ? name?.toLowerCase() ?? 'updated' : 'updated',
          email: data['email'] ?? email ?? '',
          avatar: 'https://randomuser.me/api/portraits/lego/1.jpg', // Use default avatar
        );
      } else {
        throw Exception('Failed to update user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update user in API: $e');
    }
  }

  // Create a new user
  Future<User> createUser({String? name, String? job, String? email}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/users'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': 'reqres-free-v1',
        },
        body: json.encode({
          if (name != null) 'name': name,
          if (job != null) 'job': job,
          if (email != null) 'email': email,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        // Note: ReqRes API returns different format for create response
        // id is returned in response for new user, but might be String
        int userId = 0;
        if (data['id'] != null) {
          if (data['id'] is int) {
            userId = data['id'];
          } else if (data['id'] is String) {
            userId = int.tryParse(data['id']) ?? 0;
          }
        }

        return User(
          id: userId,
          name: data['name'] ?? name ?? '',
          username: data['name']?.toLowerCase() ?? 'newuser',
          email: data['email'] ?? email ?? '',
          avatar: 'https://randomuser.me/api/portraits/lego/1.jpg', // Use default avatar
        );
      } else {
        throw Exception('Failed to create user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create user in API: $e');
    }
  }

  // Delete a user by ID
  Future<bool> deleteUser(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/users/$id'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': 'reqres-free-v1',
        },
      );

      // ReqRes API returns 204 for successful deletion
      if (response.statusCode == 204 || response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to delete user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete user in API: $e');
    }
  }
}