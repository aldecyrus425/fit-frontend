import 'package:fit_final/models/exercise.dart';
import 'package:fit_final/models/levelOptions.dart';
import 'package:fit_final/models/serverAddress.dart';
import 'package:fit_final/models/serviceOptions.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminExerciseScreen extends StatefulWidget {
  const AdminExerciseScreen({super.key});

  @override
  State<AdminExerciseScreen> createState() => _AdminExerciseScreenState();
}

class _AdminExerciseScreenState extends State<AdminExerciseScreen> {

  @override
  void initState() {
    super.initState();
    fetchExercises();
  }


  Future<void> addExerciseToServer({
    required String name,
    required String description,
    required String videoUrl,
    required String category,
    required int duration,
    required int sets,
    required int reps,
    required String difficulty,
  }) async {
    try {
      final url = Uri.parse(
          Config.endpoint("addExercise.php"));
      final payload = {
        "name": name,
        "description": description,
        "videoUrl": videoUrl,
        "category": category,
        "duration": duration,
        "sets": sets,
        "reps": reps,
        "difficulty": difficulty,
      };
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      final data = jsonDecode(response.body);
      print("Server response: $data");

      if (response.statusCode == 200 && data['message'] != null) {
        // Successfully added
        print("Exercise added successfully!");
      } else {
        throw Exception(data['error'] ?? "Failed to add exercise");
      }
    } catch (e) {
      print("Error adding exercise: $e");
      rethrow;
    }
  }

  Future<void> fetchExercises() async {
    try {
      final url = Uri.parse(Config.endpoint("getExercise.php")); // your endpoint
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          exercises = data.map((e) => Exercise(
            id: e['id'],
            name: e['name'],
            description: e['description'],
            videoUrl: e['videoUrl'],
            category: e['category'],
            duration: e['duration'],
            sets: e['sets'],
            reps: e['reps'],
            difficulty: e['difficulty'],
          )).toList();
        });
      } else {
        throw Exception("Failed to fetch exercises");
      }
    } catch (e) {
      print("Error fetching exercises: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load exercises: $e")),
      );
    }
  }
  
  List<Exercise> exercises = [];

  Future<void> deleteExercise(int index, String id) async {
    try {
      final url = Uri.parse(Config.endpoint("deleteExercise.php"));
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id": id}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['message'] != null) {
        setState(() {
          exercises.removeAt(index); // remove locally
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Exercise deleted successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['error'] ?? "Failed to delete exercise")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }


  void showAddExerciseDialog() {
    final _formKey = GlobalKey<FormState>();

    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final videoUrlController = TextEditingController();
    final durationController = TextEditingController();
    final setsController = TextEditingController();
    final repsController = TextEditingController();

    String selectedCategory = serviceOptions[0];
    String selectedDifficulty = levelOptions[0];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text("Add New Exercise"),
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
                      decoration: const InputDecoration(labelText: "Exercise Name"),
                      validator: (value) =>
                      value == null || value.isEmpty ? "Enter exercise name" : null,
                    ),
                    const SizedBox(height: 8),

                    // Description
                    TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(labelText: "Description"),
                    ),
                    const SizedBox(height: 8),

                    // Video URL
                    TextFormField(
                      controller: videoUrlController,
                      decoration: const InputDecoration(labelText: "Video URL"),
                    ),
                    const SizedBox(height: 8),

                    // Duration
                    TextFormField(
                      controller: durationController,
                      decoration: const InputDecoration(labelText: "Duration (minutes)"),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                      value == null || value.isEmpty ? "Enter duration" : null,
                    ),
                    const SizedBox(height: 8),

                    // Sets
                    TextFormField(
                      controller: setsController,
                      decoration: const InputDecoration(labelText: "Sets"),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),

                    // Reps
                    TextFormField(
                      controller: repsController,
                      decoration: const InputDecoration(labelText: "Reps"),
                      keyboardType: TextInputType.number,
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

                    // Difficulty Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedDifficulty,
                      decoration: const InputDecoration(labelText: "Difficulty"),
                      items: levelOptions
                          .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                          .toList(),
                      onChanged: (val) => setStateDialog(() => selectedDifficulty = val!),
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
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final newExercise = Exercise(
                      id: const Uuid().v4(),
                      name: nameController.text,
                      description: descriptionController.text,
                      videoUrl: videoUrlController.text,
                      category: selectedCategory,
                      duration: int.parse(durationController.text),
                      sets: setsController.text.isNotEmpty ? int.parse(setsController.text) : 1,
                      reps: repsController.text.isNotEmpty ? int.parse(repsController.text) : 0,
                      difficulty: selectedDifficulty,
                    );

                    // Add locally
                    setState(() {
                      exercises.add(newExercise);
                    });

                    // Send to server
                    try {
                      await addExerciseToServer(
                        name: newExercise.name,
                        description: newExercise.description,
                        videoUrl: newExercise.videoUrl,
                        category: newExercise.category,
                        duration: newExercise.duration,
                        sets: newExercise.sets,
                        reps: newExercise.reps,
                        difficulty: newExercise.difficulty,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Exercise added successfully")),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Failed to add exercise: $e")),
                      );
                      // Optionally remove locally if server failed
                      setState(() {
                        exercises.remove(newExercise);
                      });
                    }

                    Navigator.pop(context);
                  }
                },
                child: const Text("Add Exercise"),
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
        title: const Text("Delete Exercise"),
        content: const Text("Are you sure you want to delete this exercise?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context); // close dialog first
              await deleteExercise(index, id); // call delete function
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
      appBar: AppBar(title: const Text("Manage Exercises"), backgroundColor: Colors.orange),
      backgroundColor: Colors.grey[100],
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: exercises.length,
        itemBuilder: (context, index) {
          final exercise = exercises[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: Text(exercise.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("${exercise.category} | ${exercise.difficulty}"),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => showDeleteDialog(index, exercises[index].id),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: showAddExerciseDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}