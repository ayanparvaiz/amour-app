import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/localization/translation_keys.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/widgets/match_card.dart';
import '../../core/widgets/shimmer.dart';
import '../../data/models/match_model.dart';
import '../../routes/app_routes.dart';
import 'matches_controller.dart';

class MatchesView extends GetView<MatchesController> {
  const MatchesView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(TrKeys.matchesTitle.tr),
          bottom: TabBar(
            tabs: [
              Obx(() => Tab(
                    text:
                        '${TrKeys.matchesTabMutual.tr} (${controller.mutual.length})',
                  )),
              Obx(() => Tab(
                    text:
                        '${TrKeys.matchesTabReceived.tr} (${controller.receivedCount.value})',
                  )),
              Obx(() => Tab(
                    text: '${TrKeys.matchesTabSent.tr} (${controller.sent.length})',
                  )),
            ],
          ),
        ),
        drawer: const AppDrawer(current: AppRoutes.matches),
        body: Obx(() {
          if (controller.loading.value) {
            return const MatchGridSkeleton();
          }

          final message = controller.error.value;
          if (message != null) {
            return MatchesEmptyState(
              icon: Icons.cloud_off_rounded,
              title: message,
              actionLabel: TrKeys.homeRetry.tr,
              onAction: controller.load,
            );
          }

          return TabBarView(
            children: [
              _MutualTab(),
              _ReceivedTab(),
              _SentTab(),
            ],
          );
        }),
      ),
    );
  }
}

class _MutualTab extends GetView<MatchesController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.mutual.isEmpty) {
        return MatchesEmptyState(
          icon: Icons.auto_awesome_rounded,
          title: TrKeys.matchesNoneTitle.tr,
          body: TrKeys.matchesNoneBody.tr,
          actionLabel: TrKeys.matchesStartDiscovering.tr,
          onAction: () => Get.toNamed(AppRoutes.discover),
        );
      }

      return MatchesGrid(
        members: controller.mutual,
        onRefresh: controller.load,
        // Already matched, so there is nothing left to like or pass — only to
        // start a conversation.
        buildActions: (member) => MatchCardActions(
          onMessage: () => Get.toNamed(AppRoutes.chat, arguments: member.id),
        ),
      );
    });
  }
}

class _ReceivedTab extends GetView<MatchesController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final count = controller.receivedCount.value;

      if (count == 0) {
        return MatchesEmptyState(
          icon: Icons.favorite_border_rounded,
          title: TrKeys.matchesNoLikesTitle.tr,
          body: TrKeys.matchesNoLikesBody.tr,
        );
      }

      // The server sends an empty list with a real count to free accounts, so
      // this is the one tab that can have people in it and nothing to show.
      if (!controller.canSeeReceived) {
        return ReceivedLikesPaywall(count: count);
      }

      return MatchesGrid(
        members: controller.received,
        onRefresh: controller.load,
        buildActions: (member) => MatchCardActions(
          onLike: () => controller.like(member),
          onPass: () => controller.pass(member),
          onMessage: () => Get.toNamed(AppRoutes.chat, arguments: member.id),
        ),
      );
    });
  }
}

class _SentTab extends GetView<MatchesController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.sent.isEmpty) {
        return MatchesEmptyState(
          icon: Icons.send_rounded,
          title: TrKeys.matchesNoSentTitle.tr,
          body: TrKeys.matchesNoSentBody.tr,
          actionLabel: TrKeys.matchesStartDiscovering.tr,
          onAction: () => Get.toNamed(AppRoutes.discover),
        );
      }

      // Nothing to act on — the like is already sent.
      return MatchesGrid(members: controller.sent, onRefresh: controller.load);
    });
  }
}

/// The three action callbacks a card in this screen may carry.
class MatchCardActions {
  const MatchCardActions({this.onLike, this.onPass, this.onMessage});

  final VoidCallback? onLike;
  final VoidCallback? onPass;
  final VoidCallback? onMessage;
}

/// Shared grid, so the three tabs stay identical in spacing and card size.
class MatchesGrid extends StatelessWidget {
  const MatchesGrid({
    super.key,
    required this.members,
    this.onRefresh,
    this.buildActions,
  });

  final List<MatchModel> members;
  final Future<void> Function()? onRefresh;
  final MatchCardActions Function(MatchModel)? buildActions;

  @override
  Widget build(BuildContext context) {
    final grid = GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 230,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.62,
      ),
      itemCount: members.length,
      itemBuilder: (_, i) {
        final member = members[i];
        final actions = buildActions?.call(member);
        return MatchCard(
          match: member,
          onTap: () => Get.toNamed(AppRoutes.profile, arguments: member.id),
          onLike: actions?.onLike,
          onPass: actions?.onPass,
          onMessage: actions?.onMessage,
        );
      },
    );

    if (onRefresh == null) return grid;
    return RefreshIndicator(onRefresh: onRefresh!, child: grid);
  }
}

/// What free accounts see instead of the received likes: the number waiting,
/// and the way to unlock them.
class ReceivedLikesPaywall extends StatelessWidget {
  const ReceivedLikesPaywall({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.primary.withValues(alpha: 0.12),
                border: Border.all(color: scheme.primary.withValues(alpha: 0.3)),
              ),
              child: Icon(Icons.favorite_rounded, size: 32, color: scheme.primary),
            ),
            const SizedBox(height: 20),
            Text(TrKeys.matchesLockedTitle.tr,
                style: text.headlineMedium, textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text(
              count == 1
                  ? TrKeys.matchesLockedOne.tr
                  : TrKeys.matchesLockedMany.trParams({'count': '$count'}),
              style: text.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Get.toNamed(AppRoutes.plans),
              child: Text(TrKeys.matchesSeePlans.tr),
            ),
          ],
        ),
      ),
    );
  }
}

class MatchesEmptyState extends StatelessWidget {
  const MatchesEmptyState({
    super.key,
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
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
