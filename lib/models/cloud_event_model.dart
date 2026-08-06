class CloudEventModel {
  final String eventId;
  final String title;
  final String description;
  final String inviteCode;
  final double budget;
  final String createdBy; // UID of creator
  final List<String> members; // List of UIDs

  CloudEventModel({
    required this.eventId,
    required this.title,
    required this.description,
    required this.inviteCode,
    required this.budget,
    required this.createdBy,
    required this.members,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'inviteCode': inviteCode,
      'budget': budget,
      'createdBy': createdBy,
      'members': members,
    };
  }

  factory CloudEventModel.fromMap(Map<String, dynamic> map, String docId) {
    return CloudEventModel(
      eventId: docId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      inviteCode: map['inviteCode'] ?? '',
      budget: (map['budget'] ?? 0).toDouble(),
      createdBy: map['createdBy'] ?? '',
      members: List<String>.from(map['members'] ?? []),
    );
  }
}

class CloudEventExpenseModel {
  final String expenseId;
  final String eventId;
  final double amount;
  final String description;
  final String category;
  final String paidBy; // Name of person who paid
  final String addedBy; // UID of person who logged it
  final String addedByName; // Name of person who logged it
  final DateTime timestamp;

  CloudEventExpenseModel({
    required this.expenseId,
    required this.eventId,
    required this.amount,
    required this.description,
    required this.category,
    required this.paidBy,
    required this.addedBy,
    required this.addedByName,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'amount': amount,
      'description': description,
      'category': category,
      'paidBy': paidBy,
      'addedBy': addedBy,
      'addedByName': addedByName,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory CloudEventExpenseModel.fromMap(
      Map<String, dynamic> map, String docId) {
    return CloudEventExpenseModel(
      expenseId: docId,
      eventId: map['eventId'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      paidBy: map['paidBy'] ?? '',
      addedBy: map['addedBy'] ?? '',
      addedByName: map['addedByName'] ?? 'Unknown',
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
    );
  }
}
