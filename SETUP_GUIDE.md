# Flutter App Setup Guide for Live cPanel Server

## 🚀 Quick Setup

### 1. Configure Your Live Server URL

Edit `lib/config/app_config.dart` and replace the production URL:

```dart
static const Map<String, String> apiUrls = {
  'development': 'http://10.0.2.2:8000/api', // Android emulator
  'local': 'http://localhost:8000/api', // iOS simulator
  'production': 'https://your-actual-domain.com/api', // Replace with your cPanel domain
};
```

### 2. Verify Your Laravel API Endpoints

Make sure these endpoints are accessible on your cPanel server:
- `https://yourdomain.com/api/auth/login`
- `https://yourdomain.com/api/auth/register`
- `https://yourdomain.com/api/dashboard`
- `https://yourdomain.com/api/projects`
- `https://yourdomain.com/api/tickets`
- `https://yourdomain.com/api/users`

### 3. Configure CORS on Your Laravel Server

Add this to your Laravel `config/cors.php`:

```php
return [
    'paths' => ['api/*'],
    'allowed_methods' => ['*'],
    'allowed_origins' => ['*'],
    'allowed_origins_patterns' => [],
    'allowed_headers' => ['*'],
    'exposed_headers' => [],
    'max_age' => 0,
    'supports_credentials' => false,
];
```

### 4. Run the Flutter App

```bash
cd TMApp
flutter pub get
flutter run
```

## 🔧 Detailed Configuration

### Environment Setup

The app supports multiple environments:

- **Development**: Local development with Android emulator
- **Local**: Local development with iOS simulator  
- **Production**: Live cPanel server

### Real-Time Features

The app includes real-time data polling:
- Dashboard updates every 10 seconds
- Projects, tickets, and users data refresh automatically
- Notifications for CRUD operations
- Offline data caching

### Login Credentials

Use your existing Laravel user credentials:
- **Email**: `john.doe@helper.app`
- **Password**: `Passw@rd`
- **Type**: Admin

Or register a new user through the app.

## 🐛 Troubleshooting

### Common Issues:

1. **Connection Error**: Check your domain URL in `app_config.dart`
2. **CORS Error**: Verify CORS configuration on your Laravel server
3. **API 404**: Ensure API routes are properly configured
4. **Authentication Error**: Check if Sanctum is properly configured

### Testing API Endpoints:

Test your API endpoints in a browser:
```
https://yourdomain.com/api/dashboard
https://yourdomain.com/api/projects
https://yourdomain.com/api/tickets
```

### Debug Mode:

To run in development mode with local server:
```bash
flutter run --dart-define=ENVIRONMENT=development
```

## 📱 Features

- ✅ Cross-platform (Android & iOS)
- ✅ Real-time data updates
- ✅ Role-based access control
- ✅ Offline support
- ✅ Push notifications
- ✅ Modern Material Design UI
- ✅ Secure authentication
- ✅ Data synchronization

## 🔄 Real-Time Updates

The app automatically:
- Polls for new data every 10 seconds
- Updates dashboard statistics
- Refreshes project and ticket lists
- Shows notifications for changes
- Syncs offline data when online

## 📞 Support

If you encounter issues:
1. Check the console logs for error messages
2. Verify your API endpoints are accessible
3. Ensure CORS is properly configured
4. Test with a simple API call first 