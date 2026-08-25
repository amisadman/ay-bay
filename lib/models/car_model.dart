class CarModel {
  final int? id;
  final String carName;
  final String licensePlate;
  final String expenses; // JSON string of list of maps
  final String createdAt;

  CarModel({
    this.id,
    required this.carName,
    required this.licensePlate,
    required this.expenses,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'carName': carName,
      'licensePlate': licensePlate,
      'expenses': expenses,
      'createdAt': createdAt,
    };
  }

  factory CarModel.fromMap(Map<String, dynamic> map) {
    return CarModel(
      id: map['id'],
      carName: map['carName'],
      licensePlate: map['licensePlate'],
      expenses: map['expenses'],
      createdAt: map['createdAt'],
    );
  }
}
