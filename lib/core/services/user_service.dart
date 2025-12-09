import 'package:first_task/core/data/local/local_user_data_source.dart';
import 'package:first_task/core/data/remote/remote_user_data_source.dart';
import 'package:first_task/core/repository/user_repository.dart';

class UserService {
  static UserService? _instance;
  static UserService get instance => _instance ??= UserService._internal();

  final UserRepository _userRepository;

  factory UserService() {
    return instance;
  }

  UserService._internal()
      : _userRepository = UserRepositoryImpl(
          localDataSource: LocalUserDataSourceImpl(),
          remoteDataSource: RemoteUserDataSourceImpl(),
        );

  UserRepository get userRepository => _userRepository;
}