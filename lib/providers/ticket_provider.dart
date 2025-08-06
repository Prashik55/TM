import 'package:flutter/material.dart';
import 'package:tmapp/models/ticket.dart';
import 'package:tmapp/services/api_service.dart';
import 'package:tmapp/services/database_service.dart';
import 'package:tmapp/services/connectivity_service.dart';
import 'package:tmapp/services/notification_service.dart';

class TicketProvider extends ChangeNotifier {
  List<Ticket> _tickets = [];
  Ticket? _selectedTicket;
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isOffline = false;

  List<Ticket> get tickets => _tickets;
  Ticket? get selectedTicket => _selectedTicket;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;
  bool get isOffline => _isOffline;

  Future<void> loadTickets({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _tickets.clear();
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
          final response = await ApiService.getTickets(page: _currentPage);
          
          if (response['success'] == true) {
            final data = response['data'];
            final newTickets = (data['data'] as List)
                .map((json) => Ticket.fromJson(json))
                .toList();
            
            if (refresh) {
              _tickets = newTickets;
            } else {
              _tickets.addAll(newTickets);
            }
            
            _hasMore = data['next_page_url'] != null;
            _currentPage++;
            _isOffline = false;
            
            // Save to local database
            for (final ticket in newTickets) {
              await DatabaseService.saveTicket(ticket.toJson());
            }
            
            _setLoading(false);
            notifyListeners();
          } else {
            _setError(response['message'] ?? 'Failed to load tickets');
            await _loadFromLocal();
          }
        } catch (e) {
          print('API error: $e');
          await _loadFromLocal();
        }
      } else {
        // Offline mode
        print('Loading tickets from local database (offline mode)');
        await _loadFromLocal();
      }
    } catch (e) {
      _setError('Error loading tickets: $e');
      await _loadFromLocal();
    }
  }

  Future<void> _loadFromLocal() async {
    try {
      final localData = await DatabaseService.getTickets();
      final localTickets = localData.map((json) => Ticket.fromJson(json)).toList();
      
      _tickets = localTickets;
      _hasMore = false;
      _isOffline = true;
      _setLoading(false);
      notifyListeners();
      
      print('Tickets loaded from local database: ${_tickets.length} tickets');
    } catch (e) {
      print('Error loading from local: $e');
      _tickets = [];
      _hasMore = false;
      _isOffline = true;
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<bool> createTicket(Map<String, dynamic> data) async {
    _setLoading(true);
    _clearError();

    try {
      if (ConnectivityService().isConnected) {
        // Try to create via API
        try {
          final response = await ApiService.createTicket(data);
          
          if (response['success'] == true) {
            final ticket = Ticket.fromJson(response['data']);
            _tickets.insert(0, ticket);
            _setLoading(false);
            _isOffline = false;
            notifyListeners();
            
            // Save to local database
            await DatabaseService.saveTicket(ticket.toJson());
            
            // Show notification
            await NotificationService().showTicketCreatedNotification(ticket.name);
            return true;
          } else {
            _setError(response['message'] ?? 'Failed to create ticket');
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
      _setError('Error creating ticket: $e');
      return false;
    }
  }

  Future<bool> _createOffline(Map<String, dynamic> data) async {
    try {
      // Create temporary ticket with negative ID for offline
      final tempId = -DateTime.now().millisecondsSinceEpoch;
      final offlineTicket = Ticket.fromJson({
        ...data,
        'id': tempId,
        'order': 0,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      
      _tickets.insert(0, offlineTicket);
      _isOffline = true;
      _setLoading(false);
      notifyListeners();
      
      // Save offline action
      await DatabaseService.saveOfflineAction('create', 'tickets', data);
      
      // Save to local database
      await DatabaseService.saveTicket(offlineTicket.toJson());
      
      print('Ticket created offline. Will sync when connection is restored.');
      
      return true;
    } catch (e) {
      _setError('Error creating offline ticket: $e');
      return false;
    }
  }

  Future<bool> updateTicket(int id, Map<String, dynamic> data) async {
    _setLoading(true);
    _clearError();

    try {
      if (ConnectivityService().isConnected) {
        // Try to update via API
        try {
          final response = await ApiService.updateTicket(id, data);
          
          if (response['success'] == true) {
            final updatedTicket = Ticket.fromJson(response['data']);
            final index = _tickets.indexWhere((t) => t.id == id);
            if (index != -1) {
              _tickets[index] = updatedTicket;
            }
            _setLoading(false);
            _isOffline = false;
            notifyListeners();
            
            // Update local database
            await DatabaseService.saveTicket(updatedTicket.toJson());
            
            return true;
          } else {
            _setError(response['message'] ?? 'Failed to update ticket');
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
      _setError('Error updating ticket: $e');
      return false;
    }
  }

  Future<bool> _updateOffline(int id, Map<String, dynamic> data) async {
    try {
      final index = _tickets.indexWhere((t) => t.id == id);
      if (index != -1) {
        final updatedTicket = Ticket.fromJson({
          ..._tickets[index].toJson(),
          ...data,
          'updated_at': DateTime.now().toIso8601String(),
        });
        
        _tickets[index] = updatedTicket;
        _isOffline = true;
        _setLoading(false);
        notifyListeners();
        
        // Save offline action
        await DatabaseService.saveOfflineAction('update', 'tickets', {
          'id': id,
          ...data,
        });
        
        // Update local database
        await DatabaseService.saveTicket(updatedTicket.toJson());
        
        print('Ticket updated offline. Will sync when connection is restored.');
        
        return true;
      }
      return false;
    } catch (e) {
      _setError('Error updating offline ticket: $e');
      return false;
    }
  }

  Future<bool> deleteTicket(int id) async {
    _setLoading(true);
    _clearError();

    try {
      if (ConnectivityService().isConnected) {
        // Try to delete via API
        try {
          final response = await ApiService.deleteTicket(id);
          
          if (response['success'] == true) {
            _tickets.removeWhere((t) => t.id == id);
            _setLoading(false);
            _isOffline = false;
            notifyListeners();
            
            // Remove from local database
            await DatabaseService.deleteTicket(id);
            
            return true;
          } else {
            _setError(response['message'] ?? 'Failed to delete ticket');
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
      _setError('Error deleting ticket: $e');
      return false;
    }
  }

  Future<bool> _deleteOffline(int id) async {
    try {
      _tickets.removeWhere((t) => t.id == id);
      _isOffline = true;
      _setLoading(false);
      notifyListeners();
      
      // Save offline action
      await DatabaseService.saveOfflineAction('delete', 'tickets', {'id': id});
      
      // Remove from local database
      await DatabaseService.deleteTicket(id);
      
      print('Ticket deleted offline. Will sync when connection is restored.');
      
      return true;
    } catch (e) {
      _setError('Error deleting offline ticket: $e');
      return false;
    }
  }

  Future<void> loadTicket(int id) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService.getTicket(id);
      
      if (response['success'] == true) {
        _selectedTicket = Ticket.fromJson(response['data']);
        _setLoading(false);
        notifyListeners();
      } else {
        _setError(response['message'] ?? 'Failed to load ticket');
      }
    } catch (e) {
      _setError('Network error: ${e.toString()}');
    }
  }

  void selectTicket(Ticket ticket) {
    _selectedTicket = ticket;
    notifyListeners();
  }

  void clearSelectedTicket() {
    _selectedTicket = null;
    notifyListeners();
  }

  List<Ticket> getTicketsByProject(int projectId) {
    return _tickets.where((ticket) => ticket.projectId == projectId).toList();
  }

  List<Ticket> getTicketsByStatus(int statusId) {
    return _tickets.where((ticket) => ticket.statusId == statusId).toList();
  }

  List<Ticket> getOverdueTickets() {
    return _tickets.where((ticket) => ticket.isOverdue).toList();
  }

  List<Ticket> getDueSoonTickets() {
    return _tickets.where((ticket) => ticket.isDueSoon).toList();
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
    loadTickets(refresh: true);
  }
} 