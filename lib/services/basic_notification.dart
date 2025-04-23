import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class BasicNotification {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<bool> initialize() async {
    try {
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      bool? result = await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse details) {
          print('Notification tapped with payload: ${details.payload}');
        },
      );

      print('Notification service initialized with result: $result');
      return result ?? false;
    } catch (e) {
      print('ERROR initializing notification service: $e');
      return false;
    }
  }

  static Future<bool> showNow(String title, String body) async {
    try {
      // Define the android notification details
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'basic_channel',
        'Basic Notifications',
        channelDescription: 'Simple notification channel',
        importance: Importance.high,
        priority: Priority.high,
      );

      // Create platform-specific notification details
      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      );

      // Show the notification with a random ID
      await _notifications.show(
        DateTime.now().millisecond,
        title,
        body,
        platformDetails,
      );

      return true;
    } catch (e) {
      print('Error showing notification: $e');
      return false;
    }
  }
}
