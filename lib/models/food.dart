
class Food {
  final String id;
  final String name;
  final String description;
  final String imageUrl; // image of the food
  final int calories;
  final double protein; // grams
  final double carbs;   // grams
  final double fat;     // grams
  final String mealType; // e.g., "Breakfast", "Lunch", "Dinner", "Snack"
  bool recommended;
  final String? procedure;
  final String category; // e.g., "Strength", "Cardio"
  final String level;

  Food({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.mealType,
    this.recommended = true,
    this.procedure,
    this.category = '',
    this.level = '',
  });

  factory Food.fromJson(Map<String, dynamic> json) => Food(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    imageUrl: json['imageUrl'],
    calories: json['calories'],
    protein: json['protein']?.toDouble() ?? 0,
    carbs: json['carbs']?.toDouble() ?? 0,
    fat: json['fat']?.toDouble() ?? 0,
    mealType: json['mealType'],
    recommended: json['recommended'] ?? true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'imageUrl': imageUrl,
    'calories': calories,
    'protein': protein,
    'carbs': carbs,
    'fat': fat,
    'mealType': mealType,
    'recommended': recommended,
  };
}
