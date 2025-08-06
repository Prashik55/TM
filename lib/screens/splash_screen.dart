import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tmapp/providers/auth_provider.dart';
import 'package:tmapp/services/api_test.dart';
import 'package:tmapp/services/api_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _status = 'Initializing...';
  bool _isTesting = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    setState(() {
      _status = 'Testing API connection...';
    });

    // Test basic API connection
    try {
      final testResult = await ApiService.testConnection();
      print('API Test Result: $testResult');
      
      if (testResult['success'] == true) {
        setState(() {
          _status = 'API connection successful!';
        });
      } else {
        setState(() {
          _status = 'API connection failed: ${testResult['message']}';
        });
        await Future.delayed(const Duration(seconds: 2));
      }
    } catch (e) {
      setState(() {
        _status = 'API connection error: $e';
      });
      print('API Connection Error: $e');
      await Future.delayed(const Duration(seconds: 2));
    }
    
    setState(() {
      _status = 'Checking user account...';
    });

    // Test if user exists
    await ApiTest.testUserExists();
    
    setState(() {
      _status = 'Testing login response...';
    });

    // Test login response structure
    await ApiTest.testLoginResponse();
    
    setState(() {
      _status = 'Checking authentication status...';
      _isTesting = false;
    });

    // Check if user is already authenticated
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkAuthStatus();

    // The AuthWrapper will handle navigation based on authentication status
    print('Splash screen initialization complete');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo/Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.task_alt,
                size: 60,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 30),
            
            // App Title
            const Text(
              'Task Manager',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            
            // Status Text
            Text(
              _status,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            
            // Loading Indicator
            if (_isTesting)
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
          ],
        ),
      ),
    );
  }
} 