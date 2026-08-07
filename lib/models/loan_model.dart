class LoanModel {
  final int? id;
  final String personName;
  final String phoneNumber; // Added
  final double amount;
  final double amountPaid; // Added
  final String type; // 'loan' (given) or 'owe' (borrowed)
  final String dueDate;
  final String status; // 'pending' or 'settled'
  final String installments; // Added - JSON string of installments
  final String? note;
  final String createdAt;

  LoanModel({
    this.id,
    required this.personName,
    required this.phoneNumber,
    required this.amount,
    required this.amountPaid,
    required this.type,
    required this.dueDate,
    required this.status,
    required this.installments,
    this.note,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'personName': personName,
      'phoneNumber': phoneNumber,
      'amount': amount,
      'amountPaid': amountPaid,
      'type': type,
      'dueDate': dueDate,
      'status': status,
      'installments': installments,
      'note': note,
      'createdAt': createdAt,
    };
  }

  factory LoanModel.fromMap(Map<String, dynamic> map) {
    return LoanModel(
      id: map['id'] as int?,
      personName: map['personName'] as String,
      phoneNumber: map['phoneNumber'] as String? ?? '',
      amount: (map['amount'] as num).toDouble(),
      amountPaid: (map['amountPaid'] as num?)?.toDouble() ?? 0.0,
      type: map['type'] as String,
      dueDate: map['dueDate'] as String,
      status: map['status'] as String,
      installments: map['installments'] as String? ?? '[]',
      note: map['note'] as String?,
      createdAt: map['createdAt'] as String,
    );
  }

  LoanModel copyWith({
    int? id,
    String? personName,
    String? phoneNumber,
    double? amount,
    double? amountPaid,
    String? type,
    String? dueDate,
    String? status,
    String? installments,
    String? note,
    String? createdAt,
  }) {
    return LoanModel(
      id: id ?? this.id,
      personName: personName ?? this.personName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      amount: amount ?? this.amount,
      amountPaid: amountPaid ?? this.amountPaid,
      type: type ?? this.type,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      installments: installments ?? this.installments,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
