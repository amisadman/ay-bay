import 'dart:convert';

class GarageVehicleModel {
  final String? id;
  final String clientName;
  final String licensePlate;
  final String makeModel;
  final String status;
  final double estimatedCost; // Total cost (labor + parts)
  final String createdAt;

  // Power features
  final String? mechanicName;
  final double laborCost;
  final List<Map<String, dynamic>> usedParts;

  GarageVehicleModel({
    this.id,
    required this.clientName,
    required this.licensePlate,
    required this.makeModel,
    required this.status,
    required this.estimatedCost,
    required this.createdAt,
    this.mechanicName,
    this.laborCost = 0.0,
    this.usedParts = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'clientName': clientName,
      'licensePlate': licensePlate,
      'makeModel': makeModel,
      'status': status,
      'estimatedCost': estimatedCost,
      'createdAt': createdAt,
      'mechanicName': mechanicName,
      'laborCost': laborCost,
      'usedParts': usedParts,
    };
  }

  factory GarageVehicleModel.fromMap(Map<String, dynamic> map,
      [String? docId]) {
    return GarageVehicleModel(
      id: docId ?? map['id'],
      clientName: map['clientName'] ?? '',
      licensePlate: map['licensePlate'] ?? '',
      makeModel: map['makeModel'] ?? '',
      status: map['status'] ?? 'Pending',
      estimatedCost: map['estimatedCost']?.toDouble() ?? 0.0,
      createdAt: map['createdAt'] ?? '',
      mechanicName: map['mechanicName'],
      laborCost: map['laborCost']?.toDouble() ?? 0.0,
      usedParts: List<Map<String, dynamic>>.from(map['usedParts'] ?? []),
    );
  }

  String toJson() => json.encode(toMap());

  factory GarageVehicleModel.fromJson(String source) =>
      GarageVehicleModel.fromMap(json.decode(source));

  GarageVehicleModel copyWith({
    String? id,
    String? clientName,
    String? licensePlate,
    String? makeModel,
    String? status,
    double? estimatedCost,
    String? createdAt,
    String? mechanicName,
    double? laborCost,
    List<Map<String, dynamic>>? usedParts,
  }) {
    return GarageVehicleModel(
      id: id ?? this.id,
      clientName: clientName ?? this.clientName,
      licensePlate: licensePlate ?? this.licensePlate,
      makeModel: makeModel ?? this.makeModel,
      status: status ?? this.status,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      createdAt: createdAt ?? this.createdAt,
      mechanicName: mechanicName ?? this.mechanicName,
      laborCost: laborCost ?? this.laborCost,
      usedParts: usedParts ?? this.usedParts,
    );
  }
}
