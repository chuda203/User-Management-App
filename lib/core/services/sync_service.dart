import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class SyncService {
  static SyncService? _instance;

  factory SyncService() {
    _instance ??= SyncService._internal();
    return _instance!;
  }

  SyncService._internal();

  // Check network connectivity and sync if available
  // Repository is passed as parameter to avoid direct dependency
  Future<void> syncIfOnline({required Future<void> Function() syncOperation}) async {
    List<ConnectivityResult> results = await (Connectivity().checkConnectivity());

    ConnectivityResult connectivityResult = ConnectivityResult.none;
    if (results.isNotEmpty) {
      connectivityResult = results.first;
    }

    if (connectivityResult != ConnectivityResult.none) {
      debugPrint('[INFO] Network is available, starting synchronization...');
      try {
        await syncOperation();
        debugPrint('[INFO] Synchronization completed successfully');
      } catch (e) {
        debugPrint('[ERROR] Synchronization failed: $e');
      }
    } else {
      debugPrint('[INFO] No network connection, skipping synchronization');
    }
  }

  // Force synchronization regardless of network status
  Future<void> forceSync({required Future<void> Function() syncOperation}) async {
    debugPrint('[INFO] Force synchronization initiated...');
    try {
      await syncOperation();
      debugPrint('[INFO] Force synchronization completed');
    } catch (e) {
      debugPrint('[ERROR] Force synchronization failed: $e');
    }
  }
}