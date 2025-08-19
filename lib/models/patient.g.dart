// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PatientAdapter extends TypeAdapter<Patient> {
  @override
  final int typeId = 10;

  @override
  Patient read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Patient(
      id: fields[0] as String,
      name: fields[1] as String,
      docType: fields[2] as String,
      docNumber: fields[3] as String,
      phone: fields[4] as String?,
      email: fields[5] as String?,
      address: fields[6] as String?,
      socials: (fields[7] as Map?)?.cast<String, String>(),
      photoUrl: fields[8] as String?,
      internalNotes: (fields[9] as List).cast<String>(),
      dateOfBirth: fields[10] as DateTime?,
      emergencyContact: fields[11] as String?,
      allergies: (fields[12] as List).cast<String>(),
      medications: (fields[13] as List).cast<String>(),
      createdAt: fields[14] as DateTime,
      updatedAt: fields[15] as DateTime,
      loyaltyPoints: fields[16] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Patient obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.docType)
      ..writeByte(3)
      ..write(obj.docNumber)
      ..writeByte(4)
      ..write(obj.phone)
      ..writeByte(5)
      ..write(obj.email)
      ..writeByte(6)
      ..write(obj.address)
      ..writeByte(7)
      ..write(obj.socials)
      ..writeByte(8)
      ..write(obj.photoUrl)
      ..writeByte(9)
      ..write(obj.internalNotes)
      ..writeByte(10)
      ..write(obj.dateOfBirth)
      ..writeByte(11)
      ..write(obj.emergencyContact)
      ..writeByte(12)
      ..write(obj.allergies)
      ..writeByte(13)
      ..write(obj.medications)
      ..writeByte(14)
      ..write(obj.createdAt)
      ..writeByte(15)
      ..write(obj.updatedAt)
      ..writeByte(16)
      ..write(obj.loyaltyPoints);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PatientAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
