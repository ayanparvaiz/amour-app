import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/localization/translation_keys.dart';
import '../../data/models/match_model.dart';
import '../../data/models/message_model.dart';
import '../../data/providers/api_client.dart';
import '../../data/repositories/message_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/socket_service.dart';

/// One conversation.
///
/// Opened either from the list — where the other member's name and photo are
/// already known — or from a profile, where only the id is, and the rest has
/// to be fetched.
class ChatController extends GetxController {
  ChatController({
    MessageRepository? messages,
    UserRepository? users,
    ChatModel? chat,
    String? memberId,
  })  : _repo = messages ?? MessageRepository(),
        _users = users ?? UserRepository(),
        _injectedChat = chat,
        _injectedId = memberId;

  final MessageRepository _repo;
  final UserRepository _users;

  /// Passed in by a test. Otherwise both arrive as the route's argument — a
  /// ChatModel when opened from the list, a bare id when opened from a profile.
  final ChatModel? _injectedChat;
  final String? _injectedId;

  /// Resolved in [onInit]. A binding runs before the route's arguments are
  /// attached, so the constructor would read null and open the wrong thread.
  ChatModel? _seed;
  String? _memberId;

  final messages = <MessageModel>[].obs;
  final loading = true.obs;
  final error = RxnString();
  final sending = false.obs;

  /// Who this conversation is with. Starts as whatever the caller knew.
  final partner = Rxn<ChatModel>();

  final inputCtrl = TextEditingController();
  final scrollCtrl = ScrollController();

  StreamSubscription<MessageModel>? _incoming;

  String get myId => AuthService.to.user?.id ?? '';
  bool get canSend => AuthService.to.user?.canSendMessages ?? false;

  bool get isPartnerOnline {
    final id = partner.value?.userId;
    if (id == null || !Get.isRegistered<SocketService>()) return false;
    return SocketService.to.isOnline(id);
  }

  @override
  void onInit() {
    super.onInit();

    final argument = Get.arguments;
    _seed = _injectedChat ?? (argument is ChatModel ? argument : null);
    _memberId = _injectedId ??
        (argument is String ? argument : (argument is ChatModel ? argument.userId : null));

    partner.value = _seed;
    load();

    if (Get.isRegistered<SocketService>()) {
      _incoming = SocketService.to.incoming.listen(_onIncoming);
    }
  }

  @override
  void onClose() {
    _incoming?.cancel();
    inputCtrl.dispose();
    scrollCtrl.dispose();
    super.onClose();
  }

  Future<void> load() async {
    final id = _memberId;
    if (id == null || id.isEmpty) {
      loading.value = false;
      error.value = TrKeys.profileNotFoundBody.tr;
      return;
    }

    loading.value = true;
    error.value = null;
    try {
      messages.assignAll(await _repo.conversation(id));

      // Opened from a profile rather than the list: fill in who this is, so the
      // header is not blank.
      if (partner.value == null) {
        final member = await _users.profile(id);
        partner.value = _asChat(member);
      }

      _scrollToEnd();
    } on ApiException catch (e) {
      error.value = e.message;
    } finally {
      loading.value = false;
    }
  }

  ChatModel _asChat(MatchModel member) => ChatModel(
        userId: member.id,
        userName: member.name,
        userPhoto: member.photo,
        userLocation: member.location,
      );

  void _onIncoming(MessageModel message) {
    // Only what belongs to this conversation.
    if (message.senderId != _memberId) return;
    messages.add(message);
    _scrollToEnd();
  }

  Future<void> send() async {
    final text = inputCtrl.text.trim();
    final id = _memberId;
    if (text.isEmpty || id == null || sending.value) return;

    // The server refuses free accounts too; this only saves a round trip and
    // explains why before the message disappears into a failure.
    if (!canSend) {
      Get.snackbar(TrKeys.msgFreeBlockedTitle.tr, TrKeys.msgFreeBlockedBody.tr,
          snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 4));
      return;
    }

    sending.value = true;

    // Show it straight away, then replace it with what the server stored.
    final optimistic = MessageModel(
      id: 'pending-${DateTime.now().microsecondsSinceEpoch}',
      senderId: myId,
      receiverId: id,
      text: text,
      createdAt: DateTime.now(),
      pending: true,
    );
    messages.add(optimistic);
    inputCtrl.clear();
    _scrollToEnd();

    try {
      final saved = await _repo.send(receiverId: id, text: text);

      final index = messages.indexWhere((m) => m.id == optimistic.id);
      if (index >= 0) messages[index] = saved;

      // Saving is what makes it exist; this only carries it to them live.
      if (Get.isRegistered<SocketService>()) {
        SocketService.to.deliver(receiverId: id, message: saved);
      }
    } on ApiException catch (e) {
      messages.removeWhere((m) => m.id == optimistic.id);
      inputCtrl.text = text; // give the words back rather than losing them
      Get.snackbar(TrKeys.error.tr, e.message,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      sending.value = false;
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollCtrl.hasClients) return;
      scrollCtrl.animateTo(
        scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
      );
    });
  }
}
