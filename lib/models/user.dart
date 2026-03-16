class User {
  final String id;
  String name;
  String email;
  String fitnessService; // e.g., "Yoga", "HIIT"
  String level;          // e.g., "Beginner", "Intermediate", "Advanced"
  bool isAdmin;          // <-- Add this

  User({
    required this.id,
    required this.name,
    required this.email,
    this.fitnessService = '',
    this.level = '',
    this.isAdmin = false, // default to false
  });

  // Optional: convert from/to JSON
  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    fitnessService: json['fitness_service'] ?? '',
    level: json['level'] ?? '',
    isAdmin: (json['is_admin'] ?? 0) == 1,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'fitnessService': fitnessService,
    'level': level,
    'is_admin': isAdmin ? 1 : 0,
  };
}