import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A light sweeping across whatever it wraps, for content that is still
/// loading.
///
/// Written here rather than pulled in as a package: it is a gradient moving
/// across a shader, it has to follow the app's own theme in both light and
/// dark, and a dependency for that would cost more than it saves.
class Shimmer extends StatefulWidget {
  const Shimmer({super.key, required this.child, this.enabled = true});

  final Widget child;
  final bool enabled;

  @override
  State<Shimmer> createState() => _ShimmerState();
}


class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    final scheme = Theme.of(context).colorScheme;
    final base = scheme.surfaceContainerHighest;
    final highlight = Color.alphaBlend(
      scheme.surface.withValues(alpha: 0.65),
      base,
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (bounds) {
          // Sweeps from off the left edge to off the right, so the highlight
          // enters and leaves rather than appearing in place.
          final travel = _controller.value * 2 - 0.5;
          return LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [base, highlight, base],
            stops: [
              (travel - 0.3).clamp(0.0, 1.0),
              travel.clamp(0.0, 1.0),
              (travel + 0.3).clamp(0.0, 1.0),
            ],
          ).createShader(bounds);
        },
        child: child,
      ),
      child: widget.child,
    );
  }
}

/// A plain block in the shape of the content that will replace it.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.radius = 6,
    this.shape = BoxShape.rectangle,
  });

  final double? width;
  final double? height;
  final double radius;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          shape: shape,
          borderRadius:
              shape == BoxShape.circle ? null : BorderRadius.circular(radius),
        ),
      );
}

/// The outline of a profile card, so the grid keeps its shape while it loads
/// instead of collapsing to a spinner and jumping when the cards arrive.
class MatchCardSkeleton extends StatelessWidget {
  const MatchCardSkeleton({super.key, this.withActions = true});

  final bool withActions;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kRadius),
        border: Border.all(color: scheme.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(child: ShimmerBox(radius: 0)),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerBox(width: 96, height: 13),
                const SizedBox(height: 7),
                const ShimmerBox(width: 62, height: 10),
                if (withActions) ...[
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      ShimmerBox(width: 32, height: 32, shape: BoxShape.circle),
                      SizedBox(width: 14),
                      ShimmerBox(width: 40, height: 40, shape: BoxShape.circle),
                      SizedBox(width: 14),
                      ShimmerBox(width: 32, height: 32, shape: BoxShape.circle),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A grid of card outlines, laid out exactly like the real one so nothing
/// shifts when the profiles arrive.
class MatchGridSkeleton extends StatelessWidget {
  const MatchGridSkeleton({super.key, this.count = 6, this.withActions = true});

  final int count;
  final bool withActions;

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 230,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.62,
        ),
        itemCount: count,
        itemBuilder: (_, _) => MatchCardSkeleton(withActions: withActions),
      ),
    );
  }
}

/// The horizontal row on the home screen.
class MatchRowSkeleton extends StatelessWidget {
  const MatchRowSkeleton({super.key, this.count = 3});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: SizedBox(
        height: 246,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: count,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (_, _) =>
              const SizedBox(width: 168, child: MatchCardSkeleton(withActions: false)),
        ),
      ),
    );
  }
}
