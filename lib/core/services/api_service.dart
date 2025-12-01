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
}