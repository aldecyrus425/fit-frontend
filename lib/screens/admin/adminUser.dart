import 'dart:convert';

import 'package:fit_final/models/levelOptions.dart';
import 'package:fit_final/models/serverAddress.dart';
import 'package:fit_final/models/serviceOptions.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdminUserScreen extends StatefulWidget {
  const AdminUserScreen({super.key});

  @override
  State<AdminUserScreen> createState() => _AdminUserScreenState();
}

class _AdminUserScreenState extends State<AdminUserScreen> {

  @override
  void initState() {
    super.initState();
    fetchUsers(); // fetch non-admin users when screen loads
  }

  List<Map<String, String>> users = [];

  Future<void> fetchUsers() async {
    try {
      final url = Uri.parse(Config.endpoint("getUser.php"));
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);

        // Extract the users list
        final List<dynamic> data = jsonData['users'] ?? [];

        final filteredUsers = data
            .where((u) => u['is_admin'] == 0 || u['is_admin'] == null) // filter non-admin
            .map<Map<String, String>>((u) {
          return {
            "id": u['id'].toString(),
            "name": u['name'] ?? '-',
            "email": u['email'] ?? '-',
            "category": u['category'] ?? '-',
            "level": u['level'] ?? '-',
          };
        }).toList();

        setState(() {
          users = filteredUsers;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to fetch users")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching users: $e")),
      );
    }
  }

  Future<void> deleteUser(String userId, int index) async {
    try {
      final url = Uri.parse(Config.endpoint("deleteUser.php"));

      // Print the payload for debugging
      final payload = {"user_id": userId};
      print("Sending delete payload: $payload");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      final data = jsonDecode(response.body);
      print("Response from server: $data");

      if (response.statusCode == 200 && data['message'] != null) {
        setState(() {
          users.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User deleted successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['error'] ?? "Failed to delete user")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  void showAddUserDialog() {
    final _formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    String selectedCategory = serviceOptions[0];
    String selectedLevel = levelOptions[0];

    bool _isLoading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Add New User"),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Name
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: "Name"),
                        validator: (value) =>
                        value == null || value.isEmpty ? "Enter name" : null,
                      ),
                      const SizedBox(height: 8),
                      // Email
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(labelText: "Email"),
                        validator: (value) =>
                        value == null || value.isEmpty ? "Enter email" : null,
                      ),
                      const SizedBox(height: 8),
                      // Password
                      TextFormField(
                        controller: passwordController,
                        decoration: const InputDecoration(labelText: "Password"),
                        obscureText: true,
                        validator: (value) =>
                        value == null || value.isEmpty ? "Enter password" : null,
                      ),
                      const SizedBox(height: 8),
                      // Confirm Password
                      TextFormField(
                        controller: confirmPasswordController,
                        decoration:
                        const InputDecoration(labelText: "Confirm Password"),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Confirm password";
                          } else if (value != passwordController.text) {
                            return "Passwords do not match";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      // Category Dropdown
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: const InputDecoration(labelText: "Category"),
                        items: serviceOptions
                            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (val) => setStateDialog(() => selectedCategory = val!),
                      ),
                      const SizedBox(height: 8),
                      // Level Dropdown
                      DropdownButtonFormField<String>(
                        value: selectedLevel,
                        decoration: const InputDecoration(labelText: "Level"),
                        items: levelOptions
                            .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                            .toList(),
                        onChanged: (val) => setStateDialog(() => selectedLevel = val!),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  onPressed: _isLoading
                      ? null
                      : () async {
                    if (!_formKey.currentState!.validate()) return;

                    setStateDialog(() => _isLoading = true);

                    try {
                      final url = Uri.parse(Config.endpoint("registration.php"));
                      final response = await http.post(
                        url,
                        headers: {"Content-Type": "application/json"},
                        body: jsonEncode({
                          "name": nameController.text.trim(),
                          "email": emailController.text.trim(),
                          "password": passwordController.text.trim(),
                          "fitnessService": selectedCategory,
                          "level": selectedLevel,
                        }),
                      );

                      final data = jsonDecode(response.body);

                      if (response.statusCode == 201) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("User added successfully")),
                        );

                        // Optionally refresh your users list
                        setState(() {
                          users.add({
                            "name": nameController.text.trim(),
                            "email": emailController.text.trim(),
                            "category": selectedCategory,
                            "level": selectedLevel,
                          });
                        });

                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(data['error'] ?? "Failed to add user")),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: $e")),
                      );
                    } finally {
                      setStateDialog(() => _isLoading = false);
                    }
                  },
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Add User"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Users"),
        backgroundColor: Colors.orange,
      ),
      backgroundColor: Colors.grey[100],

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];

          return Card(
            key: ValueKey(user["id"]), // Unique identifier for the card
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.orange,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(
                user["name"]!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                  "${user["email"]!}\nCategory: ${user["category"] ?? '-'} | Level: ${user["level"] ?? '-'}"),
              isThreeLine: true,
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  final userId = user["id"];
                  if (userId == null || userId.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("User ID not found!")),
                    );
                    return;
                  }
                  showDeleteDialog(index, userId);
                },
              ),
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: showAddUserDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  void showDeleteDialog(int index, String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Delete User"),
          content: const Text(
            "Are you sure you want to delete this user?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                deleteUser(id, index);
                Navigator.pop(context);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}