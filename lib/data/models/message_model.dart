enum MessageType {
  text,
  image,
  voice,
  location,
}

class Message {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final MessageType messageType;
  final String? imageUrl;
  final String? voiceUrl;
  final bool synced;
  
  Message({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    required this.messageType,
    this.imageUrl,
    this.voiceUrl,
    this.synced = false,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'is_user': isUser ? 1 : 0,
      'timestamp': timestamp.toIso8601String(),
      'message_type': messageType.toString().split('.').last,
      'image_url': imageUrl,
      'voice_url': voiceUrl,
      'synced': synced ? 1 : 0,
    };
  }
  
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      text: json['text'],
      isUser: json['is_user'] == 1,
      timestamp: DateTime.parse(json['timestamp']),
      messageType: MessageType.values.firstWhere(
        (e) => e.toString().split('.').last == json['message_type'],
      ),
      imageUrl: json['image_url'],
      voiceUrl: json['voice_url'],
      synced: json['synced'] == 1,
    );
  }
}
