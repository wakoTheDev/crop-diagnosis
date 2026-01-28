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
  final List<String> attachedImages;
  final List<String> attachedAudioFiles;
  final List<String> attachedFiles;
  
  Message({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    required this.messageType,
    this.imageUrl,
    this.voiceUrl,
    this.synced = false,
    List<String>? attachedImages,
    List<String>? attachedAudioFiles,
    List<String>? attachedFiles,
  })  : attachedImages = attachedImages ?? [],
        attachedAudioFiles = attachedAudioFiles ?? [],
        attachedFiles = attachedFiles ?? [];
  
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
      'attached_images': attachedImages,
      'attached_audio_files': attachedAudioFiles,
      'attached_files': attachedFiles,
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
      attachedImages: json['attached_images'] != null 
          ? List<String>.from(json['attached_images']) 
          : null,
      attachedAudioFiles: json['attached_audio_files'] != null 
          ? List<String>.from(json['attached_audio_files']) 
          : null,
      attachedFiles: json['attached_files'] != null 
          ? List<String>.from(json['attached_files']) 
          : null,
    );
  }
}
