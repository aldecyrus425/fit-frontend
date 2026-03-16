import 'package:fit_final/models/app_state.dart';
import 'package:fit_final/screens/foodDetails.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/food.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      Provider.of<AppState>(context, listen: false).loadFoodsFromApi();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final foods = appState.userFoods;

    return Scaffold(
      body: foods.isEmpty
          ? const Center(child: Text('No nutrition plans available for your level.'))
          : ListView.builder(
        itemCount: foods.length,
        itemBuilder: (context, index) {

          final food = foods[index];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: Image.network(
                food.imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
              title: Text(food.name),
              subtitle: Text(
                '${food.description}\n'
                    'Calories: ${food.calories} kcal • Protein: ${food.protein}g • '
                    'Carbs: ${food.carbs}g • Fat: ${food.fat}g',
              ),
              isThreeLine: true,
              trailing: Icon(
                food.recommended ? Icons.check_circle : Icons.restaurant,
                color: food.recommended ? Colors.green : Colors.orangeAccent,
              ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FoodDetailScreen(foodId: food.id),
                    ),
                  );
                }
            ),
          );
        },
      ),
    );
  }
}