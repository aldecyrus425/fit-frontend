import 'dart:convert';

import 'package:fit_final/models/serverAddress.dart';
import 'package:flutter/material.dart';
import 'createUserModel.dart';
import 'AccountStep.dart';
import 'AgeStep.dart';
import 'HeightStep.dart';
import 'LevelStep.dart';
import 'ServiceStep.dart';
import 'SummaryStep.dart';
import 'WeightStep.dart';
import 'package:http/http.dart' as http;


class RegistrationUser extends StatefulWidget {
  const RegistrationUser({super.key});

  @override
  State<RegistrationUser> createState() => _RegistrationUserState();
}

class _RegistrationUserState extends State<RegistrationUser> {
  final PageController _controller = PageController();
  final RegisterData data = RegisterData();

  int currentPage = 0;

  void next() {
    if (currentPage < 6) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      submit();
    }
  }

  void back() {
    if (currentPage > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void submit() async {
    print("FINAL DATA:");
    print(data.name);
    print(data.email);
    print(data.password);
    print(data.service);
    print(data.level);
    print(data.age);
    print(data.weight);
    print(data.height);

    final name = data.name;
    final email = data.email;
    final password = data.password;
    final selectedService = data.service;
    final selectedLevel = data.level;

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration successful!")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['error'] ?? "Registration failed")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _controller,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (i) => setState(() => currentPage = i),
        children: [
          AccountStep(data),
          ServiceStep(data),
          LevelStep(data),
          AgeStep(data),
          WeightStep(data),
          HeightStep(data),
          SummaryStep(data),
        ],
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔥 Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: (currentPage + 1) / 7,
                  minHeight: 6,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation(Colors.deepPurple),
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  // 🔙 Back Button (Modern Ghost Button)
                  if (currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: back,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Colors.deepPurple),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          "Back",
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

                  if (currentPage > 0) const SizedBox(width: 12),

                  // 👉 Continue / Finish Button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 4,
                        shadowColor: Colors.deepPurple.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        currentPage == 6 ? "Finish" : "Continue",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
