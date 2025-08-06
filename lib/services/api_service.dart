import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tmapp/config/app_config.dart';

class ApiService {
  static String get baseUrl => AppConfig.apiBaseUrl;
  
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  static Future<void> setToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  static Future<void> removeToken() async {
    await _storage.delete(key: 'auth_token');
  }

  static Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<http.Response> get(String endpoint) async {
    final headers = await _getHeaders();
    final url = '$baseUrl$endpoint';
    
    print('=== API GET Request ===');
    print('URL: $url');
    print('Headers: $headers');
    print('Base URL: $baseUrl');
    print('Environment: ${AppConfig.environment}');
    
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(AppConfig.connectionTimeout);
      
      print('=== API Response ===');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');
      
      return response;
    } catch (e) {
      print('=== API Error ===');
      print('Error: $e');
      rethrow;
    }
  }

  static Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final url = '$baseUrl$endpoint';
    
    if (AppConfig.debugMode) {
      print('POST Request: $url');
      print('Data: $data');
      print('Headers: $headers');
    }
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(data),
      ).timeout(AppConfig.connectionTimeout);
      
      if (AppConfig.debugMode) {
        print('Response Status: ${response.statusCode}');
        print('Response Body: ${response.body}');
      }
      
      return response;
    } catch (e) {
      if (AppConfig.debugMode) {
        print('POST Request Error: $e');
      }
      rethrow;
    }
  }

  static Future<http.Response> put(String endpoint, Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final url = '$baseUrl$endpoint';
    
    if (AppConfig.debugMode) {
      print('PUT Request: $url');
      print('Data: $data');
      print('Headers: $headers');
    }
    
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(data),
      ).timeout(AppConfig.connectionTimeout);
      
      if (AppConfig.debugMode) {
        print('Response Status: ${response.statusCode}');
        print('Response Body: ${response.body}');
      }
      
      return response;
    } catch (e) {
      if (AppConfig.debugMode) {
        print('PUT Request Error: $e');
      }
      rethrow;
    }
  }

  static Future<http.Response> delete(String endpoint) async {
    final headers = await _getHeaders();
    final url = '$baseUrl$endpoint';
    
    if (AppConfig.debugMode) {
      print('DELETE Request: $url');
      print('Headers: $headers');
    }
    
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
      ).timeout(AppConfig.connectionTimeout);
      
      if (AppConfig.debugMode) {
        print('Response Status: ${response.statusCode}');
        print('Response Body: ${response.body}');
      }
      
      return response;
    } catch (e) {
      if (AppConfig.debugMode) {
        print('DELETE Request Error: $e');
      }
      rethrow;
    }
  }

  // Test endpoint
  static Future<Map<String, dynamic>> testConnection() async {
    try {
      final response = await get('/test');
      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection failed: $e',
      };
    }
  }

  // Auth endpoints
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await post('/auth/login', {
      'email': email,
      'password': password,
    });
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> register(String name, String email, String password, String type) async {
    final response = await post('/auth/register', {
      'name': name,
      'email': email,
      'password': password,
      'type': type,
    });
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getProfile() async {
    final response = await get('/auth/profile');
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> logout() async {
    final response = await post('/auth/logout', {});
    return jsonDecode(response.body);
  }

  // Dashboard
  static Future<Map<String, dynamic>> getDashboard() async {
    final response = await get('/dashboard');
    return jsonDecode(response.body);
  }

  // Projects
  static Future<Map<String, dynamic>> getProjects({int? page}) async {
    final response = await get('/projects${page != null ? '?page=$page' : ''}');
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getProject(int id) async {
    final response = await get('/projects/$id');
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> createProject(Map<String, dynamic> data) async {
    final response = await post('/projects', data);
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateProject(int id, Map<String, dynamic> data) async {
    final response = await put('/projects/$id', data);
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> deleteProject(int id) async {
    final response = await delete('/projects/$id');
    return jsonDecode(response.body);
  }

  // Tickets
  static Future<Map<String, dynamic>> getTickets({int? page}) async {
    final response = await get('/tickets${page != null ? '?page=$page' : ''}');
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getTicket(int id) async {
    final response = await get('/tickets/$id');
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> createTicket(Map<String, dynamic> data) async {
    final response = await post('/tickets', data);
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateTicket(int id, Map<String, dynamic> data) async {
    final response = await put('/tickets/$id', data);
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> deleteTicket(int id) async {
    final response = await delete('/tickets/$id');
    return jsonDecode(response.body);
  }

  // Users (admin only)
  static Future<Map<String, dynamic>> getUsers({int? page}) async {
    final response = await get('/users${page != null ? '?page=$page' : ''}');
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getUser(int id) async {
    final response = await get('/users/$id');
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> createUser(Map<String, dynamic> data) async {
    final response = await post('/users', data);
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateUser(int id, Map<String, dynamic> data) async {
    final response = await put('/users/$id', data);
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> deleteUser(int id) async {
    final response = await delete('/users/$id');
    return jsonDecode(response.body);
  }

  // Calendar
  static Future<Map<String, dynamic>> getCalendar() async {
    final response = await get('/calendar');
    return jsonDecode(response.body);
  }
} 