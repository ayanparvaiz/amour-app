import '../../core/constants/api_constants.dart';
import '../models/message_model.dart';
import '../providers/api_client.dart';

class MessageRepository {
  MessageRepository({ApiClient? api}) : _api = api ?? ApiClient();

  final ApiClient _api;

  /// Everyone this member has exchanged messages with, most recent first.
  ///
  /// The server builds this by reading *every* message the member has ever
  /// sent or received and reducing it in memory — there is no pagination on
  /// this endpoint, so it gets slower as a conversation history grows.
  Future<List<ChatModel>> chats() async {
    final body = await _api.get(ApiConstants.chats);
    return ((body['chats'] as List?) ?? const [])
        .map((e) => ChatModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// A whole conversation, oldest first. Also unpaginated.
  Future<List<MessageModel>> conversation(String userId) async {
    final body = await _api.get(ApiConstants.conversation(userId));
    return ((body['messages'] as List?) ?? const [])
        .map((e) => MessageModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Saves a message and returns it as stored.
  ///
  /// This is what makes the message exist; the socket only carries it to a
  /// recipient who happens to be connected. Both are needed.
  Future<MessageModel> send({
    required String receiverId,
    required String text,
  }) async {
    final body = await _api.post(
      ApiConstants.messages,
      body: {'receiverId': receiverId, 'text': text},
    );
    return MessageModel.fromJson(Map<String, dynamic>.from(body['message'] as Map));
  }
}
