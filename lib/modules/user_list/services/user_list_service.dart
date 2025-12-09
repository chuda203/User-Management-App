import '../../../core/services/user_service.dart';
import '../../../core/models/user.dart';

class UserListService {
  // Singleton instance
  static UserListService? _instance;
  static UserListService get instance => _instance ??= UserListService._internal();
  UserListService._internal();

  final UserService _userService = UserService.instance;

  Future<List<User>> getAllUsers() async {
    return await _userService.userRepository.getAllUsers();
  }

  Future<User> createUser({String? name, String? email}) async {
    return await _userService.userRepository.createUser(name: name, email: email);
  }

  Future<void> syncIfOnline() async {
    await _userService.syncService.syncIfOnline();
  }
}