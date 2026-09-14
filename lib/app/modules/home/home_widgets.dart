import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/localization/translation_keys.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/member_avatar.dart';
import '../../core/widgets/swipe_card.dart';
import '../../data/models/match_model.dart';

/// The parts the home screen is built from, none of which know about the
/// controller or the session — HomeView passes the data and the callbacks in.
///
/// That is what makes them testable at 320px in French, which is where the
/// layout breaks if it is going to.

/// Name and town, with the plan as a quiet pill beside them when there is one.
///
/// A member who has already paid does not need to be sold to: the plan used to
/// take a full-width gradient banner at the top of the screen to say something
/// they already knew.
class HomeGreeting extends StatelessWidget {
  const HomeGreeting({
    super.key,
    required this.name,
    this.location,
    this.planLabel,
    this.onTapPlan,
  });

  final String name;
  final String? location;

  /// Shown only for paid accounts. Free members get the upgrade card instead,
  /// at the foot of the screen.
  final String? planLabel;
  final VoidCallback? onTapPlan;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Two to one: whatever the plan is called, the greeting keeps most of
        // the row. The pill takes only what it needs out of its third.
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                TrKeys.greeting.trParams({'name': name}),
                style: text.headlineLarge,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (location != null) ...[
                const SizedBox(height: 3),
                Text(location!,
                    style: text.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ],
          ),
        ),
        if (planLabel != null) ...[
          const SizedBox(width: 10),
          Flexible(child: _PlanPill(label: planLabel!, onTap: onTapPlan)),
        ],
      ],
    );
  }
}

class _PlanPill extends StatelessWidget {
  const _PlanPill({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          gradient: AppColors.heroGradient,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.workspace_premium_rounded,
                size: 14, color: Colors.white),
            const SizedBox(width: 5),
            // Shortens rather than pushing the greeting off the screen.
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Who has already liked this member — the one thing worth opening the app for.
///
/// The count reaches everybody; the faces only paid accounts, because the
/// server blanks that list otherwise. So a free member is told how many are
/// waiting and sent to the plans, and a paid one is sent to the list itself.
class LikesCard extends StatelessWidget {
  const LikesCard({
    super.key,
    required this.count,
    required this.unlocked,
    required this.onTap,
    this.faces = const [],
  });

  final int count;
  final bool unlocked;
  final VoidCallback onTap;
  final List<MatchModel> faces;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(kRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(kRadius),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 13, 12, 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(kRadius),
            border: Border.all(color: scheme.primary.withValues(alpha: 0.28)),
          ),
          child: Row(
            children: [
              Icon(unlocked ? Icons.favorite_rounded : Icons.lock_rounded,
                  size: 20, color: scheme.primary),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      count == 1
                          ? TrKeys.homeLikedYouOne.tr
                          : TrKeys.homeLikedYouMany
                              .trParams({'count': '$count'}),
                      style: const TextStyle(
                          fontSize: 14.5, fontWeight: FontWeight.w700),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      unlocked
                          ? TrKeys.homeLikedYouAction.tr
                          : TrKeys.matchesSeePlans.tr,
                      style: TextStyle(
                          fontSize: 12.5,
                          color: scheme.primary,
                          fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (unlocked && faces.isNotEmpty) ...[
                const SizedBox(width: 8),
                _FacePile(faces: faces),
              ],
              Icon(Icons.chevron_right_rounded,
                  size: 22, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

/// A few faces, overlapping, so the number has people behind it.
class _FacePile extends StatelessWidget {
  const _FacePile({required this.faces});

  final List<MatchModel> faces;

  static const double _size = 30;
  static const double _overlap = 10;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: _size + (faces.length - 1) * (_size - _overlap),
      height: _size,
      child: Stack(
        children: [
          for (var i = 0; i < faces.length; i++)
            Positioned(
              left: i * (_size - _overlap),
              child: MemberAvatar(
                initial: faces[i].initial,
                photo: faces[i].photo,
                size: _size,
                borderColor: scheme.surface,
              ),
            ),
        ],
      ),
    );
  }
}

/// The way into the deck. Swiping is what the app is for, and the only route
/// to it used to be a small magnifier in the corner of the bar.
class DiscoverHero extends StatelessWidget {
  const DiscoverHero({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(kRadius),
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      shadowColor: AppColors.primary.withValues(alpha: 0.35),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 17, 14, 17),
          decoration: const BoxDecoration(gradient: AppColors.heroGradient),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.22),
                ),
                child: const Icon(Icons.style_rounded,
                    size: 21, color: Colors.white),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      TrKeys.matchesStartDiscovering.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      TrKeys.homeDiscoverBody.tr,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontSize: 12.5,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward_rounded,
                  size: 20, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

/// The profiles, dealt as the same cards the deck uses so the two screens
/// cannot drift apart — only smaller.
class MatchRow extends StatelessWidget {
  const MatchRow({super.key, required this.matches, required this.onTap});

  final List<MatchModel> matches;
  final void Function(MatchModel match) onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kHomeCardHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: matches.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, i) => SizedBox(
          width: kHomeCardWidth,
          child: SwipeCard(
            match: matches[i],
            compact: true,
            onTap: () => onTap(matches[i]),
          ),
        ),
      ),
    );
  }
}

/// Only free accounts see this, and it sits at the foot of the screen rather
/// than the head: the cap it explains is real, but it is not what anybody
/// opened the app to read.
class UpgradeCard extends StatelessWidget {
  const UpgradeCard({super.key, required this.planLabel, required this.onTap});

  final String planLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kRadius),
        color: scheme.surface,
        border: Border.all(color: scheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.workspace_premium_rounded,
                  size: 20, color: scheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(planLabel,
                    style: text.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(TrKeys.homeFreeLimit.tr, style: text.bodySmall),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onTap,
              child:
                  Text(TrKeys.homeUpgrade.tr, overflow: TextOverflow.ellipsis),
            ),
          ),
        ],
      ),
    );
  }
}
