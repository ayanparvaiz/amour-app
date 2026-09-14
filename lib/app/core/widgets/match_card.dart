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
    this.width,
    this.onLike,
    this.onPass,
    this.onMessage,
  });

  final MatchModel match;
  final VoidCallback? onTap;

  /// Fixed width for a horizontal row. Null lets a grid decide.
  final double? width;

  /// Supplying all three adds the action row under the name. Omitting them
  /// leaves the card as a plain link to the profile.
  final VoidCallback? onLike;
  final VoidCallback? onPass;
  final VoidCallback? onMessage;

  bool get _hasActions =>
      onLike != null || onPass != null || onMessage != null;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final percent = match.matchPercent;

    final card = Material(
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
                // The photo takes whatever height is left once the name and
                // actions have had theirs, so the card fits its box at any
                // width instead of relying on a guessed aspect ratio.
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      MemberAvatar.fill(
                        initial: match.initial,
                        photo: match.photo,
                      ),
                      if (percent != null)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: _PercentBadge(percent: percent),
                        ),
                    ],
                  ),
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
                      if (_hasActions) ...[
                        const SizedBox(height: 12),
                        _Actions(
                          onLike: onLike,
                          onPass: onPass,
                          onMessage: onMessage,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

    return width == null ? card : SizedBox(width: width, child: card);
  }
}

/// Pass, like and message — the same three the website puts under each card,
/// with like given the most weight.
class _Actions extends StatelessWidget {
  const _Actions({this.onLike, this.onPass, this.onMessage});

  final VoidCallback? onLike;
  final VoidCallback? onPass;
  final VoidCallback? onMessage;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Inside a FittedBox the row is given unbounded width, so it shrink-wraps
    // and spaceEvenly has nothing to spread — which is why these sat shoulder
    // to shoulder. The gaps are explicit instead.
    //
    // The FittedBox stays: two columns on a 320px screen leave about 110px
    // inside a card, and scaling down beats overflowing. At any normal width
    // nothing is scaled.
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onPass != null) ...[
            _RoundAction(
              icon: Icons.close_rounded,
              tooltip: TrKeys.discoverPass.tr,
              onTap: onPass!,
              foreground: scheme.onSurfaceVariant,
              border: scheme.outline,
            ),
            const SizedBox(width: 14),
          ],
          if (onLike != null)
            _RoundAction(
              icon: Icons.favorite_rounded,
              tooltip: TrKeys.discoverLike.tr,
              onTap: onLike!,
              foreground: Colors.white,
              background: scheme.primary,
              size: 40,
            ),
          if (onMessage != null) ...[
            const SizedBox(width: 14),
            _RoundAction(
              icon: Icons.chat_bubble_outline_rounded,
              tooltip: TrKeys.discoverMessage.tr,
              onTap: onMessage!,
              foreground: scheme.primary,
              border: scheme.outline,
            ),
          ],
        ],
      ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    required this.foreground,
    this.background,
    this.border,
    this.size = 32,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color foreground;
  final Color? background;
  final Color? border;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: background ?? Colors.transparent,
        shape: CircleBorder(
          side: border == null ? BorderSide.none : BorderSide(color: border!),
        ),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(icon, size: size * 0.46, color: foreground),
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
