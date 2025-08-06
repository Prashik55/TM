import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tmapp/providers/auth_provider.dart';
import 'package:tmapp/providers/project_provider.dart';
import 'package:tmapp/providers/ticket_provider.dart';
import 'package:tmapp/providers/user_provider.dart';
import 'package:tmapp/providers/dashboard_provider.dart';
import 'package:tmapp/widgets/auth_wrapper.dart';
import 'package:tmapp/services/notification_service.dart';
import 'package:tmapp/services/connectivity_service.dart';
import 'package:tmapp/config/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  
  // Initialize connectivity service
  ConnectivityService().initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
        ChangeNotifierProvider(create: (_) => TicketProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
      ],
      child: MaterialApp(
        title: 'Task Manager',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}
