import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/localization/translation_keys.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'profile_setup_controller.dart';

class ProfileSetupView extends GetView<ProfileSetupController> {
  const ProfileSetupView({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const _ProgressBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: Column(
                          children: [
                            const Icon(Icons.favorite_rounded,
                                size: 32, color: AppColors.primary),
                            const SizedBox(height: 10),
                            Obx(() => Text(
                                  TrKeys.psStepOf.trParams({
                                    'current': '${controller.step.value + 1}',
                                    'total': '${ProfileSetupController.stepCount}',
                                  }),
                                  style: text.bodySmall,
                                )),
                            const SizedBox(height: 22),
                            Obx(() => _StepBody(step: controller.step.value)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const _NavigationBar(),
              ],
            ),
            Obx(() => controller.saving.value
                ? const _SavingOverlay()
                : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}

/// Nine segments that fill in as the member moves forward.
class _ProgressBar extends GetView<ProfileSetupController> {
  const _ProgressBar();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      child: Obx(() => Row(
            children: List.generate(ProfileSetupController.stepCount, (i) {
              final done = i <= controller.step.value;
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  height: 5,
                  margin: EdgeInsets.only(
                      right: i == ProfileSetupController.stepCount - 1 ? 0 : 5),
                  decoration: BoxDecoration(
                    color: done ? scheme.primary : scheme.outline,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          )),
    );
  }
}

class _StepBody extends GetView<ProfileSetupController> {
  const _StepBody({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    return switch (step) {
      0 => const _GenderStep(),
      1 => const _AgeStep(),
      2 => const _LookingForStep(),
      3 => const _AgeRangeStep(),
      4 => const _LocationStep(),
      5 => const _PhotoStep(),
      6 => const _AboutStep(),
      7 => const _DetailsStep(),
      _ => const _ReadyStep(),
    };
  }
}

// ─── Step 1: gender ──────────────────────────────────────────────────────────

class _GenderStep extends GetView<ProfileSetupController> {
  const _GenderStep();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _StepTitle(TrKeys.psGenderTitle.tr),
        Obx(() => Column(
              children: [
                _OptionTile(
                  emoji: '👨',
                  label: TrKeys.psAMan.tr,
                  selected: controller.gender.value == 'man',
                  onTap: () => controller.gender.value = 'man',
                ),
                _OptionTile(
                  emoji: '👩',
                  label: TrKeys.psAWoman.tr,
                  selected: controller.gender.value == 'woman',
                  onTap: () => controller.gender.value = 'woman',
                ),
              ],
            )),
      ],
    );
  }
}

// ─── Step 2: age ─────────────────────────────────────────────────────────────

class _AgeStep extends GetView<ProfileSetupController> {
  const _AgeStep();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Column(
      children: [
        _StepTitle(TrKeys.psAgeTitle.tr),
        Text(TrKeys.psAgeBlurb.tr,
            style: text.bodySmall, textAlign: TextAlign.center),
        const SizedBox(height: 20),
        TextField(
          controller: controller.ageCtrl,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(2),
          ],
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          decoration: InputDecoration(
            hintText: TrKeys.psAgeFieldHint.tr,
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
          ),
        ),
        const SizedBox(height: 14),
        Text(TrKeys.psAgeNotice.tr,
            style: text.bodySmall, textAlign: TextAlign.center),
      ],
    );
  }
}

// ─── Step 3: looking for ─────────────────────────────────────────────────────

class _LookingForStep extends GetView<ProfileSetupController> {
  const _LookingForStep();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _StepTitle(TrKeys.psLookingForTitle.tr),
        Obx(() => Column(
              children: [
                _OptionTile(
                  emoji: '👨',
                  label: TrKeys.psMan.tr,
                  selected: controller.lookingFor.value == 'man',
                  onTap: () => controller.lookingFor.value = 'man',
                ),
                _OptionTile(
                  emoji: '👩',
                  label: TrKeys.psWoman.tr,
                  selected: controller.lookingFor.value == 'woman',
                  onTap: () => controller.lookingFor.value = 'woman',
                ),
                _OptionTile(
                  emoji: '👫',
                  label: TrKeys.psEveryone.tr,
                  selected: controller.lookingFor.value == 'everyone',
                  onTap: () => controller.lookingFor.value = 'everyone',
                ),
              ],
            )),
      ],
    );
  }
}

// ─── Step 4: age range ───────────────────────────────────────────────────────

class _AgeRangeStep extends GetView<ProfileSetupController> {
  const _AgeRangeStep();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _StepTitle(TrKeys.psAgeRangeTitle.tr),
        Obx(() => Column(
              children: [
                for (final range in ProfileSetupController.ageRanges)
                  _OptionTile(
                    label: range,
                    selected: controller.ageRange.value == range,
                    onTap: () => controller.ageRange.value = range,
                  ),
              ],
            )),
      ],
    );
  }
}

// ─── Step 5: location ────────────────────────────────────────────────────────

class _LocationStep extends GetView<ProfileSetupController> {
  const _LocationStep();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _StepTitle(TrKeys.psLocationTitle.tr),
        TextField(
          controller: controller.locationCtrl,
          textAlign: TextAlign.center,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(hintText: TrKeys.psLocationHint.tr),
        ),
      ],
    );
  }
}

// ─── Step 6: photo ───────────────────────────────────────────────────────────

class _PhotoStep extends GetView<ProfileSetupController> {
  const _PhotoStep();

  void _choose(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(TrKeys.psTakePhoto.tr),
              onTap: () {
                Get.back();
                controller.pickPhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(TrKeys.psFromGallery.tr),
              onTap: () {
                Get.back();
                controller.pickPhoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        _StepTitle(TrKeys.psPhotoTitle.tr),
        Obx(() {
          final data = controller.photo.value;
          return Stack(
            children: [
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.surfaceContainerHighest,
                  border: Border.all(color: scheme.outline, width: 2),
                ),
                clipBehavior: Clip.antiAlias,
                child: data == null
                    ? Icon(Icons.photo_camera_outlined,
                        size: 44, color: scheme.onSurfaceVariant)
                    : Image.memory(
                        base64Decode(data.split(',').last),
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                      ),
              ),
              if (data != null)
                Positioned(
                  top: 0,
                  right: 0,
                  child: _CircleButton(
                    icon: Icons.delete_outline_rounded,
                    tooltip: TrKeys.psRemovePhoto.tr,
                    background: scheme.error,
                    onTap: controller.removePhoto,
                  ),
                ),
              Positioned(
                bottom: 4,
                right: 4,
                child: _CircleButton(
                  icon: Icons.file_upload_outlined,
                  tooltip: TrKeys.psChoosePhoto.tr,
                  background: scheme.primary,
                  onTap: () => _choose(context),
                ),
              ),
            ],
          );
        }),
        const SizedBox(height: 22),
        Obx(() => OutlinedButton(
              onPressed: () => _choose(context),
              child: Text(controller.photo.value == null
                  ? TrKeys.psChoosePhoto.tr
                  : TrKeys.psChangePhoto.tr),
            )),
      ],
    );
  }
}

// ─── Step 7: about ───────────────────────────────────────────────────────────

class _AboutStep extends GetView<ProfileSetupController> {
  const _AboutStep();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StepTitle(TrKeys.psAboutTitle.tr),
        _FieldLabel(TrKeys.psBioLabel.tr),
        TextField(
          controller: controller.bioCtrl,
          minLines: 4,
          maxLines: 6,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(hintText: TrKeys.psBioHint.tr),
        ),
        const SizedBox(height: 18),
        _FieldLabel(TrKeys.psHobbiesLabel.tr),
        TextField(
          controller: controller.hobbiesCtrl,
          decoration: InputDecoration(hintText: TrKeys.psHobbiesHint.tr),
        ),
      ],
    );
  }
}

// ─── Step 8: details ─────────────────────────────────────────────────────────

class _DetailsStep extends GetView<ProfileSetupController> {
  const _DetailsStep();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StepTitle(TrKeys.psDetailsTitle.tr),
        _FieldLabel(TrKeys.psZodiacLabel.tr),
        Obx(() => DropdownButtonFormField<String>(
              initialValue: controller.zodiacSign.value,
              isExpanded: true,
              hint: Text(TrKeys.psSelect.tr),
              items: [
                for (final sign in ProfileSetupController.zodiacSigns)
                  DropdownMenuItem(
                    value: sign.value,
                    child: Text(sign.labelKey.tr),
                  ),
              ],
              onChanged: (v) => controller.zodiacSign.value = v,
            )),
        const SizedBox(height: 18),
        _FieldLabel(TrKeys.psReligionLabel.tr),
        TextField(
          controller: controller.religionCtrl,
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 18),
        _FieldLabel(TrKeys.psHeightLabel.tr),
        TextField(
          controller: controller.heightCtrl,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(3),
          ],
          decoration: InputDecoration(hintText: TrKeys.psHeightHint.tr),
        ),
      ],
    );
  }
}

// ─── Step 9: summary ─────────────────────────────────────────────────────────

class _ReadyStep extends GetView<ProfileSetupController> {
  const _ReadyStep();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Obx(() {
      final photo = controller.photo.value;
      final genderLabel = switch (controller.gender.value) {
        'man' => TrKeys.psMan.tr,
        'woman' => TrKeys.psWoman.tr,
        _ => '—',
      };

      return Column(
        children: [
          Text(TrKeys.psReadyTitle.tr,
              style: text.headlineMedium, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(TrKeys.psReadyBlurb.tr,
              style: text.bodySmall, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(kRadius),
            ),
            child: Column(
              children: [
                if (photo != null) ...[
                  ClipOval(
                    child: Image.memory(
                      base64Decode(photo.split(',').last),
                      width: 92,
                      height: 92,
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
                _SummaryRow(
                  TrKeys.psSummaryAge.tr,
                  TrKeys.psYearsOld
                      .trParams({'count': controller.ageCtrl.text.trim()}),
                ),
                _SummaryRow(TrKeys.psSummaryGender.tr, genderLabel),
                _SummaryRow(
                    TrKeys.psSummaryLocation.tr, controller.locationCtrl.text.trim()),
              ],
            ),
          ),
        ],
      );
    });
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ),
          Expanded(
            child: Text(value,
                style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}

// ─── Shared pieces ───────────────────────────────────────────────────────────

class _StepTitle extends StatelessWidget {
  const _StepTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Text(
          text,
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
      );
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      );
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
    this.emoji,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? emoji;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: selected ? scheme.primary.withValues(alpha: 0.08) : scheme.surface,
        borderRadius: BorderRadius.circular(kRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(kRadius),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(kRadius),
              border: Border.all(
                color: selected ? scheme.primary : scheme.outline,
                width: selected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                if (emoji != null) ...[
                  Text(emoji!, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 14),
                ],
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? scheme.primary : scheme.onSurface,
                    ),
                  ),
                ),
                if (selected)
                  Icon(Icons.check_rounded, size: 20, color: scheme.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.tooltip,
    required this.background,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final Color background;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Tooltip(
        message: tooltip,
        child: Material(
          color: background,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(9),
              child: Icon(icon, size: 18, color: Colors.white),
            ),
          ),
        ),
      );
}

class _NavigationBar extends GetView<ProfileSetupController> {
  const _NavigationBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      child: Obx(() {
        final canGoBack = controller.step.value > 0;
        final last = controller.isLastStep;

        return Row(
          children: [
            if (canGoBack) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: controller.saving.value ? null : controller.previous,
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: Text(TrKeys.back.tr),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: FilledButton.icon(
                onPressed: (controller.canContinue && !controller.saving.value)
                    ? controller.next
                    : null,
                icon: Icon(
                  last ? Icons.favorite_rounded : Icons.arrow_forward_rounded,
                  size: 18,
                ),
                label: Text(
                  last
                      ? (controller.saving.value
                          ? TrKeys.psSaving.tr
                          : TrKeys.psFindProfiles.tr)
                      : TrKeys.psNext.tr,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

/// Covers the wizard while the profile is uploading. A photo travels as base64
/// inside the request body, so this can take a noticeable moment.
class _SavingOverlay extends StatelessWidget {
  const _SavingOverlay();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Positioned.fill(
      child: ColoredBox(
        color: scheme.surface.withValues(alpha: 0.92),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.favorite_rounded,
                    size: 46, color: AppColors.primary),
                const SizedBox(height: 18),
                Text(TrKeys.psSavingTitle.tr, style: text.titleMedium),
                const SizedBox(height: 8),
                Text(TrKeys.psSavingBlurb.tr,
                    style: text.bodySmall, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
