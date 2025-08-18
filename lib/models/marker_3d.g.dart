// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marker_3d.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class Marker3DAdapter extends TypeAdapter<Marker3D> {
  @override
  final int typeId = 11;

  @override
  Marker3D read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Marker3D(
      id: fields[0] as String,
      modelId: fields[1] as String,
      position: (fields[2] as Map).cast<String, double>(),
      note: fields[3] as String?,
      createdAt: fields[4] as DateTime,
      createdBy: fields[5] as String?,
      color: fields[6] as String?,
      icon: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Marker3D obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.modelId)
      ..writeByte(2)
      ..write(obj.position)
      ..writeByte(3)
      ..write(obj.note)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.createdBy)
      ..writeByte(6)
      ..write(obj.color)
      ..writeByte(7)
      ..write(obj.icon);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Marker3DAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
