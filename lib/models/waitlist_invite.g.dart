// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'waitlist_invite.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WaitlistInviteAdapter extends TypeAdapter<WaitlistInvite> {
  @override
  final int typeId = 8;

  @override
  WaitlistInvite read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WaitlistInvite(
      id: fields[0] as String,
      appointmentId: fields[1] as String,
      patientId: fields[2] as String,
      expiresAt: fields[3] as DateTime,
      accepted: fields[4] as bool,
      createdAt: fields[5] as DateTime,
      respondedAt: fields[6] as DateTime?,
      loyaltyPointsAwarded: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, WaitlistInvite obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.appointmentId)
      ..writeByte(2)
      ..write(obj.patientId)
      ..writeByte(3)
      ..write(obj.expiresAt)
      ..writeByte(4)
      ..write(obj.accepted)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.respondedAt)
      ..writeByte(7)
      ..write(obj.loyaltyPointsAwarded);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WaitlistInviteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
