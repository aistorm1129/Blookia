import 'package:hive/hive.dart';

part 'patient.g.dart';

@HiveType(typeId: 10)
class Patient extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String docType;

  @HiveField(3)
  String docNumber;

  @HiveField(4)
  String? phone;

  @HiveField(5)
  String? email;

  @HiveField(6)
  String? address;

  @HiveField(7)
  Map<String, String>? socials;

  @HiveField(8)
  String? photoUrl;

  @HiveField(9)
  List<String> internalNotes;

  @HiveField(10)
  DateTime? dateOfBirth;

  @HiveField(11)
  String? emergencyContact;

  @HiveField(12)
  List<String> allergies;

  @HiveField(13)
  List<String> medications;

  @HiveField(14)
  DateTime createdAt;

  @HiveField(15)
  DateTime updatedAt;

  @HiveField(16)
  int loyaltyPoints;

  Patient({
    required this.id,
    required this.name,
    required this.docType,
    required this.docNumber,
    this.phone,
    this.email,
    this.address,
    this.socials,
    this.photoUrl,
    required this.internalNotes,
    this.dateOfBirth,
    this.emergencyContact,
    required this.allergies,
    required this.medications,
    required this.createdAt,
    required this.updatedAt,
    this.loyaltyPoints = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'docType': docType,
      'docNumber': docNumber,
      'phone': phone,
      'email': email,
      'address': address,
      'socials': socials,
      'photoUrl': photoUrl,
      'internalNotes': internalNotes,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'emergencyContact': emergencyContact,
      'allergies': allergies,
      'medications': medications,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'loyaltyPoints': loyaltyPoints,
    };
  }

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      name: json['name'],
      docType: json['docType'],
      docNumber: json['docNumber'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      socials: json['socials']?.cast<String, String>(),
      photoUrl: json['photoUrl'],
      internalNotes: List<String>.from(json['internalNotes'] ?? []),
      dateOfBirth: json['dateOfBirth'] != null 
          ? DateTime.parse(json['dateOfBirth']) 
          : null,
      emergencyContact: json['emergencyContact'],
      allergies: List<String>.from(json['allergies'] ?? []),
      medications: List<String>.from(json['medications'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      loyaltyPoints: json['loyaltyPoints'] ?? 0,
    );
  }
}