import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/localization/translation_keys.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_drawer.dart';
import '../../data/models/plan_model.dart';
import '../../routes/app_routes.dart';
import 'plans_controller.dart';

class PlansView extends GetView<PlansController> {
  const PlansView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(TrKeys.navPlans.tr)),
      drawer: const AppDrawer(current: AppRoutes.plans),
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.isAdmin) return const _AdminNotice();

        final message = controller.error.value;
        if (message != null) return _Message(text: message, onRetry: controller.load);

        if (controller.plans.isEmpty) {
          return _Message(text: TrKeys.planEmpty.tr, onRetry: controller.load);
        }

        return RefreshIndicator(
          onRefresh: controller.load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
            children: const [
              _Intro(),
              SizedBox(height: 20),
              _TierTabs(),
              SizedBox(height: 18),
              _DurationCards(),
              SizedBox(height: 24),
              _SubscribeButton(),
              SizedBox(height: 30),
              _FeatureTable(),
            ],
          ),
        );
      }),
    );
  }
}

class _Intro extends GetView<PlansController> {
  const _Intro();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Obx(() {
      final tier = controller.currentTier;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(TrKeys.planTitle.tr, style: text.headlineLarge),
          const SizedBox(height: 6),
          Text(TrKeys.planSubtitle.tr, style: text.bodySmall),
          if (tier.isPaid) ...[
            const SizedBox(height: 12),
            _Chip(label: '${TrKeys.planCurrent.tr} · ${tier.label}'),
          ],
        ],
      );
    });
  }
}

class _TierTabs extends GetView<PlansController> {
  const _TierTabs();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Obx(() {
      final tiers = controller.tiers;
      if (tiers.length < 2) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            for (final tier in tiers)
              Expanded(
                child: _TierTab(
                  tier: tier,
                  selected: controller.selectedTier.value == tier,
                  onTap: () => controller.chooseTier(tier),
                ),
              ),
          ],
        ),
      );
    });
  }
}

class _TierTab extends StatelessWidget {
  const _TierTab({
    required this.tier,
    required this.selected,
    required this.onTap,
  });

  final PlanTier tier;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: selected ? scheme.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          child: Text(
            tier.label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : scheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _DurationCards extends GetView<PlansController> {
  const _DurationCards();

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
          children: [
            for (final plan in controller.tierPlans)
              _DurationCard(
                plan: plan,
                selected: controller.selectedPlan.value?.id == plan.id,
                onTap: () => controller.choosePlan(plan),
              ),
          ],
        ));
  }
}

class _DurationCard extends GetView<PlansController> {
  const _DurationCard({
    required this.plan,
    required this.selected,
    required this.onTap,
  });

  final PlanModel plan;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final saving = controller.savingPercent(plan);
    final recommended = plan.duration == 1 && plan.durationUnit == 'month';
    final best = saving != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: selected ? scheme.primary.withValues(alpha: 0.06) : scheme.surface,
        borderRadius: BorderRadius.circular(kRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(kRadius),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(kRadius),
              border: Border.all(
                color: selected ? scheme.primary : scheme.outline,
                width: selected ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (best || recommended) ...[
                  _Chip(label: best ? TrKeys.planBest.tr : TrKeys.planRecommended.tr),
                  const SizedBox(height: 10),
                ],
                Row(
                  children: [
                    Icon(
                      selected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 20,
                      color: selected ? scheme.primary : scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.durationLabel,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            plan.priceLabel,
                            style: TextStyle(
                                fontSize: 12.5, color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          controller.isWeekly(plan)
                              ? TrKeys.planPerWeek
                                  .trParams({'price': controller.unitPrice(plan)})
                              : TrKeys.planPerMonth
                                  .trParams({'price': controller.unitPrice(plan)}),
                          style: const TextStyle(
                              fontSize: 14.5, fontWeight: FontWeight.w700),
                        ),
                        if (saving != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            TrKeys.planSave.trParams({'percent': '$saving'}),
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.online,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SubscribeButton extends GetView<PlansController> {
  const _SubscribeButton();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final plan = controller.selectedPlan.value;
      if (plan == null) return const SizedBox.shrink();

      if (controller.isCurrent(plan)) {
        return OutlinedButton(
          onPressed: null,
          child: Text(TrKeys.planCurrent.tr, overflow: TextOverflow.ellipsis),
        );
      }

      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => controller.purchase(plan),
              child: Text(
                TrKeys.planChoose.trParams({'plan': plan.tier.label}),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const _NotYetNotice(),
        ],
      );
    });
  }
}

/// Says plainly that nothing can be bought here yet, rather than letting the
/// button look live and fail.
class _NotYetNotice extends StatelessWidget {
  const _NotYetNotice();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kRadius),
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: scheme.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(TrKeys.planUnavailableTitle.tr,
                    style: text.labelLarge),
                const SizedBox(height: 3),
                Text(TrKeys.planUnavailableBody.tr, style: text.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// What each tier grants, as the server enforces it.
class _FeatureTable extends GetView<PlansController> {
  const _FeatureTable();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Obx(() {
      final tier = controller.selectedTier.value;

      bool granted(TierFeature feature) => switch (tier) {
            PlanTier.essential => feature.essential,
            PlanTier.premium => feature.premium,
            PlanTier.prestige => feature.prestige,
            PlanTier.free => feature.free,
          };

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${TrKeys.planWhatYouGet.tr} · ${tier.label}',
              style: text.headlineMedium),
          const SizedBox(height: 14),
          for (final feature in kTierFeatures)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Icon(
                    granted(feature)
                        ? Icons.check_circle_rounded
                        : Icons.remove_circle_outline_rounded,
                    size: 19,
                    color: granted(feature)
                        ? AppColors.online
                        : scheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feature.labelKey.tr,
                      style: TextStyle(
                        fontSize: 14.5,
                        color: granted(feature)
                            ? scheme.onSurface
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }
}

class _AdminNotice extends StatelessWidget {
  const _AdminNotice();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.workspace_premium_rounded,
                size: 44, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(TrKeys.planAdminTitle.tr,
                style: text.headlineMedium, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(TrKeys.planAdminBody.tr,
                style: text.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: scheme.primary,
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, this.onRetry});

  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 32, color: scheme.onSurfaceVariant),
            const SizedBox(height: 14),
            Text(text, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 18),
              OutlinedButton(onPressed: onRetry, child: Text(TrKeys.homeRetry.tr)),
            ],
          ],
        ),
      ),
    );
  }
}
