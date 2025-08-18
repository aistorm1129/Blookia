// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChatMessageAdapter extends TypeAdapter<ChatMessage> {
  @override
  final int typeId = 9;

  @override
  ChatMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatMessage(
      id: fields[0] as String,
      from: fields[1] as MessageSender,
      text: fields[2] as String,
      sentiment: fields[3] as MessageSentiment?,
      intent: fields[4] as MessageIntent?,
      timestamp: fields[5] as DateTime,
      patientId: fields[6] as String?,
      channel: fields[7] as String?,
      requiresHumanHandoff: fields[8] as bool,
      metadata: (fields[9] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, ChatMessage obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.from)
      ..writeByte(2)
      ..write(obj.text)
      ..writeByte(3)
      ..write(obj.sentiment)
      ..writeByte(4)
      ..write(obj.intent)
      ..writeByte(5)
      ..write(obj.timestamp)
      ..writeByte(6)
      ..write(obj.patientId)
      ..writeByte(7)
      ..write(obj.channel)
      ..writeByte(8)
      ..write(obj.requiresHumanHandoff)
      ..writeByte(9)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
