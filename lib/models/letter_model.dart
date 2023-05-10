class LetterModel {
  int serialNo;
  String letter;
  String braille;
  String description;
  String testAudioPath;
  String lessonAudioPath;
  String letterType;

  LetterModel({
    required this.serialNo,
    required this.letter,
    required this.braille,
    required this.description,
    required this.testAudioPath,
    required this.lessonAudioPath,
    required this.letterType,
  });

  factory LetterModel.fromJson(Map<String, dynamic> json) {
    return LetterModel(
      serialNo: json['serialNo'],
      letter: json['letter'] as String,
      braille: json['braille'] as String,
      description: json['description'] as String,
      testAudioPath: json['testAudioPath'] as String,
      lessonAudioPath: json['lessonAudioPath'] as String,
      letterType: json['letterType'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serialNo': serialNo,
      'letter': letter,
      'braille': braille,
      'description': description,
      'testAudioPath': testAudioPath,
      'lessonAudioPath': lessonAudioPath,
      'letterType': letterType,
    };
  }
}
