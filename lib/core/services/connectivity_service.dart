import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import '../services/user_service.dart';
import 'dart:async';

class ConnectivityService {
  static ConnectivityService? _instance;
  UserService? _userService;

  factory ConnectivityService({required UserService userService}) {
    _instance ??= ConnectivityService._internal();
    _instance!._userService = userService;
    return _instance!;
  }

  ConnectivityService._internal();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  // Initialize connectivity monitoring
  void initializeConnectivityMonitoring() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        if (results.isNotEmpty) {
          _handleConnectivityChange(results.first);
        }
      },
    );
  }

  // Handle connectivity changes
  void _handleConnectivityChange(ConnectivityResult result) {
    if (result != ConnectivityResult.none) {
      debugPrint('[INFO] Network connection restored, initiating sync...');
      _syncIfOnline();
    } else {
      debugPrint('[INFO] Network connection lost');
    }
  }

  // Trigger sync if online
  Future<void> _syncIfOnline() async {
    await _userService?.syncService.syncIfOnline();
  }

  // Dispose the subscription when no longer needed
  void dispose() {
    _connectivitySubscription?.cancel();
  }
}