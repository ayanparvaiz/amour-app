import 'dart:async';

import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../core/constants/api_constants.dart';
import '../models/message_model.dart';

/// The live half of messaging.
///
/// The socket only *delivers*; it never stores. A message exists because it was
/// posted to the API — the socket carries a copy to the other person if they
/// happen to be connected, and does nothing if they are not. So a screen that
/// sends must do both, and a screen that receives must not assume the socket
/// saw everything while it was away.
///
/// The server's contract, from Server.js:
/// ```
///   emit 'register' <userId>      after connecting, to be findable
///   on   'online_users' [ids]     broadcast whenever anyone joins or leaves
///   emit 'sendMessage' {receiverId, message}
///   on   'receiveMessage' message
/// ```
///
/// Presence lives in a plain Map in the Node process, so it resets when the
/// server restarts and would not survive a second instance.
class SocketService extends GetxService {
  static SocketService get to => Get.find();

  io.Socket? _socket;

  /// Ids of everyone currently connected, as last broadcast by the server.
  final onlineUsers = <String>{}.obs;

  final connected = false.obs;

  final _incoming = StreamController<MessageModel>.broadcast();

  /// Messages arriving from other members. Broadcast, so both the conversation
  /// list and an open chat can listen at once.
  Stream<MessageModel> get incoming => _incoming.stream;

  Future<SocketService> init() async => this;

  bool isOnline(String userId) => onlineUsers.contains(userId);

  /// The member this socket is registered as, kept so a reconnect can say who
  /// it is again without asking anyone.
  String? _userId;

  /// Opens the connection for [userId]. Safe to call repeatedly — re-registering
  /// the same id is what the server expects after a reconnect.
  ///
  /// The id is passed in rather than read from AuthService: this service is
  /// created first, and AuthService opens the socket from inside its own
  /// `init()`, before GetX has finished registering it.
  void connect(String userId) {
    if (userId.isEmpty) return;
    _userId = userId;

    if (_socket != null) {
      // Already built. Make sure it is up and the server knows who we are.
      if (_socket!.connected) {
        _socket!.emit('register', userId);
      } else {
        _socket!.connect();
      }
      return;
    }

    final socket = io.io(
      ApiConstants.socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableReconnection()
          .enableForceNew()
          .build(),
    );

    socket.onConnect((_) {
      connected.value = true;
      // Identify on every connect, not just the first: a reconnect gets a new
      // socket id and the server's map is keyed by it.
      final id = _userId;
      if (id != null) socket.emit('register', id);
    });

    socket.onDisconnect((_) {
      connected.value = false;
      onlineUsers.clear();
    });

    socket.on('online_users', (data) {
      if (data is List) {
        onlineUsers
          ..clear()
          ..addAll(data.map((e) => e.toString()));
      }
    });

    socket.on('receiveMessage', (data) {
      if (data is Map) {
        _incoming.add(MessageModel.fromJson(Map<String, dynamic>.from(data)));
      }
    });

    _socket = socket;
  }

  /// Hands a saved message to the recipient. Call it *after* the API has
  /// stored the message, never instead of.
  void deliver({required String receiverId, required MessageModel message}) {
    _socket?.emit('sendMessage', {
      'receiverId': receiverId,
      'message': {
        '_id': message.id,
        'senderId': message.senderId,
        'receiverId': message.receiverId,
        'text': message.text,
        'createdAt': message.createdAt?.toUtc().toIso8601String(),
      },
    });
  }

  void disconnect() {
    _socket?.dispose();
    _socket = null;
    _userId = null;
    connected.value = false;
    onlineUsers.clear();
  }

  @override
  void onClose() {
    disconnect();
    _incoming.close();
    super.onClose();
  }
}
