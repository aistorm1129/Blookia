import 'package:hive/hive.dart';

part 'appointment.g.dart';

@HiveType(typeId: 20)
enum AppointmentStatus { 
  @HiveField(0) confirmed, 
  @HiveField(1) waitlist, 
  @HiveField(2) noShow, 
  @HiveField(3) cancelled, 
  @HiveField(4) completed 
}

@HiveType(typeId: 21)
enum AppointmentType { 
  @HiveField(0) consultation, 
  @HiveField(1) procedure, 
  @HiveField(2) followUp, 
  @HiveField(3) emergency 
}

@HiveType(typeId: 22)
enum Channel { 
  @HiveField(0) inPerson, 
  @HiveField(1) teleconsult, 
  @HiveField(2) phone 
}

@HiveType(typeId: 3)
class Appointment extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String patientId;

  @HiveField(2)
  String professionalId;

  @HiveField(3)
  DateTime start;

  @HiveField(4)
  DateTime end;

  @HiveField(5)
  AppointmentType type;

  @HiveField(6)
  AppointmentStatus status;

  @HiveField(7)
  Channel channel;

  @HiveField(8)
  double noShowRisk;

  @HiveField(9)
  String? notes;

  @HiveField(10)
  String? privateNotes;

  @HiveField(11)
  Map<String, int>? painMapScores;

  @HiveField(12)
  bool consentGiven;

  @HiveField(13)
  String? recordingPath;

  @HiveField(14)
  String? transcriptId;

  @HiveField(15)
  DateTime createdAt;

  @HiveField(16)
  DateTime updatedAt;

  @HiveField(17)
  int? durationMinutes;

  @HiveField(18)
  bool isUrgent;

  Appointment({
    required this.id,
    required this.patientId,
    required this.professionalId,
    required this.start,
    required this.end,
    required this.type,
    required this.status,
    required this.channel,
    required this.noShowRisk,
    this.notes,
    this.privateNotes,
    this.painMapScores,
    this.consentGiven = false,
    this.recordingPath,
    this.transcriptId,
    required this.createdAt,
    required this.updatedAt,
    this.durationMinutes,
    this.isUrgent = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'professionalId': professionalId,
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
      'type': type.toString(),
      'status': status.toString(),
      'channel': channel.toString(),
      'noShowRisk': noShowRisk,
      'notes': notes,
      'privateNotes': privateNotes,
      'painMapScores': painMapScores,
      'consentGiven': consentGiven,
      'recordingPath': recordingPath,
      'transcriptId': transcriptId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'durationMinutes': durationMinutes,
      'isUrgent': isUrgent,
    };
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      patientId: json['patientId'],
      professionalId: json['professionalId'],
      start: DateTime.parse(json['start']),
      end: DateTime.parse(json['end']),
      type: AppointmentType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => AppointmentType.consultation,
      ),
      status: AppointmentStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => AppointmentStatus.confirmed,
      ),
      channel: Channel.values.firstWhere(
        (e) => e.toString() == json['channel'],
        orElse: () => Channel.inPerson,
      ),
      noShowRisk: json['noShowRisk']?.toDouble() ?? 0.0,
      notes: json['notes'],
      privateNotes: json['privateNotes'],
      painMapScores: json['painMapScores']?.cast<String, int>(),
      consentGiven: json['consentGiven'] ?? false,
      recordingPath: json['recordingPath'],
      transcriptId: json['transcriptId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      durationMinutes: json['durationMinutes'],
      isUrgent: json['isUrgent'] ?? false,
    );
  }
}