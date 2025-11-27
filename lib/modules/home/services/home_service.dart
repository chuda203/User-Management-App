import '../../../core/services/user_service.dart';
import '../../../core/models/user.dart';

class HomeService {
  final UserService _userService = UserService();

  Future<List<User>> getRecentUsers() async {
    // Get all users and return just the first 3 for the home screen
    final allUsers = await _userService.getUsers();
    final recentUsers = allUsers.take(3).toList();

    // Modify the avatars to show numbered placeholders for home screen only
    for (int i = 0; i < recentUsers.length; i++) {
      recentUsers[i] = User(
        id: recentUsers[i].id,
        name: recentUsers[i].name,
        username: recentUsers[i].username,
        email: recentUsers[i].email,
        // Use numbered avatars for home screen (like 1, 2, 3) with purple background
        avatar: 'https://ui-avatars.com/api/?name=${i+1}&background=800080&color=fff&size=128',
      );
    }

    return recentUsers;
  }
}