import 'package:fit_final/models/app_state.dart';
import 'package:fit_final/screens/admin/adminDashboard.dart';
import 'package:fit_final/screens/login.dart';
import 'package:fit_final/screens/mainLayout.dart';
import 'package:fit_final/screens/register.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
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
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => const HomeScreen(),
        '/admindashboard': (context) => AdminDashboardScreen()
      },
    );
  }
}
