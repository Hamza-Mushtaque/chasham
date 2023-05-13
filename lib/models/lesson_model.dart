import 'letter_model.dart';

class LessonModel {
  String title;
  int serialNo;
  String description;
  String letterImg;
  String brailleImg;
  List<LetterModel> letters;
  String? lessonId;

  LessonModel(
      {required this.serialNo,
      required this.title,
      required this.description,
      required this.letterImg,
      required this.brailleImg,
      required this.letters,
      lessonId});

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
        serialNo: json['serialNo'],
        title: json['title'] as String,
        description: json['description'] as String,
        letterImg: json['letterImg'] as String,
        brailleImg: json['brailleImg'] as String,
        letters: (json['letters'] as List<dynamic>)
            .map((letterJson) => LetterModel.fromJson(letterJson))
            .toList(),
        lessonId: json['lessonId']);
  }

  Map<String, dynamic> toJson() {
    return {
      'serialNo': serialNo,
      'title': title,
      'description': description,
      'letterImg': letterImg,
      'brailleImg': brailleImg,
      'letters': letters.map((letter) => letter.toJson()).toList(),
    };
  }
}
