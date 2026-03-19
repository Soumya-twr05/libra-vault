// lib/models/user_model.dart

class UserModel {
  final String id;
  final String name;
  final String email;
  final String passwordHash;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'passwordHash': passwordHash,
        'createdAt': createdAt.toIso8601String(),
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        passwordHash: json['passwordHash'],
        createdAt: DateTime.parse(json['createdAt']),
      );
}