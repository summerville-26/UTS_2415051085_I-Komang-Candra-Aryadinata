class UserProfile {
  const UserProfile({
    required this.userId,
    required this.name,
    required this.about,
    this.createdAt,
    this.updatedAt,
  });

  final String userId;
  final String name;
  final String about;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['user_id'] as String,
      name: json['name'] as String? ?? '',
      about: json['about'] as String? ?? '',
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'about': about,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
  }
}
