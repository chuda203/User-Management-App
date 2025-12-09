import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import '../repository/user_repository.dart';

class SyncService {
  static SyncService? _instance;
  UserRepository? _userRepository;

  factory SyncService({required UserRepository userRepository}) {
    _instance ??= SyncService._internal();
    _instance!._userRepository = userRepository;
    return _instance!;
  }

  SyncService._internal();

  // Check network connectivity and sync if available
  Future<void> syncIfOnline() async {
    var connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult != ConnectivityResult.none) {
      debugPrint('[INFO] Network is available, starting synchronization...');
      try {
        await _userRepository?.syncPendingOperations();
        debugPrint('[INFO] Synchronization completed successfully');
      } catch (e) {
        debugPrint('[ERROR] Synchronization failed: $e');
      }
    } else {
      debugPrint('[INFO] No network connection, skipping synchronization');
    }
  }

  // Force synchronization regardless of network status
  Future<void> forceSync() async {
    debugPrint('[INFO] Force synchronization initiated...');
    try {
      await _userRepository?.syncPendingOperations();
      debugPrint('[INFO] Force synchronization completed');
    } catch (e) {
      debugPrint('[ERROR] Force synchronization failed: $e');
    }
  }
}