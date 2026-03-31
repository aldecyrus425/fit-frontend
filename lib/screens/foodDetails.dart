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
      final url =
      Uri.parse(Config.endpoint("getFoodById.php?id=${widget.foodId}"));

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
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          // ---------- Modern SliverAppBar ----------
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(food!.name,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              background: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      food!.imageUrl,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.4),
                            Colors.transparent
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            backgroundColor: Colors.deepPurple,
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---------- Description ----------
                  Text(
                    food!.description,
                    style: const TextStyle(
                        fontSize: 16, color: Colors.black87, height: 1.4),
                  ),
                  const SizedBox(height: 24),

                  // ---------- Nutrition Card ----------
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 8))
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        NutritionTile('Calories', food!.calories.toString(),
                            'kcal'),
                        NutritionTile(
                            'Protein', food!.protein.toString(), 'g'),
                        NutritionTile('Carbs', food!.carbs.toString(), 'g'),
                        NutritionTile('Fat', food!.fat.toString(), 'g'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ---------- Meal Type ----------
                  Row(
                    children: [
                      const Icon(Icons.restaurant_menu,
                          color: Colors.deepPurple),
                      const SizedBox(width: 8),
                      Text(
                        "Meal Type: ${food!.mealType}",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ---------- Procedure ----------
                  const Text(
                    "Procedure",
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    food!.procedure ?? "No procedure available.",
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}