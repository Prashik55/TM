# Task Manager Mobile App (TMApp)

A cross-platform Flutter mobile application for task and project management, designed to work with the Laravel Task Manager backend.

## Features

### 🔐 Authentication
- User login and registration
- Role-based access control
- Secure token-based authentication
- Email verification support

### 👥 User Roles
- **Admin**: Full access to all features including user management
- **Database Manager (DB)**: Can manage projects and tickets
- **Employee**: Can view and manage tickets
- **Default User**: Basic access to tickets

### 📊 Dashboard
- Personalized statistics based on user role
- Recent projects and tickets
- Quick overview of important metrics

### 📁 Projects Management
- Create, read, update, and delete projects
- Project status tracking
- Deadline management
- Team member assignment

### 🎫 Tickets Management
- Create, read, update, and delete tickets
- Ticket status and priority tracking
- Estimation and deadline management
- Assignment to team members

### 👤 User Management (Admin Only)
- Add, edit, and delete users
- Role assignment
- User status management

### 🔔 Notifications
- Local notifications for CRUD operations
- Auto-disappearing notifications
- Non-persistent device notifications

### 📱 Cross-Platform
- Android and iOS support
- Responsive design
- Native performance

## Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / Xcode (for device testing)
- Laravel backend running (see main project README)

## Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd TMApp
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API endpoint**
   - Open `lib/services/api_service.dart`
   - Update the `baseUrl` to match your Laravel backend:
     ```dart
     static const String baseUrl = 'http://your-backend-url/api';
     ```

4. **Run the app**
   ```bash
   flutter run
   ```

## Configuration

### API Configuration
The app connects to the Laravel backend API. Make sure your backend is running and accessible.

For development:
- Android Emulator: `http://10.0.2.2:8000/api`
- iOS Simulator: `http://localhost:8000/api`
- Physical Device: `http://your-computer-ip:8000/api`

### Permissions
The app requires the following permissions:
- Internet access
- Notification permissions (for local notifications)

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── user.dart
│   ├── project.dart
│   └── ticket.dart
├── providers/                # State management
│   ├── auth_provider.dart
│   ├── project_provider.dart
│   ├── ticket_provider.dart
│   └── user_provider.dart
├── screens/                  # UI screens
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── dashboard_screen.dart
│   ├── projects_screen.dart
│   ├── tickets_screen.dart
│   ├── users_screen.dart
│   └── profile_screen.dart
└── services/                 # API and utility services
    ├── api_service.dart
    └── notification_service.dart
```

## Dependencies

- `http`: HTTP client for API calls
- `provider`: State management
- `flutter_secure_storage`: Secure token storage
- `shared_preferences`: Local data storage
- `flutter_local_notifications`: Local notifications
- `permission_handler`: Permission management
- `connectivity_plus`: Network connectivity
- `sqflite`: Local database (for offline support)
- `intl`: Internationalization

## Features in Detail

### Authentication Flow
1. App starts with splash screen
2. Checks for existing authentication token
3. If valid, navigates to main screen
4. If invalid/missing, shows login screen
5. After successful login, stores token securely

### Role-Based Access
- **Admin**: All screens available
- **DB Manager**: Dashboard, Projects, Tickets, Profile
- **Employee/Default**: Dashboard, Tickets, Profile

### Offline Support
- Data caching for offline access
- Sync when connection restored
- Local storage for essential data

### Notifications
- Project CRUD notifications
- Ticket CRUD notifications
- User management notifications (admin only)
- Auto-disappearing after 5 seconds

## Development

### Adding New Features
1. Create models in `lib/models/`
2. Add API methods in `lib/services/api_service.dart`
3. Create providers for state management
4. Build UI screens
5. Update navigation as needed

### Testing
```bash
flutter test
```

### Building for Production
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## Troubleshooting

### Common Issues

1. **API Connection Failed**
   - Check if Laravel backend is running
   - Verify API URL in `api_service.dart`
   - Check network connectivity

2. **Build Errors**
   - Run `flutter clean`
   - Run `flutter pub get`
   - Check Flutter version compatibility

3. **Permission Issues**
   - Ensure notification permissions are granted
   - Check device settings

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License.

## Support

For support and questions:
- Check the main Laravel project documentation
- Review the API documentation
- Create an issue in the repository
