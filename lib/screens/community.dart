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

      final url = Uri.parse(
        Config.endpoint("getCommunity.php"),
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        // Filter based on user's category & level
        final filtered = data.where((e) =>
        e['category'] == appState.userFitnessService &&
            e['level'] == appState.userLevel
        ).map((e) => CommunityChallenge(
          id: e['id'],
          title: e['title'],
          description: e['description'],
          category: e['category'],
          level: e['level'],
          durationDays: e['durationDays'],
        )).toList();

        setState(() {
          challenges = filtered;
          isLoading = false;
        });
      } else {
        setState(() {
          error = "Failed to fetch challenges (status ${response.statusCode})";
          isLoading = false;
        });
      }
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
          children: challenges.map((challenge) {
            return ChallengeCard(
              challenge: challenge,
            );
          }).toList(),
        ),
      ),
    );
  }
}
class ChallengeCard extends StatefulWidget {
  final CommunityChallenge challenge;

  const ChallengeCard({super.key, required this.challenge});

  @override
  State<ChallengeCard> createState() => _ChallengeCardState();
}

class _ChallengeCardState extends State<ChallengeCard> {
  bool isAccepted = false;
  bool isRejected = false;
  double progress = 0.0;

  @override
  void initState() {
    super.initState();
    progress = 0.0; // or pass from widget.challenge if saved in db
  }

  void acceptChallenge() {
    setState(() {
      isAccepted = true;
      isRejected = false;
    });
  }

  void rejectChallenge() {
    setState(() {
      isRejected = true;
    });
  }

  void doneToday() {
    setState(() {
      progress += 1 / widget.challenge.durationDays;
      if (progress > 1) progress = 1;
    });
  }

  void cancelChallenge() {
    setState(() {
      isAccepted = false;
      progress = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isRejected) return const SizedBox();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.orange.shade50, Colors.orange.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.challenge.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(widget.challenge.description),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              color: Colors.orangeAccent,
              minHeight: 6,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 10),
            Text(
              '${(progress * 100).toInt()}%',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (!isAccepted) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: acceptChallenge,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        "Accept",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: rejectChallenge,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        side: const BorderSide(color: Colors.orange),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        "Reject",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
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
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        "Done Today",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: cancelChallenge,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        side: const BorderSide(color: Colors.orange),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ],
        ),
      ),
    );
  }
}