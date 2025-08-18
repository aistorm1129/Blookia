import 'package:hive/hive.dart';

part 'chat_message.g.dart';

enum MessageSender { patient, assistant }
enum MessageSentiment { neutral, happy, angry, urgent, confused }
enum MessageIntent { booking, cancellation, pricing, hours, location, postcare, general }

@HiveType(typeId: 9)
class ChatMessage extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  MessageSender from;

  @HiveField(2)
  String text;

  @HiveField(3)
  MessageSentiment? sentiment;

  @HiveField(4)
  MessageIntent? intent;

  @HiveField(5)
  DateTime timestamp;

  @HiveField(6)
  String? patientId;

  @HiveField(7)
  String? channel;

  @HiveField(8)
  bool requiresHumanHandoff;

  @HiveField(9)
  Map<String, dynamic>? metadata;

  ChatMessage({
    required this.id,
    required this.from,
    required this.text,
    this.sentiment,
    this.intent,
    required this.timestamp,
    this.patientId,
    this.channel,
    this.requiresHumanHandoff = false,
    this.metadata,
  });

  bool get needsAttention => 
      sentiment == MessageSentiment.angry || 
      sentiment == MessageSentiment.urgent ||
      requiresHumanHandoff;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from': from.toString(),
      'text': text,
      'sentiment': sentiment?.toString(),
      'intent': intent?.toString(),
      'timestamp': timestamp.toIso8601String(),
      'patientId': patientId,
      'channel': channel,
      'requiresHumanHandoff': requiresHumanHandoff,
      'metadata': metadata,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      from: MessageSender.values.firstWhere(
        (e) => e.toString() == json['from'],
        orElse: () => MessageSender.patient,
      ),
      text: json['text'],
      sentiment: json['sentiment'] != null 
          ? MessageSentiment.values.firstWhere(
              (e) => e.toString() == json['sentiment'],
              orElse: () => MessageSentiment.neutral,
            )
          : null,
      intent: json['intent'] != null 
          ? MessageIntent.values.firstWhere(
              (e) => e.toString() == json['intent'],
              orElse: () => MessageIntent.general,
            )
          : null,
      timestamp: DateTime.parse(json['timestamp']),
      patientId: json['patientId'],
      channel: json['channel'],
      requiresHumanHandoff: json['requiresHumanHandoff'] ?? false,
      metadata: json['metadata'],
    );
  }
}