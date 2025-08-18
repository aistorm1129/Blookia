import 'package:hive/hive.dart';

part 'user.g.dart';

enum UserRole { admin, professional, reception }

@HiveType(typeId: 1)
class User extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  UserRole role;

  @HiveField(3)
  String tenantId;

  @HiveField(4)
  String email;

  @HiveField(5)
  String? photoUrl;

  @HiveField(6)
  bool isActive;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  DateTime? lastLoginAt;

  User({
    required this.id,
    required this.name,
    required this.role,
    required this.tenantId,
    required this.email,
    this.photoUrl,
    this.isActive = true,
    required this.createdAt,
    this.lastLoginAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role.toString(),
      'tenantId': tenantId,
      'email': email,
      'photoUrl': photoUrl,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      role: UserRole.values.firstWhere(
        (e) => e.toString() == json['role'],
        orElse: () => UserRole.reception,
      ),
      tenantId: json['tenantId'],
      email: json['email'],
      photoUrl: json['photoUrl'],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      lastLoginAt: json['lastLoginAt'] != null 
          ? DateTime.parse(json['lastLoginAt']) 
          : null,
    );
  }
}

