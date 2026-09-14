import 'dart:async';

import 'package:flutter/material.dart';

/// Fades its child in and lifts it a little as it arrives.
///
/// Used to let a screen assemble itself rather than appear all at once: give
/// each section a slightly later [delay] and the eye is walked down the page
/// in the order the content matters. Short and only on first build — motion
/// that repeats on every rebuild stops being an arrival and becomes a flicker.
class Entrance extends StatefulWidget {
  const Entrance({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = 14,
  });

  final Widget child;

  /// How long to wait before starting. Stagger the sections with it.
  final Duration delay;

  /// How far below its resting place the child starts, in logical pixels.
  final double offset;

  /// The step between one section and the next.
  static const Duration step = Duration(milliseconds: 70);

  /// The delay for the [index]-th section of a screen.
  static Duration stagger(int index) => step * index;

  @override
  State<Entrance> createState() => _EntranceState();
}

class _EntranceState extends State<Entrance> with SingleTickerProviderStateMixin {
  /// Built here rather than as a late field: a late field is created on first
  /// use, and if that first use turns out to be dispose(), `vsync: this`
  /// reaches for an ancestor at the one moment that is unsafe.
  late final AnimationController _animation;
  late final Animation<double> _eased;
  Timer? _start;

  @override
  void initState() {
    super.initState();
    _animation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _eased = CurvedAnimation(parent: _animation, curve: Curves.easeOutCubic);

    if (widget.delay == Duration.zero) {
      _animation.forward();
    } else {
      _start = Timer(widget.delay, () {
        if (mounted) _animation.forward();
      });
    }
  }

  @override
  void dispose() {
    _start?.cancel();
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _eased,
      // Built once and handed through: the child does not depend on the
      // animation, so rebuilding it sixty times a second would be waste.
      child: widget.child,
      builder: (context, child) => Opacity(
        opacity: _eased.value,
        child: Transform.translate(
          offset: Offset(0, widget.offset * (1 - _eased.value)),
          child: child,
        ),
      ),
    );
  }
}
