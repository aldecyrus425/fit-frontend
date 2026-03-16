import 'dart:convert';
import 'dart:io';
import 'package:fit_final/models/food.dart';
import 'package:fit_final/models/levelOptions.dart';
import 'package:fit_final/models/serverAddress.dart';
import 'package:fit_final/models/serviceOptions.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class AdminFoodScreen extends StatefulWidget {
  const AdminFoodScreen({super.key});

  @override
  State<AdminFoodScreen> createState() => _AdminFoodScreenState();
}

class _AdminFoodScreenState extends State<AdminFoodScreen> {

  @override
  void initState() {
    super.initState();
    fetchFoods();
  }

  Future<void> fetchFoods() async {
    try {
      final url = Uri.parse(Config.endpoint("getFood.php"));
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          foods = data.map((item) => Food(
            id: item['id'],
            name: item['name'],
            description: item['description'],
            imageUrl: Config.endpoint(item['imageUrl']),
            calories: int.tryParse(item['calories'].toString()) ?? 0,
            protein: double.tryParse(item['protein'].toString()) ?? 0,
            carbs: double.tryParse(item['carbs'].toString()) ?? 0,
            fat: double.tryParse(item['fat'].toString()) ?? 0,
            mealType: item['mealType'],
            category: item['category'],
            level: item['level'],
          )).toList();
        });
      } else {
        print("Failed to fetch foods. Status: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching foods: $e");
    }
  }

  Future<void> addFood({
    required String name,
    required String description,
    required int calories,
    required double protein,
    required double carbs,
    required double fat,
    required String mealType,
    required String category,
    required String level,
    required File imageFile,
  }) async {
    try {
      var url = Uri.parse(Config.endpoint("addFood.php"));

      var request = http.MultipartRequest('POST', url);

      // Add text fields
      request.fields['name'] = name;
      request.fields['description'] = description;
      request.fields['calories'] = calories.toString();
      request.fields['protein'] = protein.toString();
      request.fields['carbs'] = carbs.toString();
      request.fields['fat'] = fat.toString();
      request.fields['mealType'] = mealType;
      request.fields['category'] = category;
      request.fields['level'] = level;

      // Add the image file
      request.files.add(
        await http.MultipartFile.fromPath(
          'image', // must match $_FILES['image'] in PHP
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      );

      // Send the request
      var response = await request.send();

      // Read the response
      var responseBody = await response.stream.bytesToString();
      print("Server response: $responseBody");

      if (response.statusCode == 200) {
        print("Food added successfully!");
      } else {
        print("Failed to add food. Status: ${response.statusCode}");
      }
    } catch (e) {
      print("Error adding food: $e");
    }
  }

  Future<void> deleteFood(String id) async {
    try {
      final url = Uri.parse(Config.endpoint("deleteFoodByID.php"));

      // Print the payload for debugging
      final payload = {"foodID": id};
      print("Sending delete payload: $payload");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      final data = jsonDecode(response.body);
      print("Response from server: $data");

      if (response.statusCode == 200 && data['message'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Food deleted successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['error'] ?? "Failed to delete food")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  List<Food> foods = [];

  final List<String> mealTypes = ["Breakfast", "Lunch", "Dinner", "Snack"];

  void showAddFoodDialog() {
    final _formKey = GlobalKey<FormState>();
    File? selectedImage;

    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final caloriesController = TextEditingController();
    final proteinController = TextEditingController();
    final carbsController = TextEditingController();
    final fatController = TextEditingController();

    String selectedCategory = serviceOptions[0];
    String selectedLevel = levelOptions[0];
    String selectedMealType = mealTypes[0];

    Future pickImage() async {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          selectedImage = File(image.path);
        });
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text("Add New Food"),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Image Picker
                    GestureDetector(
                      onTap: () async {
                        final image = await ImagePicker()
                            .pickImage(source: ImageSource.gallery);
                        if (image != null) {
                          setStateDialog(() {
                            selectedImage = File(image.path);
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: selectedImage != null
                            ? Image.file(selectedImage!, fit: BoxFit.cover)
                            : const Center(
                          child: Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Name
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: "Food Name"),
                      validator: (value) =>
                      value == null || value.isEmpty ? "Enter food name" : null,
                    ),
                    const SizedBox(height: 8),

                    // Description
                    TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(labelText: "Description"),
                      validator: (value) =>
                      value == null || value.isEmpty ? "Enter description" : null,
                    ),
                    const SizedBox(height: 8),

                    // Calories
                    TextFormField(
                      controller: caloriesController,
                      decoration: const InputDecoration(labelText: "Calories"),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                      value == null || value.isEmpty ? "Enter calories" : null,
                    ),
                    const SizedBox(height: 8),

                    // Protein
                    TextFormField(
                      controller: proteinController,
                      decoration: const InputDecoration(labelText: "Protein (g)"),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                      value == null || value.isEmpty ? "Enter protein" : null,
                    ),
                    const SizedBox(height: 8),

                    // Carbs
                    TextFormField(
                      controller: carbsController,
                      decoration: const InputDecoration(labelText: "Carbs (g)"),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                      value == null || value.isEmpty ? "Enter carbs" : null,
                    ),
                    const SizedBox(height: 8),

                    // Fat
                    TextFormField(
                      controller: fatController,
                      decoration: const InputDecoration(labelText: "Fat (g)"),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                      value == null || value.isEmpty ? "Enter fat" : null,
                    ),
                    const SizedBox(height: 8),

                    // Category
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(labelText: "Category"),
                      items: serviceOptions
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (val) => setStateDialog(() => selectedCategory = val!),
                    ),
                    const SizedBox(height: 8),

                    // Level
                    DropdownButtonFormField<String>(
                      value: selectedLevel,
                      decoration: const InputDecoration(labelText: "Level"),
                      items: levelOptions
                          .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                          .toList(),
                      onChanged: (val) => setStateDialog(() => selectedLevel = val!),
                    ),
                    const SizedBox(height: 8),

                    // Meal Type
                    DropdownButtonFormField<String>(
                      value: selectedMealType,
                      decoration: const InputDecoration(labelText: "Meal Type"),
                      items: mealTypes
                          .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                          .toList(),
                      onChanged: (val) => setStateDialog(() => selectedMealType = val!),
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
                onPressed: () {

                  if (_formKey.currentState!.validate() && selectedImage != null) {
                    addFood(
                        name: nameController.text,
                        description: descriptionController.text,
                        calories: int.parse(caloriesController.text),
                        protein: double.parse(proteinController.text),
                        carbs: double.parse(carbsController.text),
                        fat: double.parse(fatController.text),
                        mealType: selectedMealType,
                        category: selectedCategory,
                        level: selectedLevel,
                        imageFile: selectedImage!
                    );
                    Navigator.pop(context);
                  }
                  else if (selectedImage == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please select an image")),
                    );
                  }
                },
                child: const Text("Add Food"),
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
        title: const Text("Delete Food"),
        content: const Text("Are you sure you want to delete this food?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                deleteFood(id);
                foods.removeAt(index);
              });
              Navigator.pop(context);
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
      appBar: AppBar(title: const Text("Manage Foods"), backgroundColor: Colors.orange),
      backgroundColor: Colors.grey[100],
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: foods.length,
        itemBuilder: (context, index) {
          final food = foods[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: food.imageUrl.isNotEmpty
                  ? Image.network(
                food.imageUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.fastfood, size: 50, color: Colors.orange),
              )
                  : const Icon(Icons.fastfood, size: 50, color: Colors.orange),
              title: Text(food.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("${food.calories} kcal | ${food.category} | ${food.level}"),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => showDeleteDialog(index, foods[index].id),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: showAddFoodDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}