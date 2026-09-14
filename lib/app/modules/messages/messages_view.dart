import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/localization/translation_keys.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/widgets/member_avatar.dart';
import '../../data/models/message_model.dart';
import '../../routes/app_routes.dart';
import 'messages_controller.dart';

class MessagesView extends GetView<MessagesController> {
  const MessagesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(TrKeys.navMessages.tr)),
      drawer: const AppDrawer(current: AppRoutes.messages),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.discover),
        tooltip: TrKeys.matchesStartDiscovering.tr,
        child: const Icon(Icons.chat_rounded),
      ),
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final message = controller.error.value;
        if (message != null) {
          return _Empty(
            icon: Icons.cloud_off_rounded,
            title: message,
            actionLabel: TrKeys.homeRetry.tr,
            onAction: controller.load,
          );
        }

        if (controller.chats.isEmpty) {
          return RefreshIndicator(
            onRefresh: controller.load,
            child: ListView(
              children: [
                const SizedBox(height: 90),
                // No button here: starting a conversation is the floating
                // action, so it sits in the same place whether the list is
                // empty or full.
                _Empty(
                  icon: Icons.forum_outlined,
                  title: TrKeys.msgNoChatsTitle.tr,
                  body: TrKeys.msgNoChatsBody.tr,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.load,
          child: ListView.separated(
            itemCount: controller.chats.length,
            separatorBuilder: (_, _) =>
                const Divider(height: 1, indent: 78, endIndent: 16),
            itemBuilder: (_, i) => ChatRow(
              chat: controller.chats[i],
              online: controller.isOnline(controller.chats[i].userId),
              onTap: () => Get.toNamed(
                AppRoutes.chat,
                arguments: controller.chats[i],
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// One conversation in the list.
class ChatRow extends StatelessWidget {
  const ChatRow({
    super.key,
    required this.chat,
    required this.online,
    this.onTap,
  });

  final ChatModel chat;
  final bool online;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Stack(
        children: [
          MemberAvatar(initial: chat.initial, photo: chat.userPhoto, size: 50),
          if (online)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 13,
                height: 13,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.online,
                  border: Border.all(color: scheme.surface, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        chat.userName,
        style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: chat.lastMessage == null
          ? null
          : Text(
              chat.lastMessage!,
              style: TextStyle(fontSize: 13.5, color: scheme.onSurfaceVariant),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
      trailing: chat.lastMessageTime == null
          ? null
          : Text(
              formatChatTime(chat.lastMessageTime!),
              style: TextStyle(fontSize: 11.5, color: scheme.onSurfaceVariant),
            ),
    );
  }
}

/// Time for the list: the clock today, a weekday this week, a date beyond that.
String formatChatTime(DateTime when, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  final today = DateTime(reference.year, reference.month, reference.day);
  final day = DateTime(when.year, when.month, when.day);
  final difference = today.difference(day).inDays;

  String two(int n) => n.toString().padLeft(2, '0');

  if (difference == 0) return '${two(when.hour)}:${two(when.minute)}';
  if (difference == 1) return TrKeys.msgYesterday.tr;
  if (difference < 7) return _weekday(when.weekday);
  return '${two(when.day)}/${two(when.month)}';
}

String _weekday(int weekday) => switch (weekday) {
      DateTime.monday => 'lun.',
      DateTime.tuesday => 'mar.',
      DateTime.wednesday => 'mer.',
      DateTime.thursday => 'jeu.',
      DateTime.friday => 'ven.',
      DateTime.saturday => 'sam.',
      _ => 'dim.',
    };

class _Empty extends StatelessWidget {
  const _Empty({
    required this.icon,
    required this.title,
    this.body,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? body;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.surfaceContainerHighest,
              ),
              child: Icon(icon, size: 30, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 18),
            Text(title, style: text.headlineMedium, textAlign: TextAlign.center),
            if (body != null) ...[
              const SizedBox(height: 8),
              Text(body!, style: text.bodySmall, textAlign: TextAlign.center),
            ],
            if (actionLabel != null) ...[
              const SizedBox(height: 22),
              FilledButton(
                onPressed: onAction,
                child: Text(actionLabel!, overflow: TextOverflow.ellipsis),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
