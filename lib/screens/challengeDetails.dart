import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/serverAddress.dart';
import 'package:http/http.dart' as http;

class ChallengeDetailScreen extends StatefulWidget {
  final String? challengeId;

  const ChallengeDetailScreen({super.key, required this.challengeId});

  @override
  State<ChallengeDetailScreen> createState() => _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends State<ChallengeDetailScreen> {
  Map<String, dynamic>? challenge;
  bool isLoading = true;
  String? error;

  double progress = 0.0;
  String status = "pending"; // default before fetching

  @override
  void initState() {
    super.initState();
    fetchChallengeDetails();
  }

  Future<void> fetchChallengeDetails() async {
    try {
      final appState = Provider.of<AppState>(context, listen: false);

      final url = Uri.parse(
        Config.endpoint("getUserChallengeById.php?user_id=${appState.currentUser!.id}&challenge_id=${widget.challengeId}"),
      );

      final response = await http.get(url);

      print("Fetching challenge for id=${widget.challengeId}");
      print("Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data.isEmpty) {
          setState(() {
            error = "Challenge not found";
            isLoading = false;
          });
          return;
        }

        setState(() {
          challenge = data[0];
          progress = double.tryParse(challenge!['progress'].toString()) ?? 0.0;
          status = challenge!['status'] ?? "pending";
          isLoading = false;
        });
      } else {
        setState(() {
          error = "Failed to fetch challenge (status ${response.statusCode})";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = "Error fetching challenge: $e";
        isLoading = false;
      });
    }
  }

  Future<void> updateChallenge(String newStatus) async {
    final appState = Provider.of<AppState>(context, listen: false);

    // If "done today", increment progress
    if (newStatus == "accepted") {
      progress += 1 / (challenge?['duration_days'] ?? 1);
      if (progress > 1) progress = 1;
      newStatus = progress >= 1 ? "completed" : "accepted";
    } else if (newStatus == "cancelled") {
      progress = 0.0;
    }

    final url = Uri.parse(Config.endpoint("addUserChallenge.php"));
    final payload = {
      "user_id": appState.currentUser!.id,
      "challenge_id": widget.challengeId,
      "status": newStatus,
      "progress": progress,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        setState(() {
          status = newStatus;
        });
      } else {
        print("Failed to update challenge. Status: ${response.statusCode}");
      }
    } catch (e) {
      print("Error updating challenge: $e");
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

    return Scaffold(
      appBar: AppBar(title: Text(challenge!['title'] ?? "Challenge")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              challenge!['title'] ?? "",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(challenge!['description'] ?? ""),
            const SizedBox(height: 16),
            Text("Duration: ${challenge!['duration_days']} days"),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              color: Colors.orangeAccent,
            ),
            const SizedBox(height: 8),
            Text("${(progress * 100).toInt()}%"),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: status == "accepted" || status == "completed"
                        ? () => updateChallenge("accepted")
                        : null,
                    child: const Text("Done Today"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: status == "accepted" || status == "completed"
                        ? () => updateChallenge("cancelled")
                        : null,
                    child: const Text("Cancel"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}