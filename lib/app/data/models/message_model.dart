/// One message in a conversation.
class MessageModel {
  const MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.text,
    this.createdAt,
    this.pending = false,
  });

  final String id;
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime? createdAt;

  /// Shown immediately, before the server has confirmed it. Not persisted.
  final bool pending;

  bool isMine(String myId) => senderId == myId;

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        id: (json['_id'] ?? json['id'] ?? '').toString(),
        senderId: (json['senderId'] ?? '').toString(),
        receiverId: (json['receiverId'] ?? '').toString(),
        text: (json['text'] ?? '').toString(),
        createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString())?.toLocal(),
      );

  MessageModel confirmed() => MessageModel(
        id: id,
        senderId: senderId,
        receiverId: receiverId,
        text: text,
        createdAt: createdAt,
      );
}

/// A row in the conversation list, as `GET /messages/chats` returns it.
class ChatModel {
  const ChatModel({
    required this.userId,
    required this.userName,
    this.userPhoto,
    this.userLocation,
    this.lastMessage,
    this.lastMessageTime,
  });

  final String userId;
  final String userName;
  final String? userPhoto;
  final String? userLocation;
  final String? lastMessage;
  final DateTime? lastMessageTime;

  String get initial =>
      userName.trim().isEmpty ? '?' : userName.trim()[0].toUpperCase();

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    String? nonEmpty(Object? v) {
      final s = v?.toString().trim() ?? '';
      return s.isEmpty ? null : s;
    }

    return ChatModel(
      userId: (json['userId'] ?? '').toString(),
      userName: (json['userName'] ?? '').toString(),
      userPhoto: nonEmpty(json['userPhoto']),
      userLocation: nonEmpty(json['userLocation']),
      lastMessage: nonEmpty(json['lastMessage']),
      lastMessageTime:
          DateTime.tryParse((json['lastMessageTime'] ?? '').toString())?.toLocal(),
    );
  }

  ChatModel copyWith({String? lastMessage, DateTime? lastMessageTime}) =>
      ChatModel(
        userId: userId,
        userName: userName,
        userPhoto: userPhoto,
        userLocation: userLocation,
        lastMessage: lastMessage ?? this.lastMessage,
        lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      );
}
