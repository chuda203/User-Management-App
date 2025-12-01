import '../../../core/services/user_service.dart';
import '../../../core/models/user.dart';

class UserListService {
  final UserService _userService = UserService();

  Future<List<User>> getAllUsers() async {
    return await _userService.getUsers();
  }

  Future<User> createUser({String? name, String? email}) async {
    return await _userService.createUser(name: name, email: email);
  }
}