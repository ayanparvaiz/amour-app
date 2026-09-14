import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../localization/translation_keys.dart';

/// The sizes the action row is built from, shared so the loading skeleton
/// cannot drift away from the real thing and make the screen jump.
const double kSwipeActionLarge = 62;
const double kSwipeActionSmall = 50;
const double kSwipeActionGap = 22;

/// Pass, super like and like — under the deck, where a thumb reaches them.
///
/// Knows nothing about the controller or the session: Discover passes the
/// callbacks in. That keeps it testable at phone widths without standing up
/// storage-backed services.
class SwipeActions extends StatelessWidget {
  const SwipeActions({
    super.key,
    required this.onPass,
    required this.onSuperLike,
    required this.onLike,
    this.canSuperLike = false,
  });

  final VoidCallback onPass;
  final VoidCallback onSuperLike;
  final VoidCallback onLike;

  /// Super likes are Premium and Prestige only. The button stays tappable when
  /// locked — it explains itself rather than going quietly dead.
  final bool canSuperLike;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _Action(
            icon: Icons.close_rounded,
            size: kSwipeActionLarge,
            iconSize: 30,
            foreground: const Color(0xFFEF4444),
            border: scheme.outline,
            tooltip: TrKeys.discoverPass.tr,
            onTap: onPass,
          ),
          const SizedBox(width: kSwipeActionGap),
          _Action(
            icon: Icons.star_rounded,
            size: kSwipeActionSmall,
            iconSize: 24,
            foreground: canSuperLike
                ? const Color(0xFF3B82F6)
                : scheme.onSurfaceVariant.withValues(alpha: 0.5),
            border: scheme.outline,
            tooltip: TrKeys.swipeSuper.tr,
            onTap: onSuperLike,
          ),
          const SizedBox(width: kSwipeActionGap),
          _Action(
            icon: Icons.favorite_rounded,
            size: kSwipeActionLarge,
            iconSize: 30,
            foreground: Colors.white,
            background: scheme.primary,
            tooltip: TrKeys.discoverLike.tr,
            onTap: onLike,
          ),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.size,
    required this.iconSize,
    required this.foreground,
    required this.tooltip,
    required this.onTap,
    this.background,
    this.border,
  });

  final IconData icon;
  final double size;
  final double iconSize;
  final Color foreground;
  final Color? background;
  final Color? border;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: background ?? scheme.surface,
        shape: CircleBorder(
          side: border == null ? BorderSide.none : BorderSide(color: border!),
        ),
        elevation: background == null ? 1 : 3,
        shadowColor: Colors.black.withValues(alpha: 0.2),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(icon, size: iconSize, color: foreground),
          ),
        ),
      ),
    );
  }
}
