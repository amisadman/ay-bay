import 'dart:convert';

class GarageExpenseModel {
  final String? id;
  final String category;
  final double amount;
  final String date;

  GarageExpenseModel({
    this.id,
    required this.category,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'category': category,
      'amount': amount,
      'date': date,
    };
  }

  factory GarageExpenseModel.fromMap(Map<String, dynamic> map,
      [String? docId]) {
    return GarageExpenseModel(
      id: docId ?? map['id'],
      category: map['category'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
      date: map['date'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory GarageExpenseModel.fromJson(String source) =>
      GarageExpenseModel.fromMap(json.decode(source));

  GarageExpenseModel copyWith({
    String? id,
    String? category,
    double? amount,
    String? date,
  }) {
    return GarageExpenseModel(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
    );
  }
}
