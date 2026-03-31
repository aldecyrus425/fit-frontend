import 'dart:convert';

import 'package:fit_final/models/app_state.dart';
import 'package:fit_final/models/levelOptions.dart';
import 'package:fit_final/models/serverAddress.dart';
import 'package:fit_final/models/serviceOptions.dart';
import 'package:fit_final/models/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  String? userId;

  // Controllers
  final fullnameCtrl = TextEditingController(text: "Juan Dela Cruz");
  final emailCtrl = TextEditingController(text: "juan@email.com");
  final ageCtrl = TextEditingController(text: "25");
  final heightCtrl = TextEditingController(text: "170");
  final weightCtrl = TextEditingController(text: "65");

  // Dropdown Values
  String? selectedGender = "Male";
  String? selectedService = serviceOptions[0];
  String? selectedLevel = levelOptions[0];

  final List<String> genderOptions = ["Male", "Female"];

  Future<void> loadUser() async {
    if (userId == null) return;

    try {
      final url = Uri.parse(Config.endpoint("get_user.php"));

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "id": userId,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final user = data['user'];

        setState(() {
          // 🔹 TextFields
          fullnameCtrl.text = user['name'] ?? '';
          emailCtrl.text = user['email'] ?? '';
          ageCtrl.text = user['age'].toString();
          heightCtrl.text = user['height'].toString();
          weightCtrl.text = user['weight'].toString();

          // 🔹 Dropdowns (SAFE)
          selectedGender = genderOptions.contains(user['gender'])
              ? user['gender']
              : genderOptions[0];

          selectedLevel = levelOptions.contains(user['level'])
              ? user['level']
              : levelOptions[0];

          selectedService = serviceOptions.contains(user['service'])
              ? user['service']
              : serviceOptions[0];
        });
      } else {
        print(data['error']);
      }
    } catch (e) {
      print("Load User Error: $e");
    }
  }



  @override
  void initState() {
    super.initState();

    final state = context.read<AppState>();
    userId = state.currentUser?.id;

    loadUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Update Profile"),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildInput(fullnameCtrl, "Full Name", Icons.person),

              _buildInput(emailCtrl, "Email", Icons.email),

              _buildInput(ageCtrl, "Age", Icons.cake, isNumber: true),

              /// ✅ GENDER DROPDOWN (NEW)
              _buildDropdown(
                label: "Gender",
                value: selectedGender,
                items: genderOptions,
                icon: Icons.person_outline,
                onChanged: (val) => setState(() => selectedGender = val),
              ),

              _buildInput(heightCtrl, "Height (cm)", Icons.height,
                  isNumber: true),

              _buildInput(weightCtrl, "Weight (kg)", Icons.monitor_weight,
                  isNumber: true),

              _buildDropdown(
                label: "Level",
                value: selectedLevel,
                items: levelOptions,
                icon: Icons.fitness_center,
                onChanged: (val) => setState(() => selectedLevel = val),
              ),

              _buildDropdown(
                label: "Services",
                value: selectedService,
                items: serviceOptions,
                icon: Icons.miscellaneous_services,
                onChanged: (val) => setState(() => selectedService = val),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _updateProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Update Profile"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 Input Field
  Widget _buildInput(
      TextEditingController controller, String label, IconData icon,
      {bool isPassword = false, bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType:
        isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
          const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  /// 🔹 Dropdown (Reusable)
  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        value: items.contains(value) ? value : null, // 🔥 SAFE
        onChanged: onChanged,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
          const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        items: items
            .map((item) => DropdownMenuItem(
          value: item,
          child: Text(item),
        ))
            .toList(),
      ),
    );
  }

  /// 🔹 UPDATE API
  void _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        final url = Uri.parse(Config.endpoint("update_profile.php"));

        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "id": userId,
            "fullname": fullnameCtrl.text,
            "email": emailCtrl.text,
            "age": ageCtrl.text,
            "height": heightCtrl.text,
            "weight": weightCtrl.text,
            "level": selectedLevel,
            "service": selectedService,
            "gender": selectedGender, // ✅ ADDED
          }),
        );

        final data = jsonDecode(response.body);

        if (response.statusCode == 200) {
          final updatedUser = User(
            id: userId!,
            name: fullnameCtrl.text,
            email: emailCtrl.text,
            fitnessService: selectedService ?? '',
            level: selectedLevel ?? ''
          );

          Provider.of<AppState>(context, listen: false).setUser(updatedUser);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile Updated!")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['error'] ?? "Update failed")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }
}