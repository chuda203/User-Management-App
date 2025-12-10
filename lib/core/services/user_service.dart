import 'package:first_task/core/services/local_user_service.dart';
import 'package:first_task/core/services/remote_user_service.dart';
import 'package:first_task/core/repository/user_repository.dart';
import 'package:first_task/core/repository/auth_repository.dart';
import 'package:first_task/core/services/sync_service.dart';
import 'package:first_task/core/services/connectivity_service.dart';

class UserService {
  static UserService? _instance;
  static UserService get instance => _instance ??= UserService._internal();

  final UserRepository _userRepository;
  final AuthRepository _authRepository;
  late final SyncService _syncService;
  late final ConnectivityService _connectivityService;

  factory UserService() {
    return instance;
  }

  UserService._internal()
      : _userRepository = UserRepositoryImpl(
          localDataSource: LocalUserServiceImpl(),
          remoteDataSource: RemoteUserServiceImpl(),
        ),
        _authRepository = AuthRepositoryImpl() {
    _syncService = SyncService(userRepository: _userRepository);
    _connectivityService = ConnectivityService(userService: this);
    // Initialize connectivity monitoring
    _connectivityService.initializeConnectivityMonitoring();
  }

  UserRepository get userRepository => _userRepository;
  AuthRepository get authRepository => _authRepository;
  SyncService get syncService => _syncService;
  ConnectivityService get connectivityService => _connectivityService;
}