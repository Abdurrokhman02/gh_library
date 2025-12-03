// lib/models/user_model.dart
class User {
  final int id;
  final String name;
  final String email;
  final String profilePictureUrl;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.profilePictureUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Safe parsing ID
    final String userIdString = json['id']?.toString() ?? '0';

    return User(
      id: int.tryParse(userIdString) ?? 0, 
      name: json['name'] as String,
      email: json['email'] as String,
      profilePictureUrl: json['profile_picture_url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profile_picture_url': profilePictureUrl,
    };
  }
  
  User copyWith({
    String? name,
    String? email,
    String? profilePictureUrl,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
    );
  }
}