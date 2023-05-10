class UserModel {
  final String name;
  DateTime? dateOfBirth;
  final String profileImage;

  UserModel({required this.name, this.dateOfBirth, required this.profileImage});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'],
      dateOfBirth: json['dateOfBirth'] == null
          ? null
          : DateTime.parse(json['dateOfBirth'].toDate().toString()),
      profileImage: json['profileImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dateOfBirth':
          dateOfBirth == null ? null : dateOfBirth!.toIso8601String(),
      'profileImage': profileImage,
    };
  }
}
