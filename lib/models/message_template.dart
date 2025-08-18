import 'package:hive/hive.dart';

part 'message_template.g.dart';

enum MessageKind { confirm, reminder, thankyou, cancel, rebook }

@HiveType(typeId: 4)
class MessageTemplate extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  MessageKind kind;

  @HiveField(2)
  Map<String, String> textByLocale;

  @HiveField(3)
  String tenantId;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime updatedAt;

  MessageTemplate({
    required this.id,
    required this.kind,
    required this.textByLocale,
    required this.tenantId,
    required this.createdAt,
    required this.updatedAt,
  });

  String getText(String locale) {
    return textByLocale[locale] ?? textByLocale['en'] ?? '';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kind': kind.toString(),
      'textByLocale': textByLocale,
      'tenantId': tenantId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory MessageTemplate.fromJson(Map<String, dynamic> json) {
    return MessageTemplate(
      id: json['id'],
      kind: MessageKind.values.firstWhere(
        (e) => e.toString() == json['kind'],
        orElse: () => MessageKind.confirm,
      ),
      textByLocale: Map<String, String>.from(json['textByLocale']),
      tenantId: json['tenantId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}