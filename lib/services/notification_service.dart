import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initNotifiCation() async {
    tz.initializeTimeZones(); // Khởi tạo timezone

    AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');

    InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static scheduledNotificationAsync() async {
    await _flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'scheduled title',
        'theme changes 5 seconds ago',
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
        const NotificationDetails(
          android: AndroidNotificationDetails(
              'your channel id', 'your channel name'),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle);
  }

  static Future<void> scheduleNotification(
      DateTime scheduledDateTime, String title, String body) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'task_due_channel',
      'Task Due Notifications',
      channelDescription: 'Notifications for tasks that are due',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    // await _flutterLocalNotificationsPlugin.show(
    //   0,
    //   title,
    //   body,
    //   notificationDetails,
    //   payload: 'task_due',
    // );

    final tz.TZDateTime tzDateTime = tz.TZDateTime.from(
      scheduledDateTime,
      tz.local,
    );

    debugPrint('Scheduled notification time (local): $tzDateTime');
    debugPrint('Scheduled Current local time: ${tz.TZDateTime.now(tz.local)}');

    // Kiểm tra nếu thời gian đã qua
    if (tzDateTime.isBefore(tz.TZDateTime.now(tz.local))) {
      debugPrint("Scheduled time is in the past.");
      return;
    }

    // Lên lịch thông báo với giờ địa phương
    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        title,
        body,
        tzDateTime,
        notificationDetails,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'task_due',
        androidScheduleMode: AndroidScheduleMode.exact,
      );
      debugPrint('Notification scheduled successfully');
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }
}
