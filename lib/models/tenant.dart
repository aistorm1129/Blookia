import 'package:hive/hive.dart';

part 'tenant.g.dart';

@HiveType(typeId: 0)
class Tenant extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String country;

  @HiveField(3)
  String? logoUrl;

  @HiveField(4)
  String? address;

  @HiveField(5)
  String? phone;

  @HiveField(6)
  DateTime createdAt;

  Tenant({
    required this.id,
    required this.name,
    required this.country,
    this.logoUrl,
    this.address,
    this.phone,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country': country,
      'logoUrl': logoUrl,
      'address': address,
      'phone': phone,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      id: json['id'],
      name: json['name'],
      country: json['country'],
      logoUrl: json['logoUrl'],
      address: json['address'],
      phone: json['phone'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}