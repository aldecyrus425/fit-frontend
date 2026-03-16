import 'dart:convert';
import 'package:fit_final/models/levelOptions.dart';
import 'package:fit_final/models/serverAddress.dart';
import 'package:fit_final/models/serviceOptions.dart';
import 'package:fit_final/widget/dropdownField.dart';
import 'package:fit_final/widget/inputField.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  String? selectedService;
  String? selectedLevel;

  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedService == null || selectedLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select service and level")),
      );
      return;
    }

    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse(Config.endpoint("registration.php"));

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
          "fitnessService": selectedService,
          "level": selectedLevel,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // Success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration successful!")),
        );
        Navigator.pop(context); // Go back to login
      } else {
        // Error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['error'] ?? "Registration failed")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
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
                image: AssetImage("assets/registration_background.jpeg"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          /// Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.75),
                  Colors.black.withOpacity(0.45),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          /// Form Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  const SizedBox(height: 80),
                  const Text(
                    "Create Account",
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Start your fitness journey",
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 40),

                  InputField(controller: _nameCtrl, hint: "Name", icon: Icons.person),
                  const SizedBox(height: 20),
                  InputField(controller: _emailCtrl, hint: "Email", icon: Icons.email),
                  const SizedBox(height: 20),
                  InputField(
                      controller: _passwordCtrl,
                      hint: "Password",
                      icon: Icons.lock,
                      obscure: true),
                  const SizedBox(height: 20),

                  dropdownField(
                    hint: "Select Fitness Service",
                    value: selectedService,
                    options: serviceOptions,
                    icon: Icons.fitness_center,
                    onChanged: (val) => setState(() => selectedService = val),
                  ),
                  const SizedBox(height: 20),
                  dropdownField(
                    hint: "Select Level",
                    value: selectedLevel,
                    options: levelOptions,
                    icon: Icons.bar_chart,
                    onChanged: (val) => setState(() => selectedLevel = val),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF5A623),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _isLoading ? null : _register,
                      child: _isLoading
                          ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                          : const Text(
                        "Register",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Already have an account? Login",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}