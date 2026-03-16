class Exercise {
  final String id;
  final String name;
  final String description;
  final String videoUrl; // link to tutorial video
  final String category; // e.g., "Strength", "Cardio", "Core"
  final int duration;    // in minutes
  final int sets;
  final int reps;
  bool completed;
  bool canceled;
  final String difficulty; // "Beginner", "Intermediate", "Advanced"

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.videoUrl,
    required this.category,
    required this.duration,
    this.sets = 1,
    this.reps = 0,
    this.completed = false,
    this.canceled = false,
    required this.difficulty,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    videoUrl: json['videoUrl'],
    category: json['category'],
    duration: json['duration'],
    sets: json['sets'] ?? 1,
    reps: json['reps'] ?? 0,
    completed: json['completed'] ?? false,
    canceled: json['canceled'] ?? false,
    difficulty: json['difficulty'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'videoUrl': videoUrl,
    'category': category,
    'duration': duration,
    'sets': sets,
    'reps': reps,
    'completed': completed,
    'canceled': canceled,
    'difficulty': difficulty,
  };
}