import 'dart:convert';
import 'package:fit_final/models/community.dart';
import 'package:fit_final/models/serverAddress.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import 'package:http/http.dart' as http;

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  List<CommunityChallenge> challenges = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchCommunityChallenges();
  }

  Future<void> fetchCommunityChallenges() async {
    try {
      final appState = Provider.of<AppState>(context, listen: false);

      final url = Uri.parse(Config.endpoint("getCommunity.php"));
      final response = await http.get(url);

      if (response.statusCode != 200) {
        setState(() {
          error = "Failed to fetch challenges (status ${response.statusCode})";
          isLoading = false;
        });
        return;
      }

      final List data = jsonDecode(response.body);

      final userChallengesUrl = Uri.parse(
        Config.endpoint("getUserChallenges.php?user_id=${appState.currentUser!.id}"),
      );
      final userResponse = await http.get(userChallengesUrl);

      List<String> excludedIds = [];
      if (userResponse.statusCode == 200) {
        final List userData = jsonDecode(userResponse.body);
        excludedIds = userData.map<String>((e) => e['challenge_id'].toString()).toList();
      }

      final filtered = data
          .where((e) =>
      e['category'] == appState.userFitnessService &&
          e['level'] == appState.userLevel &&
          !excludedIds.contains(e['id'].toString()))
          .map((e) => CommunityChallenge.fromJson(e))
          .toList();

      setState(() {
        challenges = filtered;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = "Error fetching challenges: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        body: Center(child: Text(error!)),
      );
    }

    if (challenges.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("No challenges for your level")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: challenges
              .map((challenge) => ModernChallengeCard(challenge: challenge))
              .toList(),
        ),
      ),
    );
  }
}

class ModernChallengeCard extends StatefulWidget {
  final CommunityChallenge challenge;
  const ModernChallengeCard({super.key, required this.challenge});

  @override
  State<ModernChallengeCard> createState() => _ModernChallengeCardState();
}

class _ModernChallengeCardState extends State<ModernChallengeCard> {
  bool isAccepted = false;
  bool isRejected = false;
  double progress = 0.0;

  @override
  void initState() {
    super.initState();
    progress = 0.0;
  }

  void acceptChallenge() async {
    setState(() {
      isAccepted = true;
      isRejected = false;
      progress = 0.0;
    });
    await updateChallengeBackend(status: "accepted", progress: 0.0);
  }

  void rejectChallenge() async {
    setState(() {
      isRejected = true;
    });
    await updateChallengeBackend(status: "rejected", progress: progress);
  }

  void doneToday() async {
    setState(() {
      progress += 1 / widget.challenge.durationDays;
      if (progress > 1) progress = 1;
    });
    String newStatus = progress >= 1.0 ? "completed" : "accepted";
    await updateChallengeBackend(status: newStatus, progress: progress);
  }

  void cancelChallenge() async {
    setState(() {
      isAccepted = false;
      progress = 0.0;
    });
    await updateChallengeBackend(status: "cancelled", progress: 0.0);
  }

  Future<void> updateChallengeBackend({
    required String status,
    required double progress,
  }) async {
    final appState = Provider.of<AppState>(context, listen: false);

    final url = Uri.parse(Config.endpoint("addUserChallenge.php"));
    final payload = {
      "user_id": appState.currentUser!.id,
      "challenge_id": widget.challenge.id,
      "status": status,
      "progress": progress,
    };

    try {
      final response = await http.post(url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(payload));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Challenge updated: $data");
      }
    } catch (e) {
      print("Error updating challenge: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isRejected) return const SizedBox();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade50, Colors.purpleAccent.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purpleAccent.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.challenge.title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.deepPurple)),
          const SizedBox(height: 6),
          Text(widget.challenge.description,
              style: const TextStyle(fontSize: 14, color: Colors.black87)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white30,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 6),
          Text("${(progress * 100).toInt()}%",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (!isAccepted) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: acceptChallenge,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Accept",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                          color: Colors.white
                        )),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: rejectChallenge,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.deepPurple,
                      side: BorderSide(color: Colors.deepPurple.shade400),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Reject",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            )
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: doneToday,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Done Today",
                        style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
                  ),
                ),

              ],
            )
          ]
        ],
      ),
    );
  }
}