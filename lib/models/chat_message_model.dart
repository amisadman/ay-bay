class ChatMessageModel {
  final String id;
  final String sender; // 'user' or 'walleo'
  final String text;
  final DateTime timestamp;
  final bool isActionExecuted;
  final String? actionDetails;

  ChatMessageModel({
    required this.id,
    required this.sender,
    required this.text,
    required this.timestamp,
    this.isActionExecuted = false,
    this.actionDetails,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sender': sender,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'isActionExecuted': isActionExecuted ? 1 : 0,
      'actionDetails': actionDetails,
    };
  }

  factory ChatMessageModel.fromMap(Map<String, dynamic> map) {
    return ChatMessageModel(
      id: map['id'] as String,
      sender: map['sender'] as String,
      text: map['text'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      isActionExecuted: (map['isActionExecuted'] as int? ?? 0) == 1,
      actionDetails: map['actionDetails'] as String?,
    );
  }
}
