import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> init() async {
    // Request permissions
    await Permission.notification.request();

    // Initialize Android settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Initialize iOS settings
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Initialize settings
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    print('Notification tapped: ${response.payload}');
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'task_manager_channel',
      'Task Manager Notifications',
      channelDescription: 'Notifications for task management operations',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      autoCancel: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  // Specific notification methods for different operations
  Future<void> showProjectCreatedNotification(String projectName) async {
    await showNotification(
      title: 'Project Created',
      body: 'Project "$projectName" has been created successfully.',
      payload: 'project_created',
    );
  }

  Future<void> showProjectUpdatedNotification(String projectName) async {
    await showNotification(
      title: 'Project Updated',
      body: 'Project "$projectName" has been updated.',
      payload: 'project_updated',
    );
  }

  Future<void> showProjectDeletedNotification(String projectName) async {
    await showNotification(
      title: 'Project Deleted',
      body: 'Project "$projectName" has been deleted.',
      payload: 'project_deleted',
    );
  }

  Future<void> showTicketCreatedNotification(String ticketName) async {
    await showNotification(
      title: 'Ticket Created',
      body: 'Ticket "$ticketName" has been created successfully.',
      payload: 'ticket_created',
    );
  }

  Future<void> showTicketUpdatedNotification(String ticketName) async {
    await showNotification(
      title: 'Ticket Updated',
      body: 'Ticket "$ticketName" has been updated.',
      payload: 'ticket_updated',
    );
  }

  Future<void> showTicketDeletedNotification(String ticketName) async {
    await showNotification(
      title: 'Ticket Deleted',
      body: 'Ticket "$ticketName" has been deleted.',
      payload: 'ticket_deleted',
    );
  }

  Future<void> showUserCreatedNotification(String userName) async {
    await showNotification(
      title: 'User Created',
      body: 'User "$userName" has been created successfully.',
      payload: 'user_created',
    );
  }

  Future<void> showUserUpdatedNotification(String userName) async {
    await showNotification(
      title: 'User Updated',
      body: 'User "$userName" has been updated.',
      payload: 'user_updated',
    );
  }

  Future<void> showUserDeletedNotification(String userName) async {
    await showNotification(
      title: 'User Deleted',
      body: 'User "$userName" has been deleted.',
      payload: 'user_deleted',
    );
  }

  Future<void> showErrorNotification(String message) async {
    await showNotification(
      title: 'Error',
      body: message,
      payload: 'error',
    );
  }

  Future<void> showSuccessNotification(String message) async {
    await showNotification(
      title: 'Success',
      body: message,
      payload: 'success',
    );
  }
} 