import 'package:first_task/core/database/database_helper.dart';
import 'package:first_task/core/models/user.dart';

abstract class LocalUserService {
  Future<List<User>> getAllUsers();
  Future<User?> getUserById(int id);
  Future<void> insertUser(User user);
  Future<void> insertAllUsers(List<User> users);
  Future<void> updateUser(User user);
  Future<void> deleteUser(int id);
  Future<void> clearUsers();
}

class LocalUserServiceImpl implements LocalUserService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  Future<List<User>> getAllUsers() async {
    return await _databaseHelper.getAllUsers();
  }

  @override
  Future<User?> getUserById(int id) async {
    return await _databaseHelper.getUserById(id);
  }

  @override
  Future<void> insertUser(User user) async {
    await _databaseHelper.insertUser(user);
  }

  @override
  Future<void> insertAllUsers(List<User> users) async {
    await _databaseHelper.insertAllUsers(users);
  }

  @override
  Future<void> updateUser(User user) async {
    await _databaseHelper.updateUser(user);
  }

  @override
  Future<void> deleteUser(int id) async {
    await _databaseHelper.deleteUser(id);
  }

  @override
  Future<void> clearUsers() async {
    await _databaseHelper.clearUsers();
  }
}