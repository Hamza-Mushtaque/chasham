import 'letter_model.dart';

class LessonModel {
  String title;
  String description;
  String letterImg;
  String brailleImg;
  List<LetterModel> letters;
  String? lessonId;

  LessonModel({
    required this.title,
    required this.description,
    required this.letterImg,
    required this.brailleImg,
    required this.letters,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      title: json['title'] as String,
      description: json['description'] as String,
      letterImg: json['letterImg'] as String,
      brailleImg: json['brailleImg'] as String,
      letters: (json['letters'] as List<dynamic>)
          .map((letterJson) => LetterModel.fromJson(letterJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'letterImg': letterImg,
      'brailleImg': brailleImg,
      'letters': letters.map((letter) => letter.toJson()).toList(),
    };
  }
}
