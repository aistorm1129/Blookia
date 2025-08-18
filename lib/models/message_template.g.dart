// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_template.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MessageTemplateAdapter extends TypeAdapter<MessageTemplate> {
  @override
  final int typeId = 4;

  @override
  MessageTemplate read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MessageTemplate(
      id: fields[0] as String,
      kind: fields[1] as MessageKind,
      textByLocale: (fields[2] as Map).cast<String, String>(),
      tenantId: fields[3] as String,
      createdAt: fields[4] as DateTime,
      updatedAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, MessageTemplate obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.kind)
      ..writeByte(2)
      ..write(obj.textByLocale)
      ..writeByte(3)
      ..write(obj.tenantId)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageTemplateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
