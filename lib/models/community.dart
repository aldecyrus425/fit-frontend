class CommunityChallenge {
  final String id;
  final String title;
  final String description;
  final String category;
  final String level;
  final int durationDays;
  double progress;
  String status;
  String? notifyTime;

  CommunityChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.level,
    required this.durationDays,
    this.progress = 0.0,
    this.status = "not_started",
    this.notifyTime,
  });

  factory CommunityChallenge.fromJson(Map<String, dynamic> json) {
    return CommunityChallenge(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      level: json['level'],
      durationDays: json['durationDays'],
      progress: double.tryParse(json['progress']?.toString() ?? '0') ?? 0.0,
      status: json['status'] ?? 'not_started',
      notifyTime: json['notifyTime'], // read from JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'level': level,
      'durationDays': durationDays,
      'progress': progress,
      'status': status,
      'notifyTime': notifyTime, // send to backend
    };
  }
}