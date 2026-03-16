import 'package:fit_final/screens/exerciseDetails.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/exercise.dart';

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
      appBar: AppBar(title: const Text("Workouts")),
      body: exercises.isEmpty
          ? const Center(child: Text("No workouts for your level"))
          : ListView.builder(
        itemCount: exercises.length,
        itemBuilder: (context, index) {

          final exercise = exercises[index];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(exercise.name),
              subtitle: Text(
                '${exercise.description}\n'
                    'Duration: ${exercise.duration} min • Sets: ${exercise.sets} • Reps: ${exercise.reps}',
              ),
              isThreeLine: true,
              trailing: const Icon(
                Icons.fitness_center,
                color: Colors.orangeAccent,
              ),
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
            ),
          );
        },
      ),
    );
  }
}