import 'dart:io';

import 'package:fit_final/models/Init_Timezone.dart';
import 'package:fit_final/models/app_state.dart';
import 'package:fit_final/models/notification_service.dart';
import 'package:fit_final/screens/UserRegistration/GetStartedStep.dart';
import 'package:fit_final/screens/admin/adminDashboard.dart';
import 'package:fit_final/screens/login.dart';
import 'package:fit_final/screens/mainLayout.dart';
import 'package:fit_final/screens/profile_update.dart';
import 'package:fit_final/screens/register.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import './screens/UserRegistration/MainRegistrationScreen.dart';

final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ---------------- Notification Permission ----------------
  if (Platform.isAndroid) {
    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    final isEnabled = await androidPlugin?.areNotificationsEnabled();
    print("🔍 Before request → Enabled: $isEnabled");

    final granted = await androidPlugin?.requestNotificationsPermission();
    print("📢 After request → Granted: $granted");
  }

  // ---------------- Check First Launch ----------------
  final prefs = await SharedPreferences.getInstance();
  final bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

  // If first launch, set it to false for next time
  if (isFirstLaunch) {
    await prefs.setBool('isFirstLaunch', false);
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MyApp(isFirstLaunch: isFirstLaunch),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isFirstLaunch;

  const MyApp({super.key, required this.isFirstLaunch});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // ---------------- Conditional Initial Route ----------------
      initialRoute: isFirstLaunch ? '/getStarted' : '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/register': (context) => const RegistrationUser(),
        '/dashboard': (context) => const HomeScreen(),
        '/admindashboard': (context) => AdminDashboardScreen(),
        '/getStarted': (context) => const GetStartedScreen(),
      },
    );
  }
}