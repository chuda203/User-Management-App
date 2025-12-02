import '../../../core/services/user_service.dart';
import '../../../core/models/user.dart';

class UserAddService {
  // Singleton instance
  static UserAddService? _instance;
  static UserAddService get instance => _instance ??= UserAddService._internal();
  UserAddService._internal();

  final UserService _userService = UserService.instance;

  Future<User> createUser({String? name, String? email}) async {
    return await _userService.createUser(name: name, email: email);
  }
}