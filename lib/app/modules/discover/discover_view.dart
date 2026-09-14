import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/localization/translation_keys.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/widgets/shimmer.dart';
import '../../core/widgets/swipe_actions.dart';
import '../../core/widgets/swipe_deck.dart';
import '../../data/services/auth_service.dart';
import '../../routes/app_routes.dart';
import 'discover_controller.dart';
import 'discover_filter_sheet.dart';

class DiscoverView extends GetView<DiscoverController> {
  const DiscoverView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TrKeys.navDiscover.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            tooltip: TrKeys.discoverFilters.tr,
            onPressed: () => showDiscoverFilters(context, controller),
          ),
        ],
      ),
      drawer: const AppDrawer(current: AppRoutes.discover),
      body: Obx(() {
        if (controller.loading.value) return const _DeckSkeleton();

        final message = controller.error.value;
        if (message != null) {
          return _Centered(
            icon: Icons.cloud_off_rounded,
            title: message,
            actionLabel: TrKeys.homeRetry.tr,
            onAction: controller.load,
          );
        }

        if (controller.profiles.isEmpty) {
          return _Centered(
            icon: Icons.search_off_rounded,
            title: TrKeys.swipeDeckEmpty.tr,
            body: TrKeys.swipeDeckEmptyBody.tr,
            actionLabel: TrKeys.homeRetry.tr,
            onAction: controller.load,
          );
        }

        return const _Deck();
      }),
    );
  }
}

class _Deck extends GetView<DiscoverController> {
  const _Deck();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const _FreeLimitNotice(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Obx(() => SwipeDeck(
                    profiles: controller.profiles.toList(),
                    controller: controller.deck,
                    onSwipe: controller.onSwiped,
                    onTapProfile: (profile) =>
                        Get.toNamed(AppRoutes.profile, arguments: profile.id),
                  )),
            ),
          ),
          const _ActionBar(),
        ],
      ),
    );
  }
}

/// The action row, wired to the deck. The buttons throw the same card the same
/// way a drag does, so the two ways of deciding behave identically rather than
/// one being a shortcut.
class _ActionBar extends GetView<DiscoverController> {
  const _ActionBar();

  @override
  Widget build(BuildContext context) => Obx(() => SwipeActions(
        canSuperLike: AuthService.to.user?.canSuperLike ?? false,
        onPass: controller.passTop,
        onSuperLike: controller.superLikeTop,
        onLike: controller.likeTop,
      ));
}

/// Free accounts are cut to five profiles by the server, so the deck running
/// out is a paywall rather than the end of the members.
class _FreeLimitNotice extends StatelessWidget {
  const _FreeLimitNotice();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = AuthService.to.user;
      if (user == null || user.hasUnlimitedBrowsing) return const SizedBox.shrink();

      final text = Theme.of(context).textTheme;
      final scheme = Theme.of(context).colorScheme;

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(kRadius),
            color: scheme.primary.withValues(alpha: 0.07),
            border: Border.all(color: scheme.primary.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Icon(Icons.lock_outline_rounded, size: 17, color: scheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(TrKeys.homeFreeLimit.tr, style: text.bodySmall),
              ),
              TextButton(
                onPressed: () => Get.toNamed(AppRoutes.plans),
                child: Text(TrKeys.homeUpgrade.tr,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
      );
    });
  }
}

/// The deck's own shape while it loads: one card, and the buttons beneath.
class _DeckSkeleton extends StatelessWidget {
  const _DeckSkeleton();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Shimmer(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: ShimmerBox(radius: kRadius + 8),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 6, 20, 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ShimmerBox(
                      width: kSwipeActionLarge,
                      height: kSwipeActionLarge,
                      shape: BoxShape.circle),
                  SizedBox(width: kSwipeActionGap),
                  ShimmerBox(
                      width: kSwipeActionSmall,
                      height: kSwipeActionSmall,
                      shape: BoxShape.circle),
                  SizedBox(width: kSwipeActionGap),
                  ShimmerBox(
                      width: kSwipeActionLarge,
                      height: kSwipeActionLarge,
                      shape: BoxShape.circle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Centered extends StatelessWidget {
  const _Centered({
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
              width: 70,
              height: 70,
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
              OutlinedButton(
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
