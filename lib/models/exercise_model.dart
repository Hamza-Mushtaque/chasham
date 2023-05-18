class ExerciseModel {
  String title;
  int serialNo;
  String description;
  int firstLetter;
  int lastLetter;
  int noOfQs;
  String exerciseAudioPath;
  final String exerciseType;

  ExerciseModel(
      {required this.serialNo,
      required this.title,
      required this.description,
      required this.lastLetter,
      required this.firstLetter,
      required this.noOfQs,
      required this.exerciseAudioPath,
      required this.exerciseType});

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
        serialNo: json['serialNo'] as int,
        title: json['title'] as String,
        description: json['description'] as String,
        lastLetter: json['lastLetter'] as int,
        firstLetter: json['firstLetter'] as int,
        noOfQs: json['noOfQs'] as int,
        exerciseAudioPath: json['exerciseAudioPath'] as String,
        exerciseType: _validateType(json['exerciseType'] as String));
  }

  Map<String, dynamic> toJson() {
    return {
      'serialNo': serialNo,
      'title': title,
      'description': description,
      'lastLetter': lastLetter,
      'firstLetter': firstLetter,
      'noOfQs': noOfQs,
      'exerciseType': exerciseType,
      'exerciseAudioPath': exerciseAudioPath
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
