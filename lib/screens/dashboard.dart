import 'dart:convert';

import 'package:fit_final/models/serverAddress.dart';
import 'package:fit_final/screens/exerciseDetails.dart';
import 'package:fit_final/screens/foodDetails.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/exercise.dart';
import '../models/food.dart';
import 'package:http/http.dart' as http;

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {


    Future<List<dynamic>> fetchUserChallenges(String userId) async {
      final url = Uri.parse(
        Config.endpoint("getUserActiveChallenge.php?user_id=$userId"),
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to load challenges");
      }
    }



    // Access AppState
    final state = Provider.of<AppState>(context);
    final userId = state.currentUser?.id;

    Future<List<Food>> fetchFoods() async {
      final url = Uri.parse(Config.endpoint("getFood.php"));

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        return data.map((e) => Food(
          id: e['id'],
          name: e['name'],
          description: e['description'],
          imageUrl: Config.endpoint(e['imageUrl']),
          calories: int.tryParse(e['calories'].toString()) ?? 0,
          protein: double.tryParse(e['protein'].toString()) ?? 0,
          carbs: double.tryParse(e['carbs'].toString()) ?? 0,
          fat: double.tryParse(e['fat'].toString()) ?? 0,
          mealType: e['mealType'],
          category: e['category'],
          level: e['level'],
        )).toList();
      } else {
        throw Exception("Failed to load foods");
      }
    }

    final foods = state.foods.isNotEmpty
        ? state.foods
        : [
      Food(
        id: '1',
        name: 'Grilled Chicken Salad',
        description: 'High protein salad with fresh veggies',
        imageUrl: 'https://example.com/chicken_salad.jpg',
        calories: 350,
        protein: 30,
        carbs: 20,
        fat: 10,
        mealType: 'Lunch',
      ),
      Food(
        id: '2',
        name: 'Oatmeal with Fruits',
        description: 'Healthy breakfast with fiber and vitamins',
        imageUrl: 'https://example.com/oatmeal.jpg',
        calories: 250,
        protein: 8,
        carbs: 45,
        fat: 5,
        mealType: 'Breakfast',
      ),
    ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good morning, ${state.userName}!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),

            // ---------- Exercises Section ----------
            Text("Today's Challenges", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),

            FutureBuilder<List<dynamic>>(
              future: fetchUserChallenges(userId!),
              builder: (context, snapshot) {

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Text("Failed to load challenges");
                }

                final challenges = snapshot.data ?? [];

                if (challenges.isEmpty) {
                  return const Text("No active challenges");
                }

                return Column(
                  children: challenges.map((ch) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(ch['title']),
                        subtitle: Text(
                          "${ch['description']} • ${ch['duration_days']} days",
                        ),
                        trailing: ElevatedButton(
                          child: const Text("Start"),
                          onPressed: () {
                            // open challenge details
                          },
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 24),

            // ---------- Recommended Foods Section ----------
            Text("Recommended Food", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),

            FutureBuilder<List<Food>>(
              future: fetchFoods(),
              builder: (context, snapshot) {

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Text("Failed to load foods");
                }

                final allFoods = snapshot.data ?? [];

                // 🔥 Filter foods based on user category and level
                final filteredFoods = allFoods.where((food) =>
                food.category == state.userFitnessService &&
                    food.level == state.userLevel
                ).toList();

                if (filteredFoods.isEmpty) {
                  return const Text("No recommended foods");
                }

                return Column(
                  children: filteredFoods.map((food) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(
                          food.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          food.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FoodDetailScreen(foodId: food.id),
                              ),
                            );
                          },
                          child: const Text("Show"),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}