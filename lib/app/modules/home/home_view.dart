import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/localization/translation_keys.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/widgets/match_card.dart';
import '../../data/services/auth_service.dart';
import '../../routes/app_routes.dart';
import 'home_controller.dart';

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
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            const _Greeting(),
            const SizedBox(height: 20),
            const _PlanCard(),
            const SizedBox(height: 26),
            const _MatchesSection(),
            const SizedBox(height: 26),
            const _QuickActions(),
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
    final text = Theme.of(context).textTheme;

    return Obx(() {
      final user = AuthService.to.user;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(TrKeys.greeting.trParams({'name': user?.name ?? ''}),
              style: text.headlineLarge),
          if (user?.location != null) ...[
            const SizedBox(height: 4),
            Text(user!.location!, style: text.bodySmall),
          ],
        ],
      );
    });
  }
}

/// The member's plan and what it currently allows. Free accounts get a route
/// to the pricing page instead of a list of ticks.
class _PlanCard extends StatelessWidget {
  const _PlanCard();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Obx(() {
      final user = AuthService.to.user;
      if (user == null) return const SizedBox.shrink();

      final paid = user.tier.isPaid || user.isAdmin;

      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(kRadius),
          gradient: paid ? AppColors.heroGradient : null,
          color: paid ? null : scheme.surface,
          border: paid ? null : Border.all(color: scheme.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.workspace_premium_rounded,
                    size: 20, color: paid ? Colors.white : scheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    user.planName ?? user.tier.label,
                    style: text.titleMedium?.copyWith(
                        color: paid ? Colors.white : scheme.onSurface),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (paid)
              Text(
                TrKeys.entSuperLikesWithQuota
                    .trParams({'count': '${user.weeklySuperLikes}'}),
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9), fontSize: 13.5),
              )
            else ...[
              Text(TrKeys.homeFreeLimit.tr, style: text.bodySmall),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Get.toNamed(AppRoutes.plans),
                  child: Text(TrKeys.homeUpgrade.tr),
                ),
              ),
            ],
          ],
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
              child: Text(TrKeys.homePerfectMatches.tr, style: text.headlineMedium),
            ),
            TextButton(
              onPressed: () => Get.toNamed(AppRoutes.discover),
              child: Text(TrKeys.homeSeeAll.tr),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.loading.value) {
            return const SizedBox(
              height: 240,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final message = controller.error.value;
          if (message != null) {
            return _ErrorBox(message: message, onRetry: controller.load);
          }

          if (controller.matches.isEmpty) {
            return NoMatchesYet(onRetry: controller.load);
          }

          return SizedBox(
            height: 246,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: controller.matches.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final match = controller.matches[i];
                return MatchCard(
                  match: match,
                  onTap: () => Get.toNamed(AppRoutes.profile, arguments: match.id),
                );
              },
            ),
          );
        }),
      ],
    );
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

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionTile(
            icon: Icons.favorite_border_rounded,
            label: TrKeys.navMatches.tr,
            route: AppRoutes.matches,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionTile(
            icon: Icons.chat_bubble_outline_rounded,
            label: TrKeys.navMessages.tr,
            route: AppRoutes.messages,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionTile(
            icon: Icons.person_outline_rounded,
            label: TrKeys.navProfile.tr,
            route: AppRoutes.profile,
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.icon, required this.label, required this.route});

  final IconData icon;
  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(kRadius),
      child: InkWell(
        onTap: () => Get.toNamed(route),
        borderRadius: BorderRadius.circular(kRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(kRadius),
            border: Border.all(color: scheme.outline),
          ),
          child: Column(
            children: [
              Icon(icon, size: 22, color: scheme.primary),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
