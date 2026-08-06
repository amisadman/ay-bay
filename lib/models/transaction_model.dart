class TransactionModel {
  final int? id;
  final String title;
  final double amount;
  final String type; // 'income' or 'expense'
  final String category;
  final String date; // YYYY-MM-DD
  final String? note;
  final String createdAt;

  TransactionModel({
    this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.note,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type,
      'category': category,
      'date': date,
      'note': note,
      'createdAt': createdAt,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] as String,
      category: map['category'] as String,
      date: map['date'] as String,
      note: map['note'] as String?,
      createdAt: map['createdAt'] as String,
    );
  }
}
