class GarageEmployeeModel {
  final String name;
  final String phone;
  final String role; // 'Admin', 'Pending', 'Mechanic'

  GarageEmployeeModel({
    required this.name,
    required this.phone,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'role': role,
    };
  }

  factory GarageEmployeeModel.fromMap(Map<String, dynamic> map) {
    return GarageEmployeeModel(
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? 'Pending',
    );
  }
}
