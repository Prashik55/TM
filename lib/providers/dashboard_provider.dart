import 'package:flutter/material.dart';
import 'package:tmapp/services/api_service.dart';
import 'package:tmapp/services/database_service.dart';
import 'package:tmapp/services/connectivity_service.dart';
import 'package:tmapp/services/realtime_service.dart';
import 'package:tmapp/config/app_config.dart';

class Dashboard {
  final int totalProjects;
  final int activeTickets;
  final int completedTasks;
  final int teamMembers;
  final List<DashboardActivity> recentActivity;

  Dashboard({
    required this.totalProjects,
    required this.activeTickets,
    required this.completedTasks,
    required this.teamMembers,
    required this.recentActivity,
  });

  factory Dashboard.fromJson(Map<String, dynamic> json) {
    return Dashboard(
      totalProjects: json['total_projects'] ?? 0,
      activeTickets: json['active_tickets'] ?? 0,
      completedTasks: json['completed_tasks'] ?? 0,
      teamMembers: json['team_members'] ?? 0,
      recentActivity: json['recent_activity'] != null
          ? List<DashboardActivity>.from(
              json['recent_activity'].map((x) => DashboardActivity.fromJson(x)))
          : [],
    );
  }

  factory Dashboard.fromLocalData(Map<String, dynamic> data) {
    return Dashboard(
      totalProjects: data['total_projects'] ?? 0,
      activeTickets: data['active_tickets'] ?? 0,
      completedTasks: data['completed_tasks'] ?? 0,
      teamMembers: data['team_members'] ?? 0,
      recentActivity: [],
    );
  }

  // Create a dummy dashboard for testing
  factory Dashboard.dummy() {
    return Dashboard(
      totalProjects: 5,
      activeTickets: 12,
      completedTasks: 8,
      teamMembers: 4,
      recentActivity: [
        DashboardActivity(
          title: 'Project "Website Redesign" created',
          description: 'Created by John Doe',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        DashboardActivity(
          title: 'Ticket "Fix login bug" completed',
          description: 'Completed by Jane Smith',
          timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        ),
        DashboardActivity(
          title: 'New team member added',
          description: 'Mike Johnson joined the team',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ],
    );
  }
}

class DashboardActivity {
  final String title;
  final String description;
  final DateTime timestamp;

  DashboardActivity({
    required this.title,
    required this.description,
    required this.timestamp,
  });

  factory DashboardActivity.fromJson(Map<String, dynamic> json) {
    return DashboardActivity(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class DashboardProvider extends ChangeNotifier {
  Dashboard? _dashboard;
  bool _isLoading = false;
  String? _error;
  DateTime? _lastUpdate;
  bool _isOffline = false;

  Dashboard? get dashboard => _dashboard;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdate => _lastUpdate;
  bool get isOffline => _isOffline;

  DashboardProvider() {
    // Set up real-time updates
    RealtimeService.onDashboardUpdate = _onDashboardUpdate;
  }

  void _onDashboardUpdate(Map<String, dynamic> data) {
    _dashboard = Dashboard.fromJson(data);
    _lastUpdate = DateTime.now();
    _error = null;
    _isOffline = false;
    notifyListeners();
  }

  Future<void> loadDashboard() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('Loading dashboard...');
      
      // Check if we're online
      if (ConnectivityService().isConnected) {
        // Try to load from API
        try {
          print('=== DEBUGGING API CALL ===');
          print('Base URL: ${AppConfig.apiBaseUrl}');
          print('Environment: ${AppConfig.environment}');
          
          final response = await ApiService.getDashboard();
          print('Dashboard response: $response');
          
          if (response['success'] == true) {
            // Handle different response structures
            Map<String, dynamic> dashboardData;
            
            if (response['data']['stats'] != null) {
              // New structure with stats object
              dashboardData = {
                'total_projects': response['data']['stats']['total_projects'] ?? 0,
                'active_tickets': response['data']['stats']['total_tickets'] ?? 0,
                'completed_tasks': 0, // Not provided in new structure
                'team_members': response['data']['stats']['total_users'] ?? 0,
                'recent_activity': [],
              };
            } else {
              // Original structure
              dashboardData = response['data'];
            }
            
            _dashboard = Dashboard.fromJson(dashboardData);
            _lastUpdate = DateTime.now();
            _error = null;
            _isOffline = false;
            
            // Save to local database
            await DatabaseService.saveDashboardData(dashboardData);
            
            print('Dashboard loaded successfully: ${_dashboard?.totalProjects} projects');
          } else {
            _error = response['message'] ?? 'Failed to load dashboard';
            print('Dashboard error: $_error');
            await _loadFromLocal();
          }
        } catch (e) {
          print('API error: $e');
          await _loadFromLocal();
        }
      } else {
        // Offline mode
        print('Loading dashboard from local database (offline mode)');
        await _loadFromLocal();
      }
    } catch (e) {
      _error = 'Error loading dashboard: $e';
      print('Dashboard exception: $_error');
      // Show dummy data as fallback
      _dashboard = Dashboard.dummy();
      _error = null;
      _isOffline = true;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadFromLocal() async {
    try {
      final localData = await DatabaseService.getDashboardData();
      if (localData != null) {
        _dashboard = Dashboard.fromLocalData(localData);
        _lastUpdate = DateTime.parse(localData['last_updated']);
        _error = null;
        _isOffline = true;
        print('Dashboard loaded from local database');
      } else {
        // No local data, show dummy
        _dashboard = Dashboard.dummy();
        _error = null;
        _isOffline = true;
        print('No local dashboard data, showing dummy data');
      }
    } catch (e) {
      print('Error loading from local: $e');
      _dashboard = Dashboard.dummy();
      _error = null;
      _isOffline = true;
    }
  }

  Future<void> refresh() async {
    await loadDashboard();
  }

  // Test API connection
  Future<void> testApiConnection() async {
    try {
      print('=== TESTING API CONNECTION ===');
      
      // Test basic API
      final testResponse = await ApiService.get('/test');
      print('Test response: $testResponse');
      
      // Test dashboard without auth
      final testDashboardResponse = await ApiService.get('/test-dashboard');
      print('Test dashboard response: $testDashboardResponse');
      
      // Test actual dashboard with auth
      try {
        final dashboardResponse = await ApiService.get('/dashboard');
        print('Dashboard response: $dashboardResponse');
      } catch (e) {
        print('Dashboard auth error: $e');
      }
    } catch (e) {
      print('API test failed: $e');
    }
  }

  void setState(VoidCallback fn) {
    fn();
    notifyListeners();
  }

  @override
  void dispose() {
    RealtimeService.onDashboardUpdate = null;
    super.dispose();
  }
} 