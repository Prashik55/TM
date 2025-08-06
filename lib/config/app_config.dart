class AppConfig {
  // Environment configuration
  static const String environment = String.fromEnvironment('ENVIRONMENT', defaultValue: 'production');
  
  // API Base URLs for different environments
  static const Map<String, String> apiUrls = {
    'development': 'http://10.0.2.2:8000/api', // Android emulator
    'local': 'http://localhost:8000/api', // iOS simulator and web
    'web': 'http://localhost:8000/api', // Web platform
    'production': 'https://manishflourmills.com/TM/public/api', // Your actual cPanel domain with subdirectory
  };
  
  // Get the appropriate API URL based on environment
  static String get apiBaseUrl {
    // Check if running on web platform
    if (environment == 'web' || environment == 'local') {
      final url = apiUrls['local'] ?? apiUrls['production']!;
      print('Using API URL: $url');
      return url;
    }
    
    final url = apiUrls[environment] ?? apiUrls['production']!;
    print('Using API URL: $url');
    return url;
  }
  
  // App configuration
  static const String appName = 'Task Manager';
  static const String appVersion = '1.0.0';
  
  // Timeout configurations
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Cache configurations
  static const Duration cacheTimeout = Duration(minutes: 5);
  
  // Notification configurations
  static const Duration notificationDuration = Duration(seconds: 3);
  
  // Debug mode
  static const bool debugMode = true;
} 