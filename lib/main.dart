import 'dart:io';

import 'package:fit_final/models/Init_Timezone.dart';
import 'package:fit_final/models/app_state.dart';
import 'package:fit_final/models/notification_service.dart';
import 'package:fit_final/screens/admin/adminDashboard.dart';
import 'package:fit_final/screens/login.dart';
import 'package:fit_final/screens/mainLayout.dart';
import 'package:fit_final/screens/register.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import './screens/UserRegistration/MainRegistrationScreen.dart';

final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Manila'));

  await NotificationService().initialize();

  if (Platform.isAndroid) {
    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    final isEnabled = await androidPlugin?.areNotificationsEnabled();
    print("🔍 Before request → Enabled: $isEnabled");

    final granted = await androidPlugin?.requestNotificationsPermission();

    print("📢 After request → Granted: $granted");
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/register': (context) => const RegistrationUser(),
        '/dashboard': (context) => const HomeScreen(),
        '/admindashboard': (context) => AdminDashboardScreen()
      },
    );
  }
}
