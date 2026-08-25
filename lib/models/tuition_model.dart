class TuitionModel {
  final int? id;
  final String studentName;
  final String institution;
  final double monthlyFee;
  final int dueDate; // 1-31
  final String expenses; // JSON string of list of maps
  final String createdAt;

  TuitionModel({
    this.id,
    required this.studentName,
    required this.institution,
    required this.monthlyFee,
    required this.dueDate,
    required this.expenses,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentName': studentName,
      'institution': institution,
      'monthlyFee': monthlyFee,
      'dueDate': dueDate,
      'expenses': expenses,
      'createdAt': createdAt,
    };
  }

  factory TuitionModel.fromMap(Map<String, dynamic> map) {
    return TuitionModel(
      id: map['id'],
      studentName: map['studentName'],
      institution: map['institution'],
      monthlyFee: map['monthlyFee'],
      dueDate: map['dueDate'],
      expenses: map['expenses'],
      createdAt: map['createdAt'],
    );
  }
}
