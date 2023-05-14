class ProgressModel {
  final String userId;
  final List<int> lessonCompleted;
  final List<int> exercisesCompleted;
  final String rank;

  ProgressModel({
    required this.userId,
    required this.lessonCompleted,
    required this.exercisesCompleted,
    required this.rank,
  });

  factory ProgressModel.fromJson(Map<String, dynamic> json) {
    return ProgressModel(
      userId: json['userId'] ?? '',
      lessonCompleted: List<int>.from(json['lessonCompleted'] ?? []),
      exercisesCompleted: List<int>.from(json['exercisesCompleted'] ?? []),
      rank: _validateRank(json['rank']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'lessonCompleted': lessonCompleted,
      'exercisesCompleted': exercisesCompleted,
      'rank': rank,
    };
  }

  static String _validateRank(String rank) {
    final validRanks = [
      'Beginner',
      'Basic',
      'Intermediate',
      'Advanced',
      'Expert'
    ];
    if (validRanks.contains(rank)) {
      return rank;
    } else {
      return 'Beginner';
    }
  }
}
