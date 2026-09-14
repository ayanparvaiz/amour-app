import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/localization/translation_keys.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/member_avatar.dart';
import '../../data/models/message_model.dart';
import '../../routes/app_routes.dart';
import 'chat_controller.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const _Header()),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.loading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final message = controller.error.value;
              if (message != null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(message, textAlign: TextAlign.center),
                  ),
                );
              }

              if (controller.messages.isEmpty) return const _EmptyConversation();

              return ListView.builder(
                controller: controller.scrollCtrl,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                itemCount: controller.messages.length,
                itemBuilder: (_, i) {
                  final message = controller.messages[i];
                  final previous = i == 0 ? null : controller.messages[i - 1];
                  return MessageBubble(
                    message: message,
                    mine: message.isMine(controller.myId),
                    // A date only when the day changes, not on every message.
                    daySeparator: _daySeparator(previous, message),
                  );
                },
              );
            }),
          ),
          const _Composer(),
        ],
      ),
    );
  }

  String? _daySeparator(MessageModel? previous, MessageModel current) {
    final when = current.createdAt;
    if (when == null) return null;
    final before = previous?.createdAt;
    if (before != null &&
        before.year == when.year &&
        before.month == when.month &&
        before.day == when.day) {
      return null;
    }
    return formatMessageDay(when);
  }
}

class _Header extends GetView<ChatController> {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Obx(() {
      final partner = controller.partner.value;
      if (partner == null) return const SizedBox.shrink();
      final online = controller.isPartnerOnline;

      return InkWell(
        onTap: () => Get.toNamed(AppRoutes.profile, arguments: partner.userId),
        child: Row(
          children: [
            MemberAvatar(
                initial: partner.initial, photo: partner.userPhoto, size: 38),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    partner.userName,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (online)
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.online,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(TrKeys.msgOnline.tr,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.online,
                              fontWeight: FontWeight.w600,
                            )),
                      ],
                    )
                  else if (partner.userLocation != null)
                    Text(
                      partner.userLocation!,
                      style:
                          TextStyle(fontSize: 11.5, color: scheme.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.mine,
    this.daySeparator,
  });

  final MessageModel message;
  final bool mine;
  final String? daySeparator;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = Radius.circular(kRadius + 4);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (daySeparator != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  daySeparator!,
                  style:
                      TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
                ),
              ),
            ),
          ),
        Align(
          alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.76,
            ),
            decoration: BoxDecoration(
              color: mine ? scheme.primary : scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.only(
                topLeft: radius,
                topRight: radius,
                bottomLeft: mine ? radius : const Radius.circular(4),
                bottomRight: mine ? const Radius.circular(4) : radius,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  message.text,
                  style: TextStyle(
                    fontSize: 14.5,
                    height: 1.35,
                    color: mine ? Colors.white : scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message.pending
                      ? TrKeys.msgSending.tr
                      : formatMessageTime(message.createdAt),
                  style: TextStyle(
                    fontSize: 10,
                    color: mine
                        ? Colors.white.withValues(alpha: 0.75)
                        : scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Composer extends GetView<ChatController> {
  const _Composer();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Obx(() {
      // Free accounts can read but not write — the server refuses the post, so
      // the input is replaced by the reason rather than failing on send.
      if (!controller.canSend) return const _UpgradeToWrite();

      return SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
          decoration: BoxDecoration(
            color: scheme.surface,
            border: Border(top: BorderSide(color: scheme.outline)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: controller.inputCtrl,
                  minLines: 1,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => controller.send(),
                  decoration: InputDecoration(
                    hintText: TrKeys.msgInputHint.tr,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: controller.sending.value ? null : controller.send,
                tooltip: TrKeys.msgSend.tr,
                icon: controller.sending.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.send_rounded, size: 19),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _UpgradeToWrite extends StatelessWidget {
  const _UpgradeToWrite();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        decoration: BoxDecoration(
          color: scheme.primary.withValues(alpha: 0.06),
          border: Border(top: BorderSide(color: scheme.outline)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.lock_outline_rounded, size: 18, color: scheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(TrKeys.msgFreeBlockedTitle.tr,
                      style: text.titleMedium),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(TrKeys.msgFreeBlockedBody.tr, style: text.bodySmall),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Get.toNamed(AppRoutes.plans),
                child: Text(TrKeys.homeUpgrade.tr,
                    overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyConversation extends StatelessWidget {
  const _EmptyConversation();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.waving_hand_outlined,
                size: 34, color: scheme.onSurfaceVariant),
            const SizedBox(height: 14),
            Text(TrKeys.msgStartConversation.tr,
                style: text.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(TrKeys.msgWriteSomething.tr,
                style: text.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

String formatMessageTime(DateTime? when) {
  if (when == null) return '';
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(when.hour)}:${two(when.minute)}';
}

/// Label for the divider between days inside a conversation.
String formatMessageDay(DateTime when, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  final today = DateTime(reference.year, reference.month, reference.day);
  final day = DateTime(when.year, when.month, when.day);
  final difference = today.difference(day).inDays;

  if (difference == 0) return TrKeys.msgToday.tr;
  if (difference == 1) return TrKeys.msgYesterday.tr;

  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(when.day)}/${two(when.month)}/${when.year}';
}
