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
        Config.endpoint("getExerciseById.php?id=${widget.exerciseId}")
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

    final videoId =
        YoutubePlayer.convertUrlToId(exercise!.videoUrl) ?? '';

    final controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(exercise!.name),
        backgroundColor: Colors.orangeAccent,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            YoutubePlayerBuilder(
              player: YoutubePlayer(controller: controller),
              builder: (context, player) {
                return SizedBox(
                  width: double.infinity,
                  height: 220,
                  child: player,
                );
              },
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    exercise!.name,
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    exercise!.description,
                    style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      InfoTile('Duration',
                          '${exercise!.duration} min',
                          Icons.timer),
                      InfoTile('Difficulty',
                          exercise!.difficulty,
                          Icons.fitness_center),
                      InfoTile('Category',
                          exercise!.category,
                          Icons.category),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start Workout'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        backgroundColor: Colors.orangeAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(12),
                        ),
                        textStyle:
                        const TextStyle(fontSize: 18),
                      ),
                      onPressed: () {},
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