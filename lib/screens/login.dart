import 'dart:convert';
import 'package:fit_final/models/app_state.dart';
import 'package:fit_final/models/serverAddress.dart';
import 'package:fit_final/models/user.dart';
import 'package:fit_final/widget/inputField.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _loading = false;

  Future<void> _login() async {
    final url = Config.endpoint("login.php");

    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    try {
      final uri = Uri.parse(url);
      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userData = data['user'];

        final user = User(
          id: userData['id'],
          name: userData['name'],
          email: userData['email'],
          fitnessService: userData['fitness_service'],
          level: userData['level'],
          isAdmin: userData['is_admin'] == 1,
        );

        // Save to AppState
        final appState = Provider.of<AppState>(context, listen: false);
        appState.setUser(user);

        // Navigate
        if (user.isAdmin) {
          Navigator.pushReplacementNamed(context, "/admindashboard");
        } else {
          Navigator.pushReplacementNamed(context, "/dashboard");
        }
      } else {
        final errorData = jsonDecode(response.body);
        _showError(errorData['error'] ?? 'Login failed');
      }
    } catch (e) {
      _showError("Unable to connect to server");
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/login-background.jpeg"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          /// Dark Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.black.withOpacity(0.4),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          /// Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  const SizedBox(height: 80),
                  const Text(
                    "Welcome Back",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Login to continue",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 40),

                  /// Email Field
                  InputField(
                    controller: _emailCtrl,
                    hint: "Email",
                    icon: Icons.email,
                  ),
                  const SizedBox(height: 20),

                  /// Password Field
                  InputField(
                    controller: _passwordCtrl,
                    hint: "Password",
                    icon: Icons.lock,
                    obscure: true,
                  ),
                  const SizedBox(height: 30),

                  /// Login Button
                  SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF5A623),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _loading ? null : _login,
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  /// Register Link
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "/register");
                      },
                      child: const Text(
                        "Don't have an account? Register",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}