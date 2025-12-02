import '../../../core/services/user_service.dart';
import '../../../core/models/user.dart';

class UserDetailService {
  // Singleton instance
  static UserDetailService? _instance;
  static UserDetailService get instance => _instance ??= UserDetailService._internal();
  UserDetailService._internal();

  final UserService _userService = UserService.instance;

  Future<User?> getUserById(int id) async {
    return await _userService.getUserById(id);
  }

  Future<bool> deleteUser(int id) async {
    return await _userService.deleteUser(id);
  }
}