import 'dart:convert';

import 'package:fit_final/models/notification_service.dart';
import 'package:fit_final/models/serverAddress.dart';
import 'package:fit_final/screens/challengeDetails.dart';
import 'package:fit_final/screens/foodDetails.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/food.dart';
import 'package:http/http.dart' as http;

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  // ✅ FIX 1: Moved OUTSIDE build
  Future<void> scheduleChallengeNotifications(List<dynamic> challenges) async {
    for (var ch in challenges) {
      final String? timeString = ch['time_notify'];

      if (timeString == null || timeString.isEmpty) continue;

      try {
        final parts = timeString.split(":");
        final now = DateTime.now();

        DateTime scheduledDate = DateTime(
          now.year,
          now.month,
          now.day,
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );

        // ✅ If time already passed → schedule for next day
        if (scheduledDate.isBefore(now)) {
          scheduledDate = scheduledDate.add(const Duration(days: 1));
        }

        await NotificationService().scheduleNotification(
          id: ch['challenge_id'].hashCode,
          title: "Challenge Reminder",
          body: ch['title'],
          scheduledDate: scheduledDate,
        );

        print("✅ Scheduled for: $scheduledDate");

      } catch (e) {
        print("❌ Error: $e");
      }
    }
  }

  // ✅ FIX 5: Moved OUTSIDE build
  Future<List<dynamic>> fetchUserChallenges(String userId) async {
    print("🔥 Fetching challenges for user: $userId");

    final url = Uri.parse(
      Config.endpoint("getUserActiveChallenge.php?user_id=$userId"),
    );

    final response = await http.get(url);

    print("📡 Response: ${response.body}");

    if (response.statusCode == 200) {
      final challenges = jsonDecode(response.body);

      print("✅ Parsed challenges: $challenges");

      await scheduleChallengeNotifications(challenges);

      return challenges;
    } else {
      print("❌ Failed API call");
      throw Exception("Failed to load challenges");
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final userId = state.currentUser?.id;

    if (userId == null) {
      return const Center(child: Text("User not logged in"));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              /// 🔥 HEADER (MODERN)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple, Colors.purpleAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      "Welcome back 👋",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      state.userName,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// 🔥 CHALLENGES SECTION
                    _sectionTitle("Today's Challenges"),

                    const SizedBox(height: 10),

                    FutureBuilder<List<dynamic>>(
                      future: fetchUserChallenges(userId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return const Text("Failed to load challenges");
                        }

                        final challenges = snapshot.data ?? [];

                        if (challenges.isEmpty) {
                          return _emptyCard("No active challenges");
                        }

                        return Column(
                          children: challenges.map((ch) {
                            return _modernCard(
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(12),
                                title: Text(
                                  ch['title'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    "${ch['description']} • ${ch['duration_days']} days",
                                  ),
                                ),
                                trailing: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepPurple,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text("Start",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: () {
                                    final challengeId =
                                    ch['challenge_id']?.toString();

                                    if (challengeId == null ||
                                        challengeId.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content:
                                            Text("Invalid challenge data")),
                                      );
                                      return;
                                    }

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            ChallengeDetailScreen(
                                                challengeId: challengeId),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    /// 🔥 FOOD SECTION
                    _sectionTitle("Recommended Food"),

                    const SizedBox(height: 10),

                    FutureBuilder<List<Food>>(
                      future: fetchFoods(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return const Text("Failed to load foods");
                        }

                        final allFoods = snapshot.data ?? [];

                        final filteredFoods = allFoods.where((food) =>
                        food.category == state.userFitnessService &&
                            food.level == state.userLevel).toList();

                        if (filteredFoods.isEmpty) {
                          return _emptyCard("No recommended foods");
                        }

                        return Column(
                          children: filteredFoods.map((food) {
                            return _modernCard(
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(12),
                                title: Text(
                                  food.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    food.description,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                trailing: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepPurple,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            FoodDetailScreen(foodId: food.id),
                                      ),
                                    );
                                  },
                                  child:
                                  const Text(
                                      "Show",
                                    style: TextStyle(
                                      color: Colors.white
                                    ),
                                  ),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _modernCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _emptyCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}