import 'package:hive/hive.dart';

part 'marker_3d.g.dart';

@HiveType(typeId: 11)
class Marker3D extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String modelId;

  @HiveField(2)
  Map<String, double> position;

  @HiveField(3)
  String? note;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  String? createdBy;

  @HiveField(6)
  String? color;

  @HiveField(7)
  String? icon;

  Marker3D({
    required this.id,
    required this.modelId,
    required this.position,
    this.note,
    required this.createdAt,
    this.createdBy,
    this.color,
    this.icon,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'modelId': modelId,
      'position': position,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'color': color,
      'icon': icon,
    };
  }

  factory Marker3D.fromJson(Map<String, dynamic> json) {
    return Marker3D(
      id: json['id'],
      modelId: json['modelId'],
      position: Map<String, double>.from(json['position']),
      note: json['note'],
      createdAt: DateTime.parse(json['createdAt']),
      createdBy: json['createdBy'],
      color: json['color'],
      icon: json['icon'],
    );
  }
}