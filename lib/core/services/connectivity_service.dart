import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

class ConnectivityService {
  static ConnectivityService? _instance;

  factory ConnectivityService() {
    _instance ??= ConnectivityService._internal();
    return _instance!;
  }

  ConnectivityService._internal();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Function()? _onConnectivityChanged;

  // Initialize connectivity monitoring
  void initializeConnectivityMonitoring() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        if (results.isNotEmpty) {
          ConnectivityResult result = results.first;
          _handleConnectivityChange(result);

          // Notify listeners about connectivity change
          _onConnectivityChanged?.call();
        }
      },
    );
  }

  // Handle connectivity changes
  void _handleConnectivityChange(ConnectivityResult result) {
    if (result != ConnectivityResult.none) {
      debugPrint('[INFO] Network connection restored');
    } else {
      debugPrint('[INFO] Network connection lost');
    }
  }

  // Set callback to be notified when connectivity changes
  void setOnConnectivityChangedCallback(Function() callback) {
    _onConnectivityChanged = callback;
  }

  // Check current connectivity
  Future<ConnectivityResult> getCurrentConnectivity() async {
    List<ConnectivityResult> results = await Connectivity().checkConnectivity();
    if (results.isNotEmpty) {
      return results.first;
    } else {
      // Default to none if no results
      return ConnectivityResult.none;
    }
  }

  // Dispose the subscription when no longer needed
  void dispose() {
    _connectivitySubscription?.cancel();
  }
}