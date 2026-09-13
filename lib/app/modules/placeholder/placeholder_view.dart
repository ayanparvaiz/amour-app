import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/localization/translation_keys.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_drawer.dart';

/// Stands in for a destination that is scheduled but not built yet.
///
/// It carries the drawer like any real screen, so the navigation can be walked
/// end to end while the screens land one at a time — and so nobody reaches a
/// dead end they cannot leave.
class PlaceholderView extends StatelessWidget {
  const PlaceholderView({
    super.key,
    required this.title,
    this.note,
    this.drawerRoute,
  });

  final String title;
  final String? note;

  /// Route of this destination, so the drawer can mark it as current. Omit it
  /// on screens pushed on top of another, which get a back arrow instead.
  final String? drawerRoute;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final inDrawer = drawerRoute != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: inDrawer
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: Get.back,
                tooltip: TrKeys.back.tr,
              ),
      ),
      drawer: inDrawer ? AppDrawer(current: drawerRoute!) : null,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(kRadius + 6),
                ),
                child: Icon(Icons.construction_rounded,
                    size: 32, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 20),
              Text(TrKeys.homeComingSoonTitle.tr,
                  style: text.headlineMedium, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                note ?? TrKeys.comingSoon.tr,
                style: text.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
