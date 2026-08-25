import 'dart:convert';

class GaragePartModel {
  final String? id;
  final String name;
  final int stock;
  final double unitCost;
  final double sellPrice;

  GaragePartModel({
    this.id,
    required this.name,
    required this.stock,
    required this.unitCost,
    required this.sellPrice,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'stock': stock,
      'unitCost': unitCost,
      'sellPrice': sellPrice,
    };
  }

  factory GaragePartModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    return GaragePartModel(
      id: docId ?? map['id'],
      name: map['name'] ?? '',
      stock: map['stock']?.toInt() ?? 0,
      unitCost: map['unitCost']?.toDouble() ?? 0.0,
      sellPrice: map['sellPrice']?.toDouble() ?? 0.0,
    );
  }

  String toJson() => json.encode(toMap());

  factory GaragePartModel.fromJson(String source) =>
      GaragePartModel.fromMap(json.decode(source));

  GaragePartModel copyWith({
    String? id,
    String? name,
    int? stock,
    double? unitCost,
    double? sellPrice,
  }) {
    return GaragePartModel(
      id: id ?? this.id,
      name: name ?? this.name,
      stock: stock ?? this.stock,
      unitCost: unitCost ?? this.unitCost,
      sellPrice: sellPrice ?? this.sellPrice,
    );
  }
}
