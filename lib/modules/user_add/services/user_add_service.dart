import '../../../core/services/user_service.dart';
import '../../../core/models/user.dart';

class UserAddService {
  final UserService _userService = UserService();

  Future<User> createUser({String? name, String? email}) async {
    return await _userService.createUser(name: name, email: email);
  }
}