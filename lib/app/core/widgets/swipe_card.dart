import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/match_model.dart';
import '../localization/translation_keys.dart';
import '../theme/app_theme.dart';
import 'member_avatar.dart';

/// Which way a card left the deck.
enum SwipeDirection { like, pass }

/// The size a compact card is dealt at in the home row. Shared with the
/// loading skeleton so the row cannot jump when the profiles arrive.
const double kHomeCardWidth = 180;
const double kHomeCardHeight = 240;

/// One profile, filling the deck: the photograph, with the name and a line or
/// two of detail over a scrim at the bottom.
class SwipeCard extends StatelessWidget {
  const SwipeCard({
    super.key,
    required this.match,
    this.onTap,
    this.dimmed = false,
    this.compact = false,
  });

  final MatchModel match;
  final VoidCallback? onTap;

  /// Cards waiting behind the top one are dimmed so the front card reads as
  /// the one in play.
  final bool dimmed;

  /// The same card at the size the home row uses. Type shrinks and the bio
  /// goes — two lines of description are unreadable at a third of the width,
  /// and the row is a taste, not the profile.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pad = compact ? 12.0 : 18.0;

    return Material(
      elevation: dimmed ? 0 : (compact ? 2 : 6),
      shadowColor: Colors.black.withValues(alpha: 0.28),
      borderRadius: BorderRadius.circular(compact ? kRadius : kRadius + 8),
      clipBehavior: Clip.antiAlias,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            MemberAvatar.fill(initial: match.initial, photo: match.photo),

            // Dark at the foot so the name stays legible over any photograph.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black87, Colors.transparent],
                  stops: [0, 0.55],
                ),
              ),
            ),

            if (match.matchPercent != null)
              Positioned(
                top: compact ? 10 : 14,
                left: compact ? 10 : 14,
                child: _Badge(percent: match.matchPercent!, compact: compact),
              ),

            Positioned(
              left: pad,
              right: pad,
              bottom: pad,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    match.age == null
                        ? match.name
                        : '${match.name}, ${match.age}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: compact ? 16 : 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (match.location != null) ...[
                    SizedBox(height: compact ? 3 : 5),
                    Row(
                      children: [
                        Icon(Icons.place_outlined,
                            size: compact ? 12 : 15, color: Colors.white70),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            match.location!,
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: compact ? 11.5 : 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (match.bio != null && !compact) ...[
                    const SizedBox(height: 10),
                    Text(
                      match.bio!,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13.5, height: 1.35),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            if (dimmed)
              ColoredBox(color: scheme.surface.withValues(alpha: 0.35)),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.percent, this.compact = false});

  final int percent;
  final bool compact;

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(
            horizontal: compact ? 7 : 10, vertical: compact ? 3 : 5),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_rounded,
                size: compact ? 10 : 13, color: Colors.white),
            SizedBox(width: compact ? 3 : 5),
            Text('$percent%',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: compact ? 11 : 13,
                  fontWeight: FontWeight.w700,
                )),
          ],
        ),
      );
}

/// The stamp that fades in as a card is dragged, so the decision is visible
/// before it is committed.
class SwipeStamp extends StatelessWidget {
  const SwipeStamp({
    super.key,
    required this.direction,
    required this.opacity,
  });

  final SwipeDirection direction;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final like = direction == SwipeDirection.like;
    final colour = like ? const Color(0xFF22C55E) : const Color(0xFFEF4444);

    return Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: Align(
        alignment: like ? Alignment.topLeft : Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Transform.rotate(
            angle: like ? -0.28 : 0.28,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                border: Border.all(color: colour, width: 4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                like ? TrKeys.swipeLike.tr : TrKeys.swipeNope.tr,
                style: TextStyle(
                  color: colour,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
