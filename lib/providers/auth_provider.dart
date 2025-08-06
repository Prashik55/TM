import 'package:flutter/material.dart';
import 'package:tmapp/models/user.dart';
import 'package:tmapp/services/api_service.dart';
import 'package:tmapp/services/database_service.dart';
import 'package:tmapp/services/notification_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;
  bool _isInitialized = false; // Track if auth check has been performed

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;
  bool get isInitialized => _isInitialized;

  Future<bool> login(String email, String password) async {
    print('AuthProvider - Login attempt for: $email');
    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService.login(email, password);
      print('AuthProvider - Login response: ${response['success']}');
      
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        final userData = data['user'];
        final token = data['token'];
        
        // Check if userData and token are not null
        if (userData != null && token != null) {
          await ApiService.setToken(token);
          _user = User.fromJson(userData);
          _isAuthenticated = true;
          _isInitialized = true;
          _setLoading(false);
          print('AuthProvider - Login successful for: ${_user?.name}');
          notifyListeners();
          
          // Show success notification
          await NotificationService().showSuccessNotification('Login successful!');
          return true;
        } else {
          _setError('Invalid response format: missing user data or token');
          print('AuthProvider - Login failed: Invalid response format');
          return false;
        }
      } else {
        final message = response['message'] ?? 'Login failed';
        _setError(message);
        print('AuthProvider - Login failed: $message');
        return false;
      }
    } catch (e) {
      _setError('Network error: ${e.toString()}');
      print('AuthProvider - Login error: $e');
      return false;
    }
  }

  Future<bool> register(String name, String email, String password, String type) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService.register(name, email, password, type);
      
      if (response['success'] == true) {
        final userData = response['data']['user'];
        final token = response['data']['token'];
        
        await ApiService.setToken(token);
        _user = User.fromJson(userData);
        _isAuthenticated = true;
        _isInitialized = true;
        _setLoading(false);
        notifyListeners();
        
        // Show success notification
        await NotificationService().showSuccessNotification('Registration successful!');
        return true;
      } else {
        _setError(response['message'] ?? 'Registration failed');
        return false;
      }
    } catch (e) {
      _setError('Network error: ${e.toString()}');
      return false;
    }
  }

  Future<bool> checkAuthStatus() async {
    if (_isInitialized) {
      print('AuthProvider - Already initialized, returning: $_isAuthenticated');
      return _isAuthenticated;
    }

    print('AuthProvider - Checking authentication status...');
    try {
      final token = await ApiService.getToken();
      print('AuthProvider - Token exists: ${token != null}');
      
      if (token == null) {
        _isAuthenticated = false;
        _isInitialized = true;
        print('AuthProvider - No token found, setting not authenticated');
        notifyListeners();
        return false;
      }

      final response = await ApiService.getProfile();
      print('AuthProvider - Profile response: ${response['success']}');
      
      if (response['success'] == true) {
        _user = User.fromJson(response['data']);
        _isAuthenticated = true;
        _isInitialized = true;
        print('AuthProvider - Token valid, user authenticated');
        notifyListeners();
        return true;
      } else {
        // Token is invalid, clear it but don't auto-logout
        await ApiService.removeToken();
        _isAuthenticated = false;
        _isInitialized = true;
        print('AuthProvider - Token invalid, clearing and setting not authenticated');
        notifyListeners();
        return false;
      }
    } catch (e) {
      // Network error or other issue, clear token
      await ApiService.removeToken();
      _isAuthenticated = false;
      _isInitialized = true;
      print('AuthProvider - Error checking auth: $e, setting not authenticated');
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    print('AuthProvider - Logging out...');
    _setLoading(true);
    
    try {
      // Try to logout from server
      await ApiService.logout();
      print('AuthProvider - Server logout successful');
    } catch (e) {
      // Ignore logout errors from server
      print('AuthProvider - Server logout error: $e');
    }
    
    try {
      // Clear all local data
      await ApiService.removeToken();
      await DatabaseService.clearAllData();
      
      // Reset state
      _user = null;
      _isAuthenticated = false;
      _isInitialized = true;
      _clearError();
      
      print('AuthProvider - Logout successful - all data cleared');
      print('AuthProvider - State after logout: isAuthenticated=$_isAuthenticated, isInitialized=$_isInitialized');
    } catch (e) {
      print('AuthProvider - Error clearing local data: $e');
    } finally {
      _setLoading(false);
      print('AuthProvider - Calling notifyListeners() after logout');
      notifyListeners();
    }
  }

  // Force logout (for security purposes)
  Future<void> forceLogout() async {
    await logout();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
} 