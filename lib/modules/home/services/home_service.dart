import '../../../core/models/user.dart';
import '../../../core/repository/user_repository.dart';
import '../../../core/services/local_user_service.dart';
import '../../../core/services/remote_user_service.dart';

abstract class HomeService {
  Future<List<User>> getRecentUsers();
}

class HomeServiceImpl implements HomeService {
  final UserRepository _userRepository;

  HomeServiceImpl({
    UserRepository? userRepository,
  }) : _userRepository = userRepository ?? 
        UserRepositoryImpl(
          localDataSource: LocalUserServiceImpl(),
          remoteDataSource: RemoteUserServiceImpl(),
        );

  @override
  Future<List<User>> getRecentUsers() async {
    // Get all users and return just the first 3 for the home screen
    final allUsers = await _userRepository.getAllUsers();
    final recentUsers = allUsers.take(3).toList();

    // Modify the avatars to show numbered placeholders for home screen only
    for (int i = 0; i < recentUsers.length; i++) {
      recentUsers[i] = User(
        id: recentUsers[i].id,
        name: recentUsers[i].name,
        username: recentUsers[i].username,
        email: recentUsers[i].email,
        avatar: 'https://ui-avatars.com/api/?name=${i+1}&background=800080&color=fff&size=128',
      );
    }

    return recentUsers;
  }
}