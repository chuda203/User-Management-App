import '../../../core/services/user_service.dart';
import '../../../core/models/user.dart';

class UserEditService {
  final UserService _userService = UserService();

  Future<User> updateUser(int id, {String? name, String? email}) async {
    return await _userService.updateUser(id, name: name, email: email);
  }
}