import 'dart:convert';
import 'package:fit_final/models/serverAddress.dart';
import 'package:flutter/material.dart';
import '../models/food.dart';
import 'package:http/http.dart' as http;
import 'package:fit_final/widget/nutrition.dart';

class FoodDetailScreen extends StatefulWidget {
  final String foodId;

  const FoodDetailScreen({super.key, required this.foodId});

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {

  Food? food;

  @override
  void initState() {
    super.initState();
    fetchFood();
  }

  Future<void> fetchFood() async {
    try {
      final url = Uri.parse(
          Config.endpoint("getFoodById.php?id=${widget.foodId}")
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          food = Food(
            id: data['id'],
            name: data['name'],
            description: data['description'],
            imageUrl: Config.endpoint(data['imageUrl']),
            calories: int.tryParse(data['calories'].toString()) ?? 0,
            protein: double.tryParse(data['protein'].toString()) ?? 0,
            carbs: double.tryParse(data['carbs'].toString()) ?? 0,
            fat: double.tryParse(data['fat'].toString()) ?? 0,
            mealType: data['mealType'],
            category: data['category'],
            level: data['level'],
            procedure: data['procedure'],
          );

        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {

    if (food == null) {
      return const Scaffold(
        body: Center(child: Text("Food not found")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(food!.name),
        backgroundColor: Colors.orangeAccent,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ---------- Image ----------
            Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(food!.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ---------- Name ----------
                  Text(
                    food!.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ---------- Description ----------
                  Text(
                    food!.description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ---------- Nutrition ----------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      NutritionTile('Calories', food!.calories.toString(), 'kcal'),
                      NutritionTile('Protein', food!.protein.toString(), 'g'),
                      NutritionTile('Carbs', food!.carbs.toString(), 'g'),
                      NutritionTile('Fat', food!.fat.toString(), 'g'),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ---------- Meal Type ----------
                  Text(
                    "Meal Type: ${food!.mealType}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ---------- Procedure ----------
                  const Text(
                    "Procedure",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    food!.procedure ?? "No procedure available.",
                    style: const TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}