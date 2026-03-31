import 'dart:convert';
import 'package:fit_final/models/serverAddress.dart';
import 'package:fit_final/widget/infoTile.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/exercise.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final String exerciseId;

  const ExerciseDetailScreen({super.key, required this.exerciseId});

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  Exercise? exercise;

  @override
  void initState() {
    super.initState();
    fetchExercise();
  }

  Future<void> fetchExercise() async {
    final url = Uri.parse(
      Config.endpoint("getExerciseById.php?id=${widget.exerciseId}"),
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      setState(() {
        exercise = Exercise(
          id: data['id'],
          name: data['name'],
          description: data['description'],
          videoUrl: data['videoUrl'],
          category: data['category'],
          duration: data['duration'],
          sets: data['sets'],
          reps: data['reps'],
          difficulty: data['difficulty'],
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (exercise == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final videoId = YoutubePlayer.convertUrlToId(exercise!.videoUrl) ?? '';

    final controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          elevation: 0,
          flexibleSpace: Container(
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
          ),
          title: Text(
            exercise!.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- Video ----------
            YoutubePlayerBuilder(
              player: YoutubePlayer(controller: controller),
              builder: (context, player) {
                return Container(
                  width: double.infinity,
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: player,
                );
              },
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---------- Exercise Name ----------
                  Text(
                    exercise!.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ---------- Description ----------
                  Text(
                    exercise!.description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ---------- Info Tiles ----------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: InfoTile(
                          'Duration',
                          '${exercise!.duration} min',
                          Icons.timer,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InfoTile(
                          'Difficulty',
                          exercise!.difficulty,
                          Icons.fitness_center,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InfoTile(
                          'Category',
                          exercise!.category,
                          Icons.category,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ---------- Sets & Reps ----------
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            const Text(
                              "Sets",
                              style: TextStyle(
                                  fontSize: 14, color: Colors.black54),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              exercise!.sets.toString(),
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Text(
                              "Reps",
                              style: TextStyle(
                                  fontSize: 14, color: Colors.black54),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              exercise!.reps.toString(),
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
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