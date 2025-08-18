// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppointmentAdapter extends TypeAdapter<Appointment> {
  @override
  final int typeId = 3;

  @override
  Appointment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Appointment(
      id: fields[0] as String,
      patientId: fields[1] as String,
      professionalId: fields[2] as String,
      start: fields[3] as DateTime,
      end: fields[4] as DateTime,
      type: fields[5] as AppointmentType,
      status: fields[6] as AppointmentStatus,
      channel: fields[7] as Channel,
      noShowRisk: fields[8] as double,
      notes: fields[9] as String?,
      privateNotes: fields[10] as String?,
      painMapScores: (fields[11] as Map?)?.cast<String, int>(),
      consentGiven: fields[12] as bool,
      recordingPath: fields[13] as String?,
      transcriptId: fields[14] as String?,
      createdAt: fields[15] as DateTime,
      updatedAt: fields[16] as DateTime,
      durationMinutes: fields[17] as int?,
      isUrgent: fields[18] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Appointment obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.patientId)
      ..writeByte(2)
      ..write(obj.professionalId)
      ..writeByte(3)
      ..write(obj.start)
      ..writeByte(4)
      ..write(obj.end)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.channel)
      ..writeByte(8)
      ..write(obj.noShowRisk)
      ..writeByte(9)
      ..write(obj.notes)
      ..writeByte(10)
      ..write(obj.privateNotes)
      ..writeByte(11)
      ..write(obj.painMapScores)
      ..writeByte(12)
      ..write(obj.consentGiven)
      ..writeByte(13)
      ..write(obj.recordingPath)
      ..writeByte(14)
      ..write(obj.transcriptId)
      ..writeByte(15)
      ..write(obj.createdAt)
      ..writeByte(16)
      ..write(obj.updatedAt)
      ..writeByte(17)
      ..write(obj.durationMinutes)
      ..writeByte(18)
      ..write(obj.isUrgent);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppointmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AppointmentStatusAdapter extends TypeAdapter<AppointmentStatus> {
  @override
  final int typeId = 20;

  @override
  AppointmentStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AppointmentStatus.confirmed;
      case 1:
        return AppointmentStatus.waitlist;
      case 2:
        return AppointmentStatus.noShow;
      case 3:
        return AppointmentStatus.cancelled;
      case 4:
        return AppointmentStatus.completed;
      default:
        return AppointmentStatus.confirmed;
    }
  }

  @override
  void write(BinaryWriter writer, AppointmentStatus obj) {
    switch (obj) {
      case AppointmentStatus.confirmed:
        writer.writeByte(0);
        break;
      case AppointmentStatus.waitlist:
        writer.writeByte(1);
        break;
      case AppointmentStatus.noShow:
        writer.writeByte(2);
        break;
      case AppointmentStatus.cancelled:
        writer.writeByte(3);
        break;
      case AppointmentStatus.completed:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppointmentStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AppointmentTypeAdapter extends TypeAdapter<AppointmentType> {
  @override
  final int typeId = 21;

  @override
  AppointmentType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AppointmentType.consultation;
      case 1:
        return AppointmentType.procedure;
      case 2:
        return AppointmentType.followUp;
      case 3:
        return AppointmentType.emergency;
      default:
        return AppointmentType.consultation;
    }
  }

  @override
  void write(BinaryWriter writer, AppointmentType obj) {
    switch (obj) {
      case AppointmentType.consultation:
        writer.writeByte(0);
        break;
      case AppointmentType.procedure:
        writer.writeByte(1);
        break;
      case AppointmentType.followUp:
        writer.writeByte(2);
        break;
      case AppointmentType.emergency:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppointmentTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ChannelAdapter extends TypeAdapter<Channel> {
  @override
  final int typeId = 22;

  @override
  Channel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Channel.inPerson;
      case 1:
        return Channel.teleconsult;
      case 2:
        return Channel.phone;
      default:
        return Channel.inPerson;
    }
  }

  @override
  void write(BinaryWriter writer, Channel obj) {
    switch (obj) {
      case Channel.inPerson:
        writer.writeByte(0);
        break;
      case Channel.teleconsult:
        writer.writeByte(1);
        break;
      case Channel.phone:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChannelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
