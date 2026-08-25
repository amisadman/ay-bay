import 'dart:convert';

class SubscriptionModel {
  final int? id;
  final String name;
  final double cost;
  final String billingCycle;
  final String nextDueDate;
  final String createdAt;

  SubscriptionModel({
    this.id,
    required this.name,
    required this.cost,
    required this.billingCycle,
    required this.nextDueDate,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'cost': cost,
      'billingCycle': billingCycle,
      'nextDueDate': nextDueDate,
      'createdAt': createdAt,
    };
  }

  factory SubscriptionModel.fromMap(Map<String, dynamic> map) {
    return SubscriptionModel(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      cost: map['cost']?.toDouble() ?? 0.0,
      billingCycle: map['billingCycle'] ?? '',
      nextDueDate: map['nextDueDate'] ?? '',
      createdAt: map['createdAt'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory SubscriptionModel.fromJson(String source) =>
      SubscriptionModel.fromMap(json.decode(source));

  SubscriptionModel copyWith({
    int? id,
    String? name,
    double? cost,
    String? billingCycle,
    String? nextDueDate,
    String? createdAt,
  }) {
    return SubscriptionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      cost: cost ?? this.cost,
      billingCycle: billingCycle ?? this.billingCycle,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
