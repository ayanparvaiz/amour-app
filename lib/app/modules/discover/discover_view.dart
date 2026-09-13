import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/localization/translation_keys.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/widgets/match_card.dart';
import '../../data/services/auth_service.dart';
import '../../routes/app_routes.dart';
import 'discover_controller.dart';
import 'discover_filter_sheet.dart';

class DiscoverView extends GetView<DiscoverController> {
  const DiscoverView({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

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
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final message = controller.error.value;
        if (message != null) {
          return _CenteredMessage(
            icon: Icons.cloud_off_rounded,
            title: message,
            actionLabel: TrKeys.homeRetry.tr,
            onAction: controller.load,
          );
        }

        if (controller.profiles.isEmpty) {
          return RefreshIndicator(
            onRefresh: controller.load,
            child: ListView(
              children: [
                const SizedBox(height: 80),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: NoMatchesYet(onRetry: controller.load),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.load,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
                  child: Text(
                    TrKeys.discoverFound
                        .trParams({'count': '${controller.profiles.length}'}),
                    style: text.bodySmall,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: _FreeLimitNotice()),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 230,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    // Tall enough for the name, location and action row with
                    // the photo filling the rest; the card no longer depends
                    // on this being exact.
                    childAspectRatio: 0.62,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      final profile = controller.profiles[i];
                      return MatchCard(
                        match: profile,
                        onTap: () => Get.toNamed(AppRoutes.profile,
                            arguments: profile.id),
                        onLike: () => controller.like(profile),
                        onPass: () => controller.pass(profile),
                        onMessage: () => Get.toNamed(AppRoutes.messages,
                            arguments: profile.id),
                      );
                    },
                    childCount: controller.profiles.length,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

/// Free accounts are cut to five results by the server, so the list ending is
/// a paywall rather than the end of the members.
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
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(kRadius),
            color: scheme.primary.withValues(alpha: 0.07),
            border: Border.all(color: scheme.primary.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Icon(Icons.lock_outline_rounded, size: 18, color: scheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(TrKeys.homeFreeLimit.tr, style: text.bodySmall),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => Get.toNamed(AppRoutes.plans),
                child: Text(TrKeys.homeUpgrade.tr),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage({
    required this.icon,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
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
            Icon(icon, size: 34, color: scheme.onSurfaceVariant),
            const SizedBox(height: 14),
            Text(title, style: text.bodyMedium, textAlign: TextAlign.center),
            if (actionLabel != null) ...[
              const SizedBox(height: 18),
              OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
