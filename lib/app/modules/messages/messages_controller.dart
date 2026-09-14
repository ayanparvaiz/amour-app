import 'dart:async';

import 'package:get/get.dart';

import '../../data/models/message_model.dart';
import '../../data/providers/api_client.dart';
import '../../data/repositories/message_repository.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/socket_service.dart';

/// The list of conversations.
class MessagesController extends GetxController {
  MessagesController({MessageRepository? repository})
      : _repo = repository ?? MessageRepository();

  final MessageRepository _repo;

  final chats = <ChatModel>[].obs;
  final loading = true.obs;
  final error = RxnString();

  StreamSubscription<MessageModel>? _incoming;

  @override
  void onInit() {
    super.onInit();
    load();

    // A message arriving while this screen is open should move its row to the
    // top rather than wait for the next manual refresh.
    if (Get.isRegistered<SocketService>()) {
      _incoming = SocketService.to.incoming.listen(_onIncoming);
    }
  }

  @override
  void onClose() {
    _incoming?.cancel();
    super.onClose();
  }

  Future<void> load() async {
    loading.value = true;
    error.value = null;
    try {
      chats.assignAll(await _repo.chats());
    } on ApiException catch (e) {
      error.value = e.message;
    } finally {
      loading.value = false;
    }
  }

  void _onIncoming(MessageModel message) {
    final myId = AuthService.to.user?.id;
    if (myId == null) return;

    final otherId = message.senderId == myId ? message.receiverId : message.senderId;
    final index = chats.indexWhere((c) => c.userId == otherId);

    if (index < 0) {
      // First message from somebody who is not in the list yet. Only the
      // server knows their name and photo, so re-read rather than invent a row.
      load();
      return;
    }

    final updated = chats[index].copyWith(
      lastMessage: message.text,
      lastMessageTime: message.createdAt ?? DateTime.now(),
    );
    chats
      ..removeAt(index)
      ..insert(0, updated);
  }

  bool isOnline(String userId) =>
      Get.isRegistered<SocketService>() && SocketService.to.isOnline(userId);
}
