import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tmapp/config/app_config.dart';

class ApiTest {
  static Future<void> testBasicConnection() async {
    print('🔍 Testing basic API connection...');
    print('📡 Base URL: ${AppConfig.apiBaseUrl}');
    
    try {
      // Test basic connection with the test endpoint
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/test'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      print('📊 Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        print('✅ API connection successful!');
      } else {
        print('⚠️ API responded with status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Connection error: $e');
      print('💡 Make sure your Laravel server is running and accessible');
    }
  }

  static Future<void> testConnection() async {
    print('🔍 Testing API connection...');
    print('📡 Base URL: ${AppConfig.apiBaseUrl}');
    
    try {
      // Test basic connection
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/dashboard'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      print('📊 Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        print('✅ API connection successful!');
      } else if (response.statusCode == 404) {
        print('❌ API endpoint not found. Check if Laravel API routes are configured.');
        print('💡 Try accessing: ${AppConfig.apiBaseUrl}/dashboard in your browser');
      } else {
        print('⚠️ API responded with status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Connection error: $e');
      print('💡 Make sure your Laravel server is running and accessible');
    }
  }
  
  static Future<void> testAuth() async {
    print('🔐 Testing authentication...');
    
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': 'john.doe@helper.app',
          'password': 'Passw@rd',
        }),
      );
      
      print('🔐 Auth Response Status: ${response.statusCode}');
      print('🔐 Auth Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        print('✅ Authentication endpoint working!');
      } else {
        print('❌ Authentication failed. Check credentials and API setup.');
      }
    } catch (e) {
      print('❌ Authentication error: $e');
    }
  }

  static Future<void> testLoginResponse() async {
    print('🔐 Testing login response structure...');
    
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': 'prashikpatil5555@gmail.com',
          'password': 'TMprashik@1886',
        }),
      );
      
      print('🔐 Login Response Status: ${response.statusCode}');
      print('🔐 Login Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('🔐 Parsed Response: $data');
        
        if (data['success'] == true) {
          print('✅ Login successful!');
          print('🔐 Response structure: ${data.keys.toList()}');
          if (data['data'] != null) {
            print('🔐 Data structure: ${data['data'].keys.toList()}');
            if (data['data']['user'] != null) {
              print('🔐 User structure: ${data['data']['user'].keys.toList()}');
            }
            if (data['data']['token'] != null) {
              print('🔐 Token: ${data['data']['token']}');
            }
          }
        } else {
          print('❌ Login failed: ${data['message']}');
        }
      } else {
        print('❌ Login request failed with status: ${response.statusCode}');
        print('❌ Error body: ${response.body}');
      }
    } catch (e) {
      print('❌ Login test error: $e');
    }
  }

  static Future<void> testUserExists() async {
    print('👤 Testing if user exists...');
    
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/test-user'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      print('👤 User Test Response Status: ${response.statusCode}');
      print('👤 User Test Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          print('✅ User exists in database!');
        } else {
          print('❌ User not found in database');
        }
      }
    } catch (e) {
      print('❌ User test error: $e');
    }
  }
} 