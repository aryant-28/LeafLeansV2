import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/plant_reminder.dart';

class ScheduledNotificationService {
  static final ScheduledNotificationService _instance = ScheduledNotificationService._internal();
  factory ScheduledNotificationService() => _instance;
  ScheduledNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();

    const settings = InitializationSettings(android: android, iOS: ios);
    await _notifications.initialize(settings,
        onDidReceiveNotificationResponse: (details) {
      print('Tapped notification: ${details.payload}');
    });
  }

  Future<void> scheduleReminder(PlantReminder reminder) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, reminder.time.hour, reminder.time.minute);
    if (scheduledDate.isBefore(now)) scheduledDate = scheduledDate.add(const Duration(days: 1));

    final scheduledTime = tz.TZDateTime.from(scheduledDate, tz.local);

    await _notifications.zonedSchedule(
      reminder.id.hashCode,
      'Reminder: ${reminder.plantName}',
      reminder.notes.isEmpty ? 'Time to check your plant!' : reminder.notes,
      scheduledTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'reminder_channel',
          'Plant Reminders',
          channelDescription: 'Reminds you to take care of your plants',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
      payload: reminder.id,
    );
  }

  Future<void> cancelReminder(String id) async {
    await _notifications.cancel(id.hashCode);
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
