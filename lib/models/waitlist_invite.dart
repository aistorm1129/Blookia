import 'package:hive/hive.dart';

part 'waitlist_invite.g.dart';

@HiveType(typeId: 8)
class WaitlistInvite extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String appointmentId;

  @HiveField(2)
  String patientId;

  @HiveField(3)
  DateTime expiresAt;

  @HiveField(4)
  bool accepted;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime? respondedAt;

  @HiveField(7)
  int loyaltyPointsAwarded;

  WaitlistInvite({
    required this.id,
    required this.appointmentId,
    required this.patientId,
    required this.expiresAt,
    this.accepted = false,
    required this.createdAt,
    this.respondedAt,
    this.loyaltyPointsAwarded = 0,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Duration get timeRemaining => expiresAt.difference(DateTime.now());

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'appointmentId': appointmentId,
      'patientId': patientId,
      'expiresAt': expiresAt.toIso8601String(),
      'accepted': accepted,
      'createdAt': createdAt.toIso8601String(),
      'respondedAt': respondedAt?.toIso8601String(),
      'loyaltyPointsAwarded': loyaltyPointsAwarded,
    };
  }

  factory WaitlistInvite.fromJson(Map<String, dynamic> json) {
    return WaitlistInvite(
      id: json['id'],
      appointmentId: json['appointmentId'],
      patientId: json['patientId'],
      expiresAt: DateTime.parse(json['expiresAt']),
      accepted: json['accepted'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      respondedAt: json['respondedAt'] != null 
          ? DateTime.parse(json['respondedAt']) 
          : null,
      loyaltyPointsAwarded: json['loyaltyPointsAwarded'] ?? 0,
    );
  }
}