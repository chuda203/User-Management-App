import '../../../core/services/user_service.dart';
import '../../../core/models/user.dart';

class UserDetailService {
  final UserService _userService = UserService();

  Future<User?> getUserById(int id) async {
    return await _userService.getUserById(id);
  }

  Future<bool> deleteUser(int id) async {
    return await _userService.deleteUser(id);
  }
}