import 'package:hive/hive.dart';

part 'transcript.g.dart';

@HiveType(typeId: 6)
class TranscriptVersion extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String text;

  @HiveField(2)
  DateTime createdAt;

  @HiveField(3)
  String? editedBy;

  TranscriptVersion({
    required this.id,
    required this.text,
    required this.createdAt,
    this.editedBy,
  });
}

@HiveType(typeId: 7)
class Transcript extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String patientId;

  @HiveField(2)
  String appointmentId;

  @HiveField(3)
  String text;

  @HiveField(4)
  List<TranscriptVersion> versions;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime updatedAt;

  @HiveField(7)
  String? recordingPath;

  @HiveField(8)
  int durationSeconds;

  Transcript({
    required this.id,
    required this.patientId,
    required this.appointmentId,
    required this.text,
    required this.versions,
    required this.createdAt,
    required this.updatedAt,
    this.recordingPath,
    this.durationSeconds = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'appointmentId': appointmentId,
      'text': text,
      'versions': versions.map((v) => {
        'id': v.id,
        'text': v.text,
        'createdAt': v.createdAt.toIso8601String(),
        'editedBy': v.editedBy,
      }).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'recordingPath': recordingPath,
      'durationSeconds': durationSeconds,
    };
  }

  factory Transcript.fromJson(Map<String, dynamic> json) {
    return Transcript(
      id: json['id'],
      patientId: json['patientId'],
      appointmentId: json['appointmentId'],
      text: json['text'],
      versions: (json['versions'] as List).map((v) => TranscriptVersion(
        id: v['id'],
        text: v['text'],
        createdAt: DateTime.parse(v['createdAt']),
        editedBy: v['editedBy'],
      )).toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      recordingPath: json['recordingPath'],
      durationSeconds: json['durationSeconds'] ?? 0,
    );
  }
}