import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/localization/translation_keys.dart';

/// Stands in for screens that are scheduled but not built yet, so every route
/// resolves and the app can be navigated end to end. Replace each use as the
/// real screen lands.
class PlaceholderView extends StatelessWidget {
  const PlaceholderView({super.key, required this.title, this.note});

  final String title;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.construction_rounded,
                  size: 40, color: scheme.onSurfaceVariant),
              const SizedBox(height: 16),
              Text(title, style: text.headlineMedium, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                note ?? TrKeys.comingSoon.tr,
                style: text.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (Navigator.of(context).canPop())
                OutlinedButton(
                  onPressed: Get.back,
                  child: Text(TrKeys.back.tr),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
