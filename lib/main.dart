import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/services/notification_service.dart';
import 'screens/task_list_screen.dart';

import 'package:permission_handler/permission_handler.dart';

void requestNotificationPermission() async {
  var status = await Permission.notification.request();
  if (status.isGranted) {
    print('Notification permission granted');
  } else {
    print('Notification permission denied');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.initNotifiCation();
  requestNotificationPermission();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: TaskListScreen(),
    );
  }
}
