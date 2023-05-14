class ExerciseModel {
  String title;
  int serialNo;
  String description;
  int lastLetter;
  int noOfQs;
  final String exerciseType;

  ExerciseModel(
      {required this.serialNo,
      required this.title,
      required this.description,
      required this.lastLetter,
      required this.noOfQs,
      required this.exerciseType});

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
        serialNo: json['serialNo'] as int,
        title: json['title'] as String,
        description: json['description'] as String,
        lastLetter: json['lastLetter'] as int,
        noOfQs: json['noOfQs'] as int,
        exerciseType: _validateType(json['exerciseType'] as String));
  }

  Map<String, dynamic> toJson() {
    return {
      'serialNo': serialNo,
      'title': title,
      'description': description,
      'lastLetter': lastLetter,
      'noOfQs': noOfQs,
      'exerciseType': exerciseType
    };
  }

  static String _validateType(String type) {
    final validTypes = ['Normal', 'Advanced'];
    if (validTypes.contains(type)) {
      return type;
    } else {
      return 'Normal';
    }
  }
}
