import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/match_model.dart';
import '../localization/translation_keys.dart';
import '../theme/app_theme.dart';
import 'member_avatar.dart';

/// One candidate profile, sized for a horizontal row.
///
/// The compatibility badge is only drawn when the server sent a score — it
/// comes back on the matches endpoint but not on a plain profile fetch.
class MatchCard extends StatelessWidget {
  const MatchCard({
    super.key,
    required this.match,
    this.onTap,
    this.width = 168,
  });

  final MatchModel match;
  final VoidCallback? onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final percent = match.matchPercent;

    return SizedBox(
      width: width,
      child: Material(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(kRadius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(kRadius),
              border: Border.all(color: scheme.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    // A square photo area keeps every card the same height
                    // whatever the image, so the row never looks ragged.
                    AspectRatio(
                      aspectRatio: 1,
                      child: MemberAvatar.fill(
                        initial: match.initial,
                        photo: match.photo,
                      ),
                    ),
                    if (percent != null)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: _PercentBadge(percent: percent),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        match.age == null ? match.name : '${match.name}, ${match.age}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (match.location != null) ...[
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(Icons.place_outlined,
                                size: 13, color: scheme.onSurfaceVariant),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                match.location!,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: scheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PercentBadge extends StatelessWidget {
  const _PercentBadge({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.favorite_rounded, size: 11, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            '$percent%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown in place of the row when the server returns nobody.
class NoMatchesYet extends StatelessWidget {
  const NoMatchesYet({super.key, this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kRadius),
        border: Border.all(color: scheme.outline, style: BorderStyle.solid),
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, size: 34, color: scheme.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(TrKeys.homeNoMatches.tr,
              style: text.titleMedium, textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(TrKeys.homeNoMatchesHint.tr,
              style: text.bodySmall, textAlign: TextAlign.center),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: Text(TrKeys.homeRetry.tr)),
          ],
        ],
      ),
    );
  }
}
