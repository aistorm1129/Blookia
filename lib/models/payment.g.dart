// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PaymentAdapter extends TypeAdapter<Payment> {
  @override
  final int typeId = 5;

  @override
  Payment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Payment(
      id: fields[0] as String,
      patientId: fields[1] as String,
      amount: fields[2] as double,
      method: fields[3] as PaymentMethod,
      status: fields[4] as PaymentStatus,
      txId: fields[5] as String?,
      timestamp: fields[6] as DateTime,
      appointmentId: fields[7] as String?,
      description: fields[8] as String?,
      qrCodeData: fields[9] as String?,
      paymentLink: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Payment obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.patientId)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.method)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.txId)
      ..writeByte(6)
      ..write(obj.timestamp)
      ..writeByte(7)
      ..write(obj.appointmentId)
      ..writeByte(8)
      ..write(obj.description)
      ..writeByte(9)
      ..write(obj.qrCodeData)
      ..writeByte(10)
      ..write(obj.paymentLink);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
