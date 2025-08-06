import 'dart:async';
import 'dart:convert';
import 'package:tmapp/config/app_config.dart';
import 'package:tmapp/services/api_service.dart';

class RealtimeService {
  static Timer? _pollingTimer;
  static bool _isPolling = false;
  static const Duration _pollingInterval = Duration(seconds: 10);
  
  // Callbacks for real-time updates
  static Function(Map<String, dynamic>)? onDashboardUpdate;
  static Function(List<dynamic>)? onProjectsUpdate;
  static Function(List<dynamic>)? onTicketsUpdate;
  static Function(List<dynamic>)? onUsersUpdate;
  
  // Last update timestamps
  static DateTime? _lastDashboardUpdate;
  static DateTime? _lastProjectsUpdate;
  static DateTime? _lastTicketsUpdate;
  static DateTime? _lastUsersUpdate;
  
  // Start real-time polling
  static void startPolling() {
    if (_isPolling) return;
    
    _isPolling = true;
    _pollingTimer = Timer.periodic(_pollingInterval, (timer) {
      _pollForUpdates();
    });
  }
  
  // Stop real-time polling
  static void stopPolling() {
    _isPolling = false;
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }
  
  // Poll for updates
  static Future<void> _pollForUpdates() async {
    try {
      // Poll dashboard data
      await _pollDashboard();
      
      // Poll projects data
      await _pollProjects();
      
      // Poll tickets data
      await _pollTickets();
      
      // Poll users data (admin only)
      await _pollUsers();
    } catch (e) {
      print('Realtime polling error: $e');
    }
  }
  
  // Poll dashboard updates
  static Future<void> _pollDashboard() async {
    try {
      final response = await ApiService.get('/dashboard');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          _lastDashboardUpdate = DateTime.now();
          onDashboardUpdate?.call(data['data']);
        }
      }
    } catch (e) {
      print('Dashboard polling error: $e');
    }
  }
  
  // Poll projects updates
  static Future<void> _pollProjects() async {
    try {
      final response = await ApiService.get('/projects');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          _lastProjectsUpdate = DateTime.now();
          onProjectsUpdate?.call(data['data']);
        }
      }
    } catch (e) {
      print('Projects polling error: $e');
    }
  }
  
  // Poll tickets updates
  static Future<void> _pollTickets() async {
    try {
      final response = await ApiService.get('/tickets');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          _lastTicketsUpdate = DateTime.now();
          onTicketsUpdate?.call(data['data']);
        }
      }
    } catch (e) {
      print('Tickets polling error: $e');
    }
  }
  
  // Poll users updates (admin only)
  static Future<void> _pollUsers() async {
    try {
      final response = await ApiService.get('/users');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          _lastUsersUpdate = DateTime.now();
          onUsersUpdate?.call(data['data']);
        }
      }
    } catch (e) {
      print('Users polling error: $e');
    }
  }
  
  // Get last update timestamps
  static DateTime? get lastDashboardUpdate => _lastDashboardUpdate;
  static DateTime? get lastProjectsUpdate => _lastProjectsUpdate;
  static DateTime? get lastTicketsUpdate => _lastTicketsUpdate;
  static DateTime? get lastUsersUpdate => _lastUsersUpdate;
  
  // Check if data is stale (older than cache timeout)
  static bool isDataStale(DateTime? lastUpdate) {
    if (lastUpdate == null) return true;
    return DateTime.now().difference(lastUpdate) > AppConfig.cacheTimeout;
  }
  
  // Force refresh all data
  static Future<void> forceRefresh() async {
    await _pollForUpdates();
  }
} 