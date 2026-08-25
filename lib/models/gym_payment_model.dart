import 'dart:convert';

class GymPaymentModel {
  final String? id;
  final String memberId;
  final double amount;
  final String planType;
  final String date;

  GymPaymentModel({
    this.id,
    required this.memberId,
    required this.amount,
    required this.planType,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'memberId': memberId,
      'amount': amount,
      'planType': planType,
      'date': date,
    };
  }

  factory GymPaymentModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    return GymPaymentModel(
      id: docId ?? map['id'],
      memberId: map['memberId'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
      planType: map['planType'] ?? '',
      date: map['date'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory GymPaymentModel.fromJson(String source) =>
      GymPaymentModel.fromMap(json.decode(source));

  GymPaymentModel copyWith({
    String? id,
    String? memberId,
    double? amount,
    String? planType,
    String? date,
  }) {
    return GymPaymentModel(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      amount: amount ?? this.amount,
      planType: planType ?? this.planType,
      date: date ?? this.date,
    );
  }
}
