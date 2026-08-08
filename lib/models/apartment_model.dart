import 'dart:convert';

class ApartmentModel {
  final int? id;
  final String name;
  final String boarderName;
  final String boarderPhone;
  final double rentAmount;
  final List<String> paidMonths; // e.g. ["2026-08", "2026-09"]
  final String createdAt;

  ApartmentModel({
    this.id,
    required this.name,
    required this.boarderName,
    required this.boarderPhone,
    required this.rentAmount,
    required this.paidMonths,
    required this.createdAt,
  });

  ApartmentModel copyWith({
    int? id,
    String? name,
    String? boarderName,
    String? boarderPhone,
    double? rentAmount,
    List<String>? paidMonths,
    String? createdAt,
  }) {
    return ApartmentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      boarderName: boarderName ?? this.boarderName,
      boarderPhone: boarderPhone ?? this.boarderPhone,
      rentAmount: rentAmount ?? this.rentAmount,
      paidMonths: paidMonths ?? this.paidMonths,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'boarderName': boarderName,
      'boarderPhone': boarderPhone,
      'rentAmount': rentAmount,
      'paidMonths': jsonEncode(paidMonths),
      'createdAt': createdAt,
    };
  }

  factory ApartmentModel.fromMap(Map<String, dynamic> map) {
    return ApartmentModel(
      id: map['id'],
      name: map['name'],
      boarderName: map['boarderName'],
      boarderPhone: map['boarderPhone'],
      rentAmount: map['rentAmount'],
      paidMonths: List<String>.from(jsonDecode(map['paidMonths'])),
      createdAt: map['createdAt'],
    );
  }
}
