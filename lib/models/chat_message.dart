class ChatMessage {
  final int? id;
  final int sessionId;
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    this.id,
    required this.sessionId, 
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'session_id': sessionId, 
      'text': text,
      'isUser': isUser ? 1 : 0,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'],
      sessionId: map['session_id'] ?? 1, 
      text: map['text'],
      isUser: map['isUser'] == 1,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
    );
  }
}