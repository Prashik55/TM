import 'package:flutter/material.dart';
import 'package:tmapp/models/user.dart';
import 'package:tmapp/services/api_service.dart';
import 'package:tmapp/services/notification_service.dart';

class UserProvider extends ChangeNotifier {
  List<User> _users = [];
  User? _selectedUser;
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;

  List<User> get users => _users;
  User? get selectedUser => _selectedUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;

  // Add currentUser getter that delegates to AuthProvider
  User? get currentUser {
    // This will be accessed through Provider.of<AuthProvider>(context, listen: false).user
    // or context.read<AuthProvider>().user in the calling code
    return null; // This is a placeholder - the actual implementation will be in the calling code
  }

  Future<void> loadUsers({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _users.clear();
      _hasMore = true;
    }

    if (!_hasMore || _isLoading) return;

    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService.getUsers(page: _currentPage);

      if (response['success'] == true) {
        final data = response['data'];
        final newUsers = (data['data'] as List)
            .map((json) => User.fromJson(json))
            .toList();

        if (refresh) {
          _users = newUsers;
        } else {
          _users.addAll(newUsers);
        }

        _hasMore = data['next_page_url'] != null;
        _currentPage++;
        _setLoading(false);
        notifyListeners();
      } else {
        _setError(response['message'] ?? 'Failed to load users');
      }
    } catch (e) {
      _setError('Network error: ${e.toString()}');
    }
  }

  Future<bool> createUser(Map<String, dynamic> data) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService.createUser(data);

      if (response['success'] == true) {
        final user = User.fromJson(response['data']);
        _users.insert(0, user);
        _setLoading(false);
        notifyListeners();

        // Show notification
        await NotificationService().showUserCreatedNotification(user.name);
        return true;
      } else {
        _setError(response['message'] ?? 'Failed to create user');
        return false;
      }
    } catch (e) {
      _setError('Network error: ${e.toString()}');
      return false;
    }
  }

  Future<bool> updateUser(int id, Map<String, dynamic> data) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService.updateUser(id, data);

      if (response['success'] == true) {
        final updatedUser = User.fromJson(response['data']);
        final index = _users.indexWhere((u) => u.id == id);
        if (index != -1) {
          _users[index] = updatedUser;
        }
        _setLoading(false);
        notifyListeners();

        // Show notification
        await NotificationService().showUserUpdatedNotification(updatedUser.name);
        return true;
      } else {
        _setError(response['message'] ?? 'Failed to update user');
        return false;
      }
    } catch (e) {
      _setError('Network error: ${e.toString()}');
      return false;
    }
  }

  Future<bool> deleteUser(int id) async {
    _setLoading(true);
    _clearError();

    try {
      final user = _users.firstWhere((u) => u.id == id);
      final response = await ApiService.deleteUser(id);

      if (response['success'] == true) {
        _users.removeWhere((u) => u.id == id);
        _setLoading(false);
        notifyListeners();

        // Show notification
        await NotificationService().showUserDeletedNotification(user.name);
        return true;
      } else {
        _setError(response['message'] ?? 'Failed to delete user');
        return false;
      }
    } catch (e) {
      _setError('Network error: ${e.toString()}');
      return false;
    }
  }

  Future<void> loadUser(int id) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService.getUser(id);

      if (response['success'] == true) {
        _selectedUser = User.fromJson(response['data']);
        _setLoading(false);
        notifyListeners();
      } else {
        _setError(response['message'] ?? 'Failed to load user');
      }
    } catch (e) {
      _setError('Network error: ${e.toString()}');
    }
  }

  void selectUser(User user) {
    _selectedUser = user;
    notifyListeners();
  }

  void clearSelectedUser() {
    _selectedUser = null;
    notifyListeners();
  }

  List<User> getUsersByType(String type) {
    return _users.where((user) => user.type == type).toList();
  }

  List<User> getAdmins() {
    return getUsersByType('admin');
  }

  List<User> getDbUsers() {
    return getUsersByType('db');
  }

  List<User> getEmployees() {
    return getUsersByType('employee');
  }

  List<User> getDefaultUsers() {
    return getUsersByType('default');
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

  void refresh() {
    loadUsers(refresh: true);
  }
}
