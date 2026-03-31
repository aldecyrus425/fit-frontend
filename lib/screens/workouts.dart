import 'package:fit_final/screens/exerciseDetails.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/exercise.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<AppState>(context, listen: false).loadExercisesFromApi();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final List<Exercise> exercises = appState.userExercises;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: exercises.isEmpty
          ? const Center(
        child: Text(
          "No workouts for your level",
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      )
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: ListView.builder(
          itemCount: exercises.length,
          itemBuilder: (context, index) {
            final exercise = exercises[index];
            final videoId = YoutubePlayer.convertUrlToId(exercise.videoUrl);

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ExerciseDetailScreen(
                      exerciseId: exercise.id,
                    ),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // ---------------- Thumbnail or Fallback Icon ----------------
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: videoId != null
                            ? Image.network(
                          'https://img.youtube.com/vi/$videoId/0.jpg',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                            : Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF6A1B9A),
                                Color(0xFFAB47BC)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.fitness_center,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // ---------------- Exercise info ----------------
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exercise.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${exercise.description}\n'
                                  'Duration: ${exercise.duration} min • Sets: ${exercise.sets} • Reps: ${exercise.reps}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}