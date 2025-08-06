import 'package:flutter/material.dart';
import 'package:tmapp/models/project.dart';
import 'package:tmapp/services/api_service.dart';
import 'package:tmapp/services/database_service.dart';
import 'package:tmapp/services/connectivity_service.dart';
import 'package:tmapp/services/notification_service.dart';

class ProjectProvider extends ChangeNotifier {
  List<Project> _projects = [];
  Project? _selectedProject;
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isOffline = false;

  List<Project> get projects => _projects;
  Project? get selectedProject => _selectedProject;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;
  bool get isOffline => _isOffline;

  Future<void> loadProjects({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _projects.clear();
      _hasMore = true;
    }

    if (!_hasMore || _isLoading) return;

    _setLoading(true);
    _clearError();

    try {
      // Check if we're online
      if (ConnectivityService().isConnected) {
        // Try to load from API
        try {
          final response = await ApiService.getProjects(page: _currentPage);
          
          if (response['success'] == true) {
            final data = response['data'];
            final newProjects = (data['data'] as List)
                .map((json) => Project.fromJson(json))
                .toList();
            
            if (refresh) {
              _projects = newProjects;
            } else {
              _projects.addAll(newProjects);
            }
            
            _hasMore = data['next_page_url'] != null;
            _currentPage++;
            _isOffline = false;
            
            // Save to local database
            for (final project in newProjects) {
              await DatabaseService.saveProject(project.toJson());
            }
            
            _setLoading(false);
            notifyListeners();
          } else {
            _setError(response['message'] ?? 'Failed to load projects');
            await _loadFromLocal();
          }
        } catch (e) {
          print('API error: $e');
          await _loadFromLocal();
        }
      } else {
        // Offline mode
        print('Loading projects from local database (offline mode)');
        await _loadFromLocal();
      }
    } catch (e) {
      _setError('Error loading projects: $e');
      await _loadFromLocal();
    }
  }

  Future<void> _loadFromLocal() async {
    try {
      final localData = await DatabaseService.getProjects();
      final localProjects = localData.map((json) => Project.fromJson(json)).toList();
      
      _projects = localProjects;
      _hasMore = false;
      _isOffline = true;
      _setLoading(false);
      notifyListeners();
      
      print('Projects loaded from local database: ${_projects.length} projects');
    } catch (e) {
      print('Error loading from local: $e');
      _projects = [];
      _hasMore = false;
      _isOffline = true;
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<bool> createProject(Map<String, dynamic> data) async {
    _setLoading(true);
    _clearError();

    try {
      if (ConnectivityService().isConnected) {
        // Try to create via API
        try {
          final response = await ApiService.createProject(data);
          
          if (response['success'] == true) {
            final project = Project.fromJson(response['data']);
            _projects.insert(0, project);
            _setLoading(false);
            _isOffline = false;
            notifyListeners();
            
            // Save to local database
            await DatabaseService.saveProject(project.toJson());
            
            // Show notification
            await NotificationService().showProjectCreatedNotification(project.name);
            return true;
          } else {
            _setError(response['message'] ?? 'Failed to create project');
            return false;
          }
        } catch (e) {
          print('API error: $e');
          return await _createOffline(data);
        }
      } else {
        // Offline mode
        return await _createOffline(data);
      }
    } catch (e) {
      _setError('Error creating project: $e');
      return false;
    }
  }

  Future<bool> _createOffline(Map<String, dynamic> data) async {
    try {
      // Create temporary project with negative ID for offline
      final tempId = -DateTime.now().millisecondsSinceEpoch;
      final offlineProject = Project.fromJson({
        ...data,
        'id': tempId,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      
      _projects.insert(0, offlineProject);
      _isOffline = true;
      _setLoading(false);
      notifyListeners();
      
      // Save offline action
      await DatabaseService.saveOfflineAction('create', 'projects', data);
      
      // Save to local database
      await DatabaseService.saveProject(offlineProject.toJson());
      
      print('Project created offline. Will sync when connection is restored.');
      
      return true;
    } catch (e) {
      _setError('Error creating offline project: $e');
      return false;
    }
  }

  Future<bool> updateProject(int id, Map<String, dynamic> data) async {
    _setLoading(true);
    _clearError();

    try {
      if (ConnectivityService().isConnected) {
        // Try to update via API
        try {
          final response = await ApiService.updateProject(id, data);
          
          if (response['success'] == true) {
            final updatedProject = Project.fromJson(response['data']);
            final index = _projects.indexWhere((p) => p.id == id);
            if (index != -1) {
              _projects[index] = updatedProject;
            }
            _setLoading(false);
            _isOffline = false;
            notifyListeners();
            
            // Update local database
            await DatabaseService.saveProject(updatedProject.toJson());
            
            return true;
          } else {
            _setError(response['message'] ?? 'Failed to update project');
            return false;
          }
        } catch (e) {
          print('API error: $e');
          return await _updateOffline(id, data);
        }
      } else {
        // Offline mode
        return await _updateOffline(id, data);
      }
    } catch (e) {
      _setError('Error updating project: $e');
      return false;
    }
  }

  Future<bool> _updateOffline(int id, Map<String, dynamic> data) async {
    try {
      final index = _projects.indexWhere((p) => p.id == id);
      if (index != -1) {
        final updatedProject = Project.fromJson({
          ..._projects[index].toJson(),
          ...data,
          'updated_at': DateTime.now().toIso8601String(),
        });
        
        _projects[index] = updatedProject;
        _isOffline = true;
        _setLoading(false);
        notifyListeners();
        
        // Save offline action
        await DatabaseService.saveOfflineAction('update', 'projects', {
          'id': id,
          ...data,
        });
        
        // Update local database
        await DatabaseService.saveProject(updatedProject.toJson());
        
        print('Project updated offline. Will sync when connection is restored.');
        
        return true;
      }
      return false;
    } catch (e) {
      _setError('Error updating offline project: $e');
      return false;
    }
  }

  Future<bool> deleteProject(int id) async {
    _setLoading(true);
    _clearError();

    try {
      if (ConnectivityService().isConnected) {
        // Try to delete via API
        try {
          final response = await ApiService.deleteProject(id);
          
          if (response['success'] == true) {
            _projects.removeWhere((p) => p.id == id);
            _setLoading(false);
            _isOffline = false;
            notifyListeners();
            
            // Remove from local database
            await DatabaseService.deleteProject(id);
            
            return true;
          } else {
            _setError(response['message'] ?? 'Failed to delete project');
            return false;
          }
        } catch (e) {
          print('API error: $e');
          return await _deleteOffline(id);
        }
      } else {
        // Offline mode
        return await _deleteOffline(id);
      }
    } catch (e) {
      _setError('Error deleting project: $e');
      return false;
    }
  }

  Future<bool> _deleteOffline(int id) async {
    try {
      _projects.removeWhere((p) => p.id == id);
      _isOffline = true;
      _setLoading(false);
      notifyListeners();
      
      // Save offline action
      await DatabaseService.saveOfflineAction('delete', 'projects', {'id': id});
      
      // Remove from local database
      await DatabaseService.deleteProject(id);
      
      print('Project deleted offline. Will sync when connection is restored.');
      
      return true;
    } catch (e) {
      _setError('Error deleting offline project: $e');
      return false;
    }
  }

  void selectProject(Project project) {
    _selectedProject = project;
    notifyListeners();
  }

  void clearSelectedProject() {
    _selectedProject = null;
    notifyListeners();
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