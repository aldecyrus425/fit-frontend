

import 'dart:convert';

import 'package:fit_final/models/community.dart';
import 'package:fit_final/models/levelOptions.dart';
import 'package:fit_final/models/serverAddress.dart';
import 'package:fit_final/models/serviceOptions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class AdminCommunityScreen extends StatefulWidget {
  const AdminCommunityScreen({super.key});

  @override
  State<AdminCommunityScreen> createState() => _AdminCommunityScreenState();
}

class _AdminCommunityScreenState extends State<AdminCommunityScreen> {

  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
    fetchCommunityChallenges(); // now it will populate your list
  }

  Future<void> fetchCommunityChallenges() async {
    try {
      final url = Uri.parse(Config.endpoint("getCommunity.php"));
      final response = await http.get(url);

      print("fetching challenges: ${response.body}");

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          challenges = data.map((e) => CommunityChallenge(
            id: e['id'],
            title: e['title'],
            description: e['description'],
            category: e['category'],
            level: e['level'],
            durationDays: e['durationDays'],
          )).toList();
        });
      } else {
        throw Exception("Failed to fetch challenges");
      }
    } catch (e) {
      print("Error fetching challenges: $e");
    }
  }

  Future<CommunityChallenge?> addCommunityChallenge({
    required String title,
    required String description,
    required String category,
    required String level,
    required int durationDays,
    String? notifyTime, // new optional parameter in HH:mm format
  }) async {
    try {
      final url = Uri.parse(Config.endpoint("addCommunityChallenge.php"));
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "title": title,
          "description": description,
          "category": category,
          "level": level,
          "durationDays": durationDays,
          "notifyTime": notifyTime,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['challenge_id'] != null) {
        return CommunityChallenge(
          id: data['challenge_id'],
          title: title,
          description: description,
          category: category,
          level: level,
          durationDays: durationDays,
          notifyTime: notifyTime, // store locally as well
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['error'] ?? "Failed to add challenge")),
        );
        return null;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
      return null;
    }
  }

  List<CommunityChallenge> challenges = [];

  Future<void> deleteCommunityChallenge(String id) async {
    try {
      final url = Uri.parse(Config.endpoint("deleteChallenge.php"));
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id": id}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['message'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Challenge deleted successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['error'] ?? "Failed to delete challenge")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }


  void showAddChallengeDialog() {
    final _formKey = GlobalKey<FormState>();
    String title = '';
    String description = '';
    String category = serviceOptions[0];
    String level = levelOptions[0];
    int durationDays = 7; // default

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text("Add New Challenge"),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    TextFormField(
                      decoration: const InputDecoration(labelText: "Title"),
                      validator: (value) =>
                      value == null || value.isEmpty ? "Enter title" : null,
                      onSaved: (value) => title = value!,
                    ),
                    const SizedBox(height: 8),

                    // Description
                    TextFormField(
                      decoration: const InputDecoration(labelText: "Description"),
                      validator: (value) =>
                      value == null || value.isEmpty ? "Enter description" : null,
                      onSaved: (value) => description = value!,
                    ),
                    const SizedBox(height: 8),

                    // Duration
                    TextFormField(
                      initialValue: durationDays.toString(),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Duration (days)"),
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Enter duration";
                        final v = int.tryParse(value);
                        if (v == null || v <= 0) return "Enter a valid number";
                        return null;
                      },
                      onSaved: (value) => durationDays = int.parse(value!),
                    ),
                    const SizedBox(height: 8),

                    TextFormField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "Notification Time",
                        suffixIcon: const Icon(Icons.access_time),
                      ),
                      controller: TextEditingController(
                        text: selectedTime != null
                            ? selectedTime!.format(context)
                            : "",
                      ),
                      onTap: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (picked != null) {
                          setStateDialog(() => selectedTime = picked);
                        }
                      },
                      validator: (value) =>
                      selectedTime == null ? "Pick a time for notification" : null,
                    ),

                    const SizedBox(height: 8),

                    // Category Dropdown
                    DropdownButtonFormField<String>(
                      value: category,
                      decoration: const InputDecoration(labelText: "Category"),
                      items: serviceOptions
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (val) => setStateDialog(() => category = val!),
                    ),
                    const SizedBox(height: 8),

                    // Level Dropdown
                    DropdownButtonFormField<String>(
                      value: level,
                      decoration: const InputDecoration(labelText: "Level"),
                      items: levelOptions
                          .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                          .toList(),
                      onChanged: (val) => setStateDialog(() => level = val!),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    // Call backend
                    final success = await addCommunityChallenge(
                      title: title,
                      description: description,
                      category: category,
                      level: level,
                      durationDays: durationDays,
                      notifyTime: selectedTime != null
                          ? "${selectedTime!.hour.toString().padLeft(2,'0')}:${selectedTime!.minute.toString().padLeft(2,'0')}"
                          : null,
                    );

                    if (success != null) {
                      setState(() {
                        challenges.add(success); // add to local list
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Challenge added successfully")),
                      );
                    }
                  }
                },
                child: const Text("Add Challenge"),
              ),
            ],
          );
        });
      },
    );
  }

  void showDeleteDialog(int index, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Challenge"),
        content: const Text("Are you sure you want to delete this challenge?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context); // close the dialog first
              await deleteCommunityChallenge(id);
              setState(() {
                challenges.removeAt(index);
              });
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      AppBar(title: const Text("Manage Community Challenges"), backgroundColor: Colors.orange),
      backgroundColor: Colors.grey[100],
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: challenges.length,
        itemBuilder: (context, index) {
          final challenge = challenges[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: Text(challenge.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                  "${challenge.category} | ${challenge.level} | ${challenge.durationDays} days"),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => showDeleteDialog(index, challenges[index].id),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: showAddChallengeDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}