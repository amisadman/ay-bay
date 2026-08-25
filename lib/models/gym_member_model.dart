import 'dart:convert';

class GymMemberModel {
  final String? cloudId;
  final String name;
  final String phone;
  final String planType;
  final String expiryDate;
  final String status;
  final String createdAt;

  // Power features
  final String? assignedTrainer;

  GymMemberModel({
    this.cloudId,
    required this.name,
    required this.phone,
    required this.planType,
    required this.expiryDate,
    required this.status,
    required this.createdAt,
    this.assignedTrainer,
  });

  Map<String, dynamic> toMap() {
    return {
      if (cloudId != null) 'cloudId': cloudId,
      'name': name,
      'phone': phone,
      'planType': planType,
      'expiryDate': expiryDate,
      'status': status,
      'createdAt': createdAt,
      'assignedTrainer': assignedTrainer,
    };
  }

  factory GymMemberModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    return GymMemberModel(
      cloudId: docId ?? map['cloudId'],
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      planType: map['planType'] ?? '',
      expiryDate: map['expiryDate'] ?? '',
      status: map['status'] ?? '',
      createdAt: map['createdAt'] ?? '',
      assignedTrainer: map['assignedTrainer'],
    );
  }

  String toJson() => json.encode(toMap());

  factory GymMemberModel.fromJson(String source) =>
      GymMemberModel.fromMap(json.decode(source));

  GymMemberModel copyWith({
    String? cloudId,
    String? name,
    String? phone,
    String? planType,
    String? expiryDate,
    String? status,
    String? createdAt,
    String? assignedTrainer,
  }) {
    return GymMemberModel(
      cloudId: cloudId ?? this.cloudId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      planType: planType ?? this.planType,
      expiryDate: expiryDate ?? this.expiryDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      assignedTrainer: assignedTrainer ?? this.assignedTrainer,
    );
  }
}
