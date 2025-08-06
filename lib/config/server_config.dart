// Server Configuration for Task Manager Mobile App
// 
// INSTRUCTIONS:
// 1. Replace 'your-domain.com' with your actual cPanel domain
// 2. Make sure your Laravel API endpoints are accessible at yourdomain.com/api
// 3. Ensure CORS is properly configured on your Laravel server
// 4. Test the API endpoints in a browser: yourdomain.com/api/dashboard

class ServerConfig {
  // Your cPanel server domain (replace with your actual domain)
  static const String liveServerUrl = 'https://your-domain.com';
  
  // API endpoints
  static const String apiBasePath = '/api';
  
  // Full API URL
  static String get apiUrl => '$liveServerUrl$apiBasePath';
  
  // Common API endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String dashboardEndpoint = '/dashboard';
  static const String projectsEndpoint = '/projects';
  static const String ticketsEndpoint = '/tickets';
  static const String usersEndpoint = '/users';
  
  // Timeout settings
  static const int connectionTimeoutSeconds = 30;
  static const int receiveTimeoutSeconds = 30;
  
  // Retry settings
  static const int maxRetries = 3;
  static const int retryDelaySeconds = 2;
}

// Example usage:
// final apiUrl = ServerConfig.apiUrl; // https://your-domain.com/api
// final loginUrl = ServerConfig.apiUrl + ServerConfig.loginEndpoint; // https://your-domain.com/api/auth/login 