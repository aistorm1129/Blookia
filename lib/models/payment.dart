import 'package:hive/hive.dart';

part 'payment.g.dart';

enum PaymentMethod { cash, card, pix, transfer, insurance }
enum PaymentStatus { pending, completed, failed, refunded }

@HiveType(typeId: 5)
class Payment extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String patientId;

  @HiveField(2)
  double amount;

  @HiveField(3)
  PaymentMethod method;

  @HiveField(4)
  PaymentStatus status;

  @HiveField(5)
  String? txId;

  @HiveField(6)
  DateTime timestamp;

  @HiveField(7)
  String? appointmentId;

  @HiveField(8)
  String? description;

  @HiveField(9)
  String? qrCodeData;

  @HiveField(10)
  String? paymentLink;

  Payment({
    required this.id,
    required this.patientId,
    required this.amount,
    required this.method,
    required this.status,
    this.txId,
    required this.timestamp,
    this.appointmentId,
    this.description,
    this.qrCodeData,
    this.paymentLink,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'amount': amount,
      'method': method.toString(),
      'status': status.toString(),
      'txId': txId,
      'timestamp': timestamp.toIso8601String(),
      'appointmentId': appointmentId,
      'description': description,
      'qrCodeData': qrCodeData,
      'paymentLink': paymentLink,
    };
  }

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      patientId: json['patientId'],
      amount: json['amount']?.toDouble() ?? 0.0,
      method: PaymentMethod.values.firstWhere(
        (e) => e.toString() == json['method'],
        orElse: () => PaymentMethod.cash,
      ),
      status: PaymentStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      txId: json['txId'],
      timestamp: DateTime.parse(json['timestamp']),
      appointmentId: json['appointmentId'],
      description: json['description'],
      qrCodeData: json['qrCodeData'],
      paymentLink: json['paymentLink'],
    );
  }
}