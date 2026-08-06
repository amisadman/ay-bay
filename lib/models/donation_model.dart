class DonationModel {
  final int? id;
  final String organizationName;
  final double amount; // Initial goal or target (can be 0 if just tracking)
  final double totalDonated; // Sum of expenses made towards this
  final String? note;
  final String createdAt;

  DonationModel({
    this.id,
    required this.organizationName,
    required this.amount,
    required this.totalDonated,
    this.note,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'organizationName': organizationName,
      'amount': amount,
      'totalDonated': totalDonated,
      'note': note,
      'createdAt': createdAt,
    };
  }

  factory DonationModel.fromMap(Map<String, dynamic> map) {
    return DonationModel(
      id: map['id'] as int?,
      organizationName: map['organizationName'] as String,
      amount: (map['amount'] as num).toDouble(),
      totalDonated: (map['totalDonated'] as num?)?.toDouble() ?? 0.0,
      note: map['note'] as String?,
      createdAt: map['createdAt'] as String,
    );
  }
}
