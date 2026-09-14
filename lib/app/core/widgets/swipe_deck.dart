import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/models/match_model.dart';
import 'swipe_card.dart';

/// Drives a deck from outside it — so a button press throws the same card the
/// same way a drag would.
class SwipeDeckController {
  _SwipeDeckState? _state;

  void _attach(_SwipeDeckState state) => _state = state;
  void _detach(_SwipeDeckState state) {
    if (identical(_state, state)) _state = null;
  }

  bool get isBusy => _state?._throwing ?? false;

  void like() => _state?.throwCard(SwipeDirection.like);
  void pass() => _state?.throwCard(SwipeDirection.pass);
}

/// A stack of profiles, dealt one at a time.
///
/// The top card follows the finger and tilts as it goes; past a threshold it
/// carries on off the screen and the decision is reported. Anything short of
/// that springs back, so a hesitant drag costs nothing.
class SwipeDeck extends StatefulWidget {
  const SwipeDeck({
    super.key,
    required this.profiles,
    required this.onSwipe,
    this.onTapProfile,
    this.controller,
  });

  final List<MatchModel> profiles;

  /// Called once the card has left the screen, never mid-drag.
  final void Function(MatchModel profile, SwipeDirection direction) onSwipe;

  final void Function(MatchModel profile)? onTapProfile;
  final SwipeDeckController? controller;

  @override
  State<SwipeDeck> createState() => _SwipeDeckState();
}

class _SwipeDeckState extends State<SwipeDeck> with SingleTickerProviderStateMixin {
  /// Built in initState rather than as a late field. A late field is created
  /// on first use, and if that first use turns out to be dispose(), `vsync:
  /// this` reaches for an ancestor at exactly the moment that is unsafe.
  late final AnimationController _animation;

  Tween<Offset>? _tween;
  Offset _drag = Offset.zero;
  bool _throwing = false;

  /// How far sideways a card must travel before it counts as a decision.
  static const double _commitFraction = 0.28;

  @override
  void initState() {
    super.initState();
    _animation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    )..addListener(
        () => setState(() => _drag = _tween?.transform(_animation.value) ?? _drag),
      );
    widget.controller?._attach(this);
  }

  @override
  void didUpdateWidget(SwipeDeck old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller?._detach(this);
      widget.controller?._attach(this);
    }
  }

  @override
  void dispose() {
    widget.controller?._detach(this);
    _animation.dispose();
    super.dispose();
  }

  MatchModel? get _top =>
      widget.profiles.isEmpty ? null : widget.profiles.first;

  void _onPanUpdate(DragUpdateDetails details) {
    if (_throwing) return;
    setState(() => _drag += details.delta);
  }

  void _onPanEnd(DragEndDetails details, double width) {
    if (_throwing) return;

    final velocity = details.velocity.pixelsPerSecond.dx;
    final past = _drag.dx.abs() > width * _commitFraction;
    final flung = velocity.abs() > 700;

    if (past || flung) {
      final goingRight = (past ? _drag.dx : velocity) > 0;
      throwCard(goingRight ? SwipeDirection.like : SwipeDirection.pass);
    } else {
      _springBack();
    }
  }

  void _springBack() {
    _tween = Tween(begin: _drag, end: Offset.zero);
    _animation
      ..duration = const Duration(milliseconds: 260)
      ..reset()
      ..forward();
  }

  /// Sends the top card off the screen and reports it once it is gone.
  void throwCard(SwipeDirection direction) {
    final profile = _top;
    if (profile == null || _throwing) return;

    final width = context.size?.width ?? 400;
    final target = Offset(
      direction == SwipeDirection.like ? width * 1.6 : -width * 1.6,
      _drag.dy + 40,
    );

    _throwing = true;
    _tween = Tween(begin: _drag, end: target);
    _animation
      ..duration = const Duration(milliseconds: 300)
      ..reset();

    _animation.forward().whenComplete(() {
      if (!mounted) return;
      _throwing = false;
      _drag = Offset.zero;
      _tween = null;
      // The list shortens in the parent; this rebuilds with the next card
      // already at rest rather than sliding in from where the last one left.
      widget.onSwipe(profile, direction);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final progress = (_drag.dx / (width * _commitFraction)).clamp(-1.5, 1.5);

        // Three deep is enough to read as a stack without building a whole
        // list of photographs that nobody has reached yet.
        final visible = widget.profiles.take(3).toList();

        return Stack(
          alignment: Alignment.center,
          children: [
            for (var i = visible.length - 1; i >= 0; i--)
              if (i == 0)
                _buildTop(visible[i], width, progress)
              else
                _buildBehind(visible[i], i, progress.abs()),
          ],
        );
      },
    );
  }

  Widget _buildBehind(MatchModel profile, int depth, double progress) {
    // The next card rises towards the front as the top one is dragged away.
    final lift = depth == 1 ? (progress.clamp(0.0, 1.0)) : 0.0;
    final scale = 1 - (depth * 0.05) + (lift * 0.05);
    final drop = (depth * 12) - (lift * 12);

    return Transform.translate(
      offset: Offset(0, drop),
      child: Transform.scale(
        scale: scale,
        child: SwipeCard(match: profile, dimmed: true),
      ),
    );
  }

  Widget _buildTop(MatchModel profile, double width, double progress) {
    // A gentle tilt, capped so a long drag never spins the card over.
    final angle = (_drag.dx / width) * 0.35;

    return Transform.translate(
      offset: _drag,
      child: Transform.rotate(
        angle: angle.clamp(-math.pi / 9, math.pi / 9),
        child: GestureDetector(
          onPanUpdate: _onPanUpdate,
          onPanEnd: (details) => _onPanEnd(details, width),
          child: Stack(
            fit: StackFit.expand,
            children: [
              SwipeCard(
                match: profile,
                onTap: () => widget.onTapProfile?.call(profile),
              ),
              if (progress > 0.05)
                SwipeStamp(direction: SwipeDirection.like, opacity: progress),
              if (progress < -0.05)
                SwipeStamp(direction: SwipeDirection.pass, opacity: -progress),
            ],
          ),
        ),
      ),
    );
  }
}
