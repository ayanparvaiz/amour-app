import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/localization/translation_keys.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/widgets/match_card.dart';
import '../../core/widgets/shimmer.dart';
import '../../data/services/auth_service.dart';
import '../../routes/app_routes.dart';
import 'home_controller.dart';
import 'home_widgets.dart';

/// The screen answers one question: what is waiting for me?
///
/// So it leads with the people who have already liked this member, then with
/// the way in to the deck, and only then with profiles to browse. The old
/// layout opened with a plan badge and closed with three tiles that repeated
/// the drawer — neither told anybody anything.
class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TrKeys.appName.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            tooltip: TrKeys.navDiscover.tr,
            onPressed: () => Get.toNamed(AppRoutes.discover),
          ),
        ],
      ),
      drawer: const AppDrawer(current: AppRoutes.home),
      body: RefreshIndicator(
        onRefresh: controller.refreshAll,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
          children: [
            const _Greeting(),
            const SizedBox(height: 18),
            const _Likes(),
            DiscoverHero(onTap: () => Get.toNamed(AppRoutes.discover)),
            const SizedBox(height: 24),
            const _MatchesSection(),
            const _Upgrade(),
          ],
        ),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = AuthService.to.user;
      final paid = user != null && (user.tier.isPaid || user.isAdmin);

      return HomeGreeting(
        name: user?.name ?? '',
        location: user?.location,
        planLabel: paid ? (user.planName ?? user.tier.label) : null,
        onTapPlan: () => Get.toNamed(AppRoutes.plans),
      );
    });
  }
}

class _Likes extends GetView<HomeController> {
  const _Likes();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final count = controller.likedByCount.value;
      // Nothing to say while the call is in flight, and nothing to say when
      // nobody has liked this member — an empty card would be worse than none.
      if (controller.loading.value || count == 0) return const SizedBox.shrink();

      final unlocked = controller.canSeeWhoLikedYou;

      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: LikesCard(
          count: count,
          unlocked: unlocked,
          faces: unlocked ? controller.likedBy.toList() : const [],
          onTap: () =>
              Get.toNamed(unlocked ? AppRoutes.matches : AppRoutes.plans),
        ),
      );
    });
  }
}

class _MatchesSection extends GetView<HomeController> {
  const _MatchesSection();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('✨', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(TrKeys.homePerfectMatches.tr,
                  style: text.headlineMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
            TextButton(
              onPressed: () => Get.toNamed(AppRoutes.discover),
              child: Text(TrKeys.homeSeeAll.tr, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.loading.value) return const MatchRowSkeleton();

          final message = controller.error.value;
          if (message != null) {
            return _ErrorBox(message: message, onRetry: controller.load);
          }

          if (controller.matches.isEmpty) {
            return NoMatchesYet(onRetry: controller.load);
          }

          return MatchRow(
            matches: controller.matches.toList(),
            onTap: (match) =>
                Get.toNamed(AppRoutes.profile, arguments: match.id),
          );
        }),
      ],
    );
  }
}

class _Upgrade extends StatelessWidget {
  const _Upgrade();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = AuthService.to.user;
      if (user == null || user.tier.isPaid || user.isAdmin) {
        return const SizedBox.shrink();
      }

      return Padding(
        padding: const EdgeInsets.only(top: 24),
        child: UpgradeCard(
          planLabel: user.planName ?? user.tier.label,
          onTap: () => Get.toNamed(AppRoutes.plans),
        ),
      );
    });
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kRadius),
        border: Border.all(color: scheme.error.withValues(alpha: 0.4)),
        color: scheme.error.withValues(alpha: 0.06),
      ),
      child: Column(
        children: [
          Icon(Icons.cloud_off_rounded, size: 30, color: scheme.error),
          const SizedBox(height: 10),
          Text(message, style: text.bodySmall, textAlign: TextAlign.center),
          const SizedBox(height: 14),
          OutlinedButton(onPressed: onRetry, child: Text(TrKeys.homeRetry.tr)),
        ],
      ),
    );
  }
}
