import 'dart:convert';

import 'package:fit_final/models/serverAddress.dart';
import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../models/food.dart';
import '../models/user.dart';
import 'package:http/http.dart' as http;

class AppState extends ChangeNotifier {
  // ---------------- User ----------------
  User? _currentUser;
  User? get currentUser => _currentUser;

  void setUser(User user) {
    _currentUser = user;
    notifyListeners(); // UI updates automatically
  }

  // Convenience getters for global user info
  String get userName => _currentUser?.name ?? '';
  String get userEmail => _currentUser?.email ?? '';
  String get userFitnessService => _currentUser?.fitnessService ?? '';
  String get userLevel => _currentUser?.level ?? '';

  bool get isLoggedIn => _currentUser != null;

  Future<void> loadExercisesFromApi() async {
    try {
      final url = Uri.parse(Config.endpoint("getExercise.php"));
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        _exercises = data.map((e) => Exercise(
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

        notifyListeners();
      } else {
        throw Exception("Failed to fetch exercises");
      }
    } catch (e) {
      print("Error loading exercises: $e");
    }
  }

  // ---------------- Exercises ----------------
  List<Exercise> _exercises = [];
  List<Exercise> get exercises => _exercises;

  /// Exercises filtered based on logged-in user's category and level
  List<Exercise> get userExercises {
    if (_currentUser == null) return [];
    return _exercises.where((ex) =>
    ex.category == _currentUser!.fitnessService &&
        ex.difficulty == _currentUser!.level
    ).toList();
  }

  // Foods filtered based on user's category & level
  List<Food> get userFoods {
    if (_currentUser == null) return [];
    return _foods.where((f) =>
    f.category == _currentUser!.fitnessService &&
        f.level == _currentUser!.level
    ).toList();
  }


  void updateExercise(Exercise exercise) {
    final index = _exercises.indexWhere((e) => e.id == exercise.id);
    if (index != -1) {
      _exercises[index] = exercise;
      notifyListeners();
      // TODO: update database
    }
  }

  void cancelExercise(String id) {
    final index = _exercises.indexWhere((e) => e.id == id);
    if (index != -1) {
      _exercises[index].canceled = true;
      notifyListeners();
      // TODO: update database
    }
  }

  // ---------------- Foods ----------------


  Future<void> loadFoodsFromApi() async {
    try {
      final url = Uri.parse(Config.endpoint("getFood.php"));
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        _foods = data.map((item) => Food(
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

        notifyListeners();
      } else {
        print("Failed to fetch foods. Status: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching foods: $e");
    }
  }


  List<Food> _foods = [];
  List<Food> get foods => _foods;

  void toggleFoodRecommendation(String id) {
    final index = _foods.indexWhere((f) => f.id == id);
    if (index != -1) {
      _foods[index].recommended = !_foods[index].recommended;
      notifyListeners();
      // TODO: update database
    }
  }
}

