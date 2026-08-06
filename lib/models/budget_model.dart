class BudgetModel {
  final int? id;
  final String monthYear; // e.g. "August 2026"
  final String budgets; // JSON String of { id, category, amount, spent }
  final String createdAt;

  BudgetModel({
    this.id,
    required this.monthYear,
    required this.budgets,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'monthYear': monthYear,
      'budgets': budgets,
      'createdAt': createdAt,
    };
  }

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'] as int?,
      monthYear: map['monthYear'] as String,
      budgets: map['budgets'] as String? ?? '[]',
      createdAt: map['createdAt'] as String,
    );
  }
}
