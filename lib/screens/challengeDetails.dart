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
  String status = "pending";

  @override
  void initState() {
    super.initState();
    fetchChallengeDetails();
  }

  Future<void> fetchChallengeDetails() async {
    try {
      final appState = Provider.of<AppState>(context, listen: false);

      final url = Uri.parse(
        Config.endpoint(
            "getUserChallengeById.php?user_id=${appState.currentUser!.id}&challenge_id=${widget.challengeId}"),
      );

      final response = await http.get(url);

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
      body: Column(
        children: [
          // ---------- Gradient Header ----------
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 24),
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
                // Back button
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 16),
                Text(
                  challenge!['title'] ?? "Challenge",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  challenge!['description'] ?? "",
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 16),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: Colors.white30,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "${(progress * 100).toInt()}% Completed",
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ---------- Challenge Info ----------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    InfoRow("Duration", "${challenge!['duration_days']} days",
                        Icons.timer),
                    const SizedBox(height: 12),
                    InfoRow("Status", status, Icons.flag),
                  ],
                ),
              ),
            ),
          ),

          const Spacer(),

          // ---------- Action Buttons ----------
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: status == "accepted" || status == "completed"
                        ? () => updateChallenge("accepted")
                        : null,
                    child: const Text(
                      "Done Today",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.deepPurple),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: status == "accepted" || status == "completed"
                        ? () => updateChallenge("cancelled")
                        : null,
                    child: const Text(
                      "Cancel Challenge",
                      style: TextStyle(fontSize: 16, color: Colors.deepPurple),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// ---------- InfoRow Widget ----------
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const InfoRow(this.label, this.value, this.icon, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.deepPurple),
        const SizedBox(width: 12),
        Text(
          "$label: ",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.black87),
          ),
        ),
      ],
    );
  }
}