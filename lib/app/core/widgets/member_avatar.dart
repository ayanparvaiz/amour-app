import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A member's photo, or their initial on the brand gradient when they have
/// none.
///
/// Photos arrive as `data:image/jpeg;base64,...` strings inside the profile
/// rather than as URLs, because the backend keeps them in the user document.
/// Decoding happens once per photo, not once per rebuild.
class MemberAvatar extends StatefulWidget {
  /// A circle, for lists and headers. [size] is the diameter.
  const MemberAvatar({
    super.key,
    required this.initial,
    this.photo,
    this.size = 56,
    this.borderColor,
  })  : _fill = false,
        fillRadius = null;

  /// Fills whatever box it is given — for cards, where a circle would leave the
  /// corners empty. Pass [radius] to round it.
  const MemberAvatar.fill({
    super.key,
    required this.initial,
    this.photo,
    this.fillRadius,
  })  : _fill = true,
        size = 0,
        borderColor = null;

  final String initial;
  final String? photo;
  final double size;
  final Color? borderColor;
  /// Corner radius in fill mode; null leaves the corners square.
  final double? fillRadius;
  final bool _fill;

  @override
  State<MemberAvatar> createState() => _MemberAvatarState();
}

class _MemberAvatarState extends State<MemberAvatar> {
  Uint8List? _bytes;

  @override
  void initState() {
    super.initState();
    _decode();
  }

  @override
  void didUpdateWidget(MemberAvatar old) {
    super.didUpdateWidget(old);
    if (old.photo != widget.photo) _decode();
  }

  void _decode() {
    final photo = widget.photo;
    if (photo == null || photo.isEmpty) {
      _bytes = null;
      return;
    }
    try {
      // Tolerates both a bare base64 string and a full data URI.
      _bytes = base64Decode(photo.contains(',') ? photo.split(',').last : photo);
    } catch (_) {
      _bytes = null; // a malformed photo just falls back to the initial
    }
  }

  @override
  Widget build(BuildContext context) {
    // In fill mode the parent decides the size, so the letter is scaled from
    // the box it is actually given rather than from a fixed diameter.
    final content = widget._fill
        ? LayoutBuilder(
            builder: (_, constraints) => _content(
              constraints.biggest.shortestSide,
            ),
          )
        : _content(widget.size);

    if (widget._fill) {
      final radius = widget.fillRadius;
      return DecoratedBox(
        decoration: BoxDecoration(
          gradient: _bytes == null ? AppColors.heroGradient : null,
          borderRadius: radius == null ? null : BorderRadius.circular(radius),
        ),
        child: radius == null
            ? content
            : ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: content,
              ),
      );
    }

    final border = widget.borderColor;
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: _bytes == null ? AppColors.heroGradient : null,
        border: border == null ? null : Border.all(color: border, width: 2),
      ),
      // Clipped explicitly rather than through the container's own
      // `clipBehavior`. That form leaves the shape up to the decoration, and
      // the photo came out square-cornered on device; ClipOval says what is
      // meant and holds whatever is painting.
      child: ClipOval(child: content),
    );
  }

  Widget _content(double extent) {
    if (_bytes != null) {
      return SizedBox.expand(
        child: Image.memory(_bytes!, fit: BoxFit.cover, gaplessPlayback: true),
      );
    }
    return Center(
      child: Text(
        widget.initial,
        style: TextStyle(
          color: Colors.white,
          fontSize: extent * 0.4,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
