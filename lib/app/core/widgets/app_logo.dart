import 'package:flutter/material.dart';

import '../constants/app_images.dart';

/// The brand mark, rounded the way iOS and Android round a launcher icon so it
/// reads as the app's own identity wherever it appears in the UI.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 72, this.shadow = true});

  final double size;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    // Apple's icon grid uses a corner radius of roughly 22.5% of the width.
    final radius = BorderRadius.circular(size * 0.225);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: shadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: size * 0.22,
                  offset: Offset(0, size * 0.07),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Image.asset(
          AppImages.logo,
          width: size,
          height: size,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );
  }
}
