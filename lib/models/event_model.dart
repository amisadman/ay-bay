class EventModel {
  final int? id;
  final String title;
  final double budget;
  final double spent;
  final String date;
  final String? note;

  EventModel({
    this.id,
    required this.title,
    required this.budget,
    this.spent = 0.0,
    required this.date,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'budget': budget,
      'spent': spent,
      'date': date,
      'note': note,
    };
  }

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'],
      title: map['title'] ?? '',
      budget: (map['budget'] as num?)?.toDouble() ?? 0.0,
      spent: (map['spent'] as num?)?.toDouble() ?? 0.0,
      date: map['date'] ?? '',
      note: map['note'],
    );
  }
}
