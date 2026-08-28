class RoomHistoryModel {
  final int? id;
  final String moduleType; // 'Gym', 'Garage', 'Shop', 'Event'
  final String roomCode;
  final String roomName;
  final String joinedAt;

  RoomHistoryModel({
    this.id,
    required this.moduleType,
    required this.roomCode,
    required this.roomName,
    required this.joinedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'moduleType': moduleType,
      'roomCode': roomCode,
      'roomName': roomName,
      'joinedAt': joinedAt,
    };
  }

  factory RoomHistoryModel.fromMap(Map<String, dynamic> map) {
    return RoomHistoryModel(
      id: map['id'],
      moduleType: map['moduleType'],
      roomCode: map['roomCode'],
      roomName: map['roomName'],
      joinedAt: map['joinedAt'],
    );
  }
}
