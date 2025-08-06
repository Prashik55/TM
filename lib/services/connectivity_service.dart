import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:tmapp/services/database_service.dart';
import 'package:tmapp/services/api_service.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isConnected = true;

  bool get isConnected => _isConnected;

  void initialize() {
    _checkInitialConnection();
    _subscription = _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
  }

  Future<void> _checkInitialConnection() async {
    final result = await _connectivity.checkConnectivity();
    _isConnected = result.isNotEmpty && !result.contains(ConnectivityResult.none);
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final wasConnected = _isConnected;
    _isConnected = results.isNotEmpty && !results.contains(ConnectivityResult.none);
    
    // If connection was restored, sync offline data
    if (!wasConnected && _isConnected) {
      _syncOfflineData();
    }
  }

  Future<void> _syncOfflineData() async {
    try {
      await DatabaseService.syncData();
    } catch (e) {
      print('Error syncing offline data: $e');
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
} 