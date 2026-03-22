class UserModel {
  String name;
  String? profileImagePath;
  int streakCount;
  DateTime? lastActiveDate;

  UserModel({
    required this.name,
    this.profileImagePath,
    this.streakCount = 0,
    this.lastActiveDate,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'profileImagePath': profileImagePath,
        'streakCount': streakCount,
        'lastActiveDate': lastActiveDate?.toIso8601String(),
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        name: json['name'] as String,
        profileImagePath: json['profileImagePath'] as String?,
        streakCount: json['streakCount'] as int? ?? 0,
        lastActiveDate: json['lastActiveDate'] != null
            ? DateTime.parse(json['lastActiveDate'] as String)
            : null,
      );
}
