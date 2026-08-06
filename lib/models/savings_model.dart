class SavingsModel {
  final int? id;
  final String bankName;
  final String accountNumber;
  final String branchAddress;
  final double balance;
  final String transactions; // JSON string of deposits/withdrawals
  final String createdAt;

  SavingsModel({
    this.id,
    required this.bankName,
    required this.accountNumber,
    required this.branchAddress,
    required this.balance,
    required this.transactions,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'branchAddress': branchAddress,
      'balance': balance,
      'transactions': transactions,
      'createdAt': createdAt,
    };
  }

  factory SavingsModel.fromMap(Map<String, dynamic> map) {
    return SavingsModel(
      id: map['id'] as int?,
      bankName: map['bankName'] as String,
      accountNumber: map['accountNumber'] as String,
      branchAddress: map['branchAddress'] as String,
      balance: (map['balance'] as num).toDouble(),
      transactions: map['transactions'] as String? ?? '[]',
      createdAt: map['createdAt'] as String,
    );
  }
}
