import 'package:first_task/core/services/sync_service.dart';
import 'package:first_task/core/services/connectivity_service.dart';

class UserService {
  static UserService? _instance;
  static UserService get instance => _instance ??= UserService._internal();

  // UserService now acts as a pure service coordinator
  late final SyncService _syncService;
  late final ConnectivityService _connectivityService;

  factory UserService() {
    _instance ??= UserService._internal();
    return _instance!;
  }

  UserService._internal() {
    _syncService = SyncService();
    _connectivityService = ConnectivityService();
    _connectivityService.initializeConnectivityMonitoring();
  }

  // Provide access to services for coordination
  SyncService get syncService => _syncService;
  ConnectivityService get connectivityService => _connectivityService;
}