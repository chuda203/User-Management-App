import 'package:first_task/core/data/local/local_user_data_source.dart';
import 'package:first_task/core/data/remote/remote_user_data_source.dart';
import 'package:first_task/core/repository/user_repository.dart';
import 'package:first_task/core/services/sync_service.dart';
import 'package:first_task/core/services/connectivity_service.dart';

class UserService {
  static UserService? _instance;
  static UserService get instance => _instance ??= UserService._internal();

  final UserRepository _userRepository;
  late final SyncService _syncService;
  late final ConnectivityService _connectivityService;

  factory UserService() {
    return instance;
  }

  UserService._internal()
      : _userRepository = UserRepositoryImpl(
          localDataSource: LocalUserDataSourceImpl(),
          remoteDataSource: RemoteUserDataSourceImpl(),
        ) {
    _syncService = SyncService(userRepository: _userRepository);
    _connectivityService = ConnectivityService(userService: this);
    // Initialize connectivity monitoring
    _connectivityService.initializeConnectivityMonitoring();
  }

  UserRepository get userRepository => _userRepository;
  SyncService get syncService => _syncService;
  ConnectivityService get connectivityService => _connectivityService;
}