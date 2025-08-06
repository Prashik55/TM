import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tmapp/providers/auth_provider.dart';
import 'package:tmapp/screens/auth/login_screen.dart';
import 'package:tmapp/screens/main_screen.dart';
import 'package:tmapp/screens/splash_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        print('AuthWrapper - REBUILD - isInitialized: ${authProvider.isInitialized}, isAuthenticated: ${authProvider.isAuthenticated}');
        
        // Show splash screen while checking authentication
        if (!authProvider.isInitialized) {
          print('AuthWrapper - Showing SplashScreen');
          return const SplashScreen();
        }

        // If not authenticated, show login screen
        if (!authProvider.isAuthenticated) {
          print('AuthWrapper - Showing LoginScreen');
          return const LoginScreen();
        }

        // If authenticated, show main app
        print('AuthWrapper - Showing MainScreen');
        return const MainScreen();
      },
    );
  }
} 