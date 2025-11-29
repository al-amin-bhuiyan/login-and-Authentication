class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String messageText;
  final DateTime createdAt;
  final bool isRead;
  final String? replyToId;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.messageText,
    required this.createdAt,
    this.isRead = false,
    this.replyToId,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'].toString(),
      conversationId: json['conversation_id'].toString(),
      senderId: json['sender_id'].toString(),
      senderName: json['sender_name'] ?? 'Unknown',
      senderAvatar: json['sender_avatar'],
      messageText: json['message_text'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      isRead: json['is_read'] ?? false,
      replyToId: json['reply_to_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_avatar': senderAvatar,
      'message_text': messageText,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
      'reply_to_id': replyToId,
    };
  }
}

class Conversation {
  final String id;
  final String name;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime? lastMessageAt;
  final String? lastMessageText;
  final int unreadCount;

  Conversation({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.createdAt,
    this.lastMessageAt,
    this.lastMessageText,
    this.unreadCount = 0,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'].toString(),
      name: json['name'] ?? 'Chat',
      avatarUrl: json['avatar_url'],
      createdAt: DateTime.parse(json['created_at']),
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'])
          : null,
      lastMessageText: json['last_message_text'],
      unreadCount: json['unread_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
      'last_message_at': lastMessageAt?.toIso8601String(),
      'last_message_text': lastMessageText,
      'unread_count': unreadCount,
    };
  }
}

