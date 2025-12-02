import '../../../core/services/user_service.dart';
import '../../../core/models/user.dart';

class UserEditService {
  // Singleton instance
  static UserEditService? _instance;
  static UserEditService get instance => _instance ??= UserEditService._internal();
  UserEditService._internal();

  final UserService _userService = UserService.instance;

  Future<User> updateUser(int id, {String? name, String? email}) async {
    return await _userService.updateUser(id, name: name, email: email);
  }
}