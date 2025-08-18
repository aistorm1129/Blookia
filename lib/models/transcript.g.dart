// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transcript.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TranscriptVersionAdapter extends TypeAdapter<TranscriptVersion> {
  @override
  final int typeId = 6;

  @override
  TranscriptVersion read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TranscriptVersion(
      id: fields[0] as String,
      text: fields[1] as String,
      createdAt: fields[2] as DateTime,
      editedBy: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TranscriptVersion obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.editedBy);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptVersionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TranscriptAdapter extends TypeAdapter<Transcript> {
  @override
  final int typeId = 7;

  @override
  Transcript read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Transcript(
      id: fields[0] as String,
      patientId: fields[1] as String,
      appointmentId: fields[2] as String,
      text: fields[3] as String,
      versions: (fields[4] as List).cast<TranscriptVersion>(),
      createdAt: fields[5] as DateTime,
      updatedAt: fields[6] as DateTime,
      recordingPath: fields[7] as String?,
      durationSeconds: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Transcript obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.patientId)
      ..writeByte(2)
      ..write(obj.appointmentId)
      ..writeByte(3)
      ..write(obj.text)
      ..writeByte(4)
      ..write(obj.versions)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt)
      ..writeByte(7)
      ..write(obj.recordingPath)
      ..writeByte(8)
      ..write(obj.durationSeconds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
