import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../core/constants/filter_options.dart';
import '../../core/localization/translation_keys.dart';
import '../../core/theme/app_theme.dart';
import '../../routes/app_routes.dart';
import 'discover_controller.dart';

/// Opens the search panel. Applying runs the query and closes; the sheet is
/// scrollable and sized to the content so the keyboard never covers a field.
Future<void> showDiscoverFilters(
  BuildContext context,
  DiscoverController controller,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) =>
          _FilterSheet(controller: controller, scrollController: scrollController),
    ),
  );
}

class _FilterSheet extends StatelessWidget {
  const _FilterSheet({required this.controller, required this.scrollController});

  final DiscoverController controller;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 12, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(TrKeys.discoverCriteria.tr, style: text.headlineMedium),
              ),
              TextButton(
                onPressed: controller.reset,
                child: Text(TrKeys.discoverReset.tr),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            children: [
              _SectionTitle(TrKeys.fSectionLocation.tr),
              _SearchLevelField(controller: controller),
              Obx(() => controller.searchLevel.value == SearchLevel.radius
                  ? _RadiusSlider(controller: controller)
                  : const SizedBox.shrink()),
              const SizedBox(height: 24),

              _SectionTitle(TrKeys.fSectionLifestyle.tr),
              _OptionField(
                label: TrKeys.fSmoke.tr,
                options: FilterOptions.smoke,
                selected: controller.smoke,
              ),
              const SizedBox(height: 14),
              _OptionField(
                label: TrKeys.fAlcohol.tr,
                options: FilterOptions.alcohol,
                selected: controller.alcohol,
              ),
              const SizedBox(height: 14),
              _OptionField(
                label: TrKeys.fChildren.tr,
                options: FilterOptions.children,
                selected: controller.children,
              ),
              const SizedBox(height: 24),

              _SectionTitle(TrKeys.fSectionAdvanced.tr),
              _AdvancedSection(controller: controller),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
            child: FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                controller.load();
              },
              child: Text(TrKeys.discoverApply.tr),
            ),
          ),
        ),
      ],
    );
  }
}

class _AdvancedSection extends StatelessWidget {
  const _AdvancedSection({required this.controller});

  final DiscoverController controller;

  @override
  Widget build(BuildContext context) {
    final fields = Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _NumberField(
                label: TrKeys.fAgeMin.tr,
                controller: controller.ageMinCtrl,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _NumberField(
                label: TrKeys.fAgeMax.tr,
                controller: controller.ageMaxCtrl,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _OptionField(
          label: TrKeys.fEyes.tr,
          options: FilterOptions.eyeColor,
          selected: controller.eyeColor,
        ),
        const SizedBox(height: 14),
        _OptionField(
          label: TrKeys.fHair.tr,
          options: FilterOptions.hairColor,
          selected: controller.hairColor,
        ),
        const SizedBox(height: 14),
        TextField(
          controller: controller.keywordCtrl,
          decoration: InputDecoration(
            labelText: TrKeys.fKeyword.tr,
            hintText: TrKeys.fKeywordHint.tr,
          ),
        ),
      ],
    );

    if (controller.canUseAdvanced) return fields;

    // Dimmed and unusable rather than hidden, so the member can see what the
    // upgrade buys — the same choice the website makes.
    return Stack(
      children: [
        Opacity(
          opacity: 0.35,
          child: IgnorePointer(child: fields),
        ),
        Positioned.fill(child: _AdvancedLock()),
      ],
    );
  }
}

class _AdvancedLock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(kRadius),
          border: Border.all(color: scheme.outline),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 18,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline_rounded, size: 24, color: scheme.primary),
            const SizedBox(height: 10),
            Text(TrKeys.discoverLocked.tr,
                style: text.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(TrKeys.discoverLockedBody.tr,
                style: text.bodySmall, textAlign: TextAlign.center),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                Get.toNamed(AppRoutes.plans);
              },
              child: Text(TrKeys.discoverUnlock.tr),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchLevelField extends StatelessWidget {
  const _SearchLevelField({required this.controller});

  final DiscoverController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() => DropdownButtonFormField<SearchLevel>(
          initialValue: controller.searchLevel.value,
          isExpanded: true,
          items: [
            for (final level in SearchLevel.values)
              DropdownMenuItem(value: level, child: Text(level.labelKey.tr)),
          ],
          onChanged: (v) {
            if (v != null) controller.searchLevel.value = v;
          },
        ));
  }
}

class _RadiusSlider extends StatelessWidget {
  const _RadiusSlider({required this.controller});

  final DiscoverController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final km = controller.radiusKm.value;
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              TrKeys.fDistance.trParams({'km': '${km.round()}'}),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Slider(
              value: km,
              min: 1,
              max: 500,
              divisions: 499,
              label: '${km.round()} km',
              onChanged: (v) => controller.radiusKm.value = v,
            ),
          ],
        ),
      );
    });
  }
}

class _OptionField extends StatelessWidget {
  const _OptionField({
    required this.label,
    required this.options,
    required this.selected,
  });

  final String label;
  final List<FilterOption> options;
  final RxnString selected;

  @override
  Widget build(BuildContext context) {
    return Obx(() => DropdownButtonFormField<String?>(
          initialValue: selected.value,
          isExpanded: true,
          decoration: InputDecoration(labelText: label),
          items: [
            for (final option in options)
              DropdownMenuItem(
                value: option.value,
                child: Text(option.labelKey.tr),
              ),
          ],
          onChanged: (v) => selected.value = v,
        ));
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(2),
      ],
      decoration: InputDecoration(labelText: label),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
}
