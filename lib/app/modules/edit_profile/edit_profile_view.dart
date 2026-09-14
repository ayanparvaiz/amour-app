import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/settings_options.dart';
import '../../core/localization/translation_keys.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/member_avatar.dart';
import '../../routes/app_routes.dart';
import 'edit_profile_controller.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await controller.confirmLeave()) Get.back();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(TrKeys.setTitle.tr),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: TrKeys.back.tr,
            onPressed: () async {
              if (await controller.confirmLeave()) Get.back();
            },
          ),
          actions: [
            Obx(() => Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: TextButton.icon(
                    onPressed: controller.saving.value ? null : controller.save,
                    icon: controller.saving.value
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check_rounded, size: 18),
                    label: Text(
                      controller.saving.value
                          ? TrKeys.setSaving.tr
                          : TrKeys.setSave.tr,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            const _PhotosSection(),
            const SizedBox(height: 28),
            const _BasicsSection(),
            const SizedBox(height: 28),
            const _PreferencesSection(),
            const SizedBox(height: 28),
            const _LocationSection(),
            const SizedBox(height: 28),
            const _InterestsSection(),
            const SizedBox(height: 28),
            const _AppearanceSection(),
            const SizedBox(height: 28),
            const _LifestyleSection(),
            const SizedBox(height: 28),
            const _SecuritySection(),
          ],
        ),
      ),
    );
  }
}

// ─── Photos ──────────────────────────────────────────────────────────────────

class _PhotosSection extends GetView<EditProfileController> {
  const _PhotosSection();

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
                controller.addPhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(TrKeys.psFromGallery.tr),
              onTap: () {
                Get.back();
                controller.addPhoto(ImageSource.gallery);
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

    return _Section(
      title: TrKeys.setPhotos.tr,
      subtitle: TrKeys.setPhotosHint.tr,
      child: Obx(() => GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (var i = 0; i < controller.photos.length; i++)
                _PhotoTile(index: i, photo: controller.photos[i]),
              // Add button, always last.
              Material(
                color: scheme.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(kRadius),
                child: InkWell(
                  onTap: () => _choose(context),
                  borderRadius: BorderRadius.circular(kRadius),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(kRadius),
                      border: Border.all(
                        color: scheme.primary.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_outlined,
                            size: 22, color: scheme.primary),
                        const SizedBox(height: 6),
                        Text(
                          TrKeys.setAdd.tr,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: scheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }
}

class _PhotoTile extends GetView<EditProfileController> {
  const _PhotoTile({required this.index, required this.photo});

  final int index;
  final String photo;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isMain = index == 0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(kRadius),
      child: Stack(
        fit: StackFit.expand,
        children: [
          MemberAvatar.fill(initial: '', photo: photo),
          Positioned(
            top: 4,
            right: 4,
            child: _TileButton(
              icon: Icons.delete_outline_rounded,
              tooltip: TrKeys.psRemovePhoto.tr,
              background: scheme.error,
              onTap: () => controller.removePhoto(index),
            ),
          ),
          if (isMain)
            Positioned(
              bottom: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  TrKeys.setPhotoMain.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            )
          else
            Positioned(
              bottom: 4,
              left: 4,
              child: _TileButton(
                icon: Icons.star_outline_rounded,
                tooltip: TrKeys.setPhotoMakeMain.tr,
                background: Colors.black54,
                onTap: () => controller.makeMain(index),
              ),
            ),
        ],
      ),
    );
  }
}

class _TileButton extends StatelessWidget {
  const _TileButton({
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
              padding: const EdgeInsets.all(5),
              child: Icon(icon, size: 15, color: Colors.white),
            ),
          ),
        ),
      );
}

// ─── Sections ────────────────────────────────────────────────────────────────

class _BasicsSection extends GetView<EditProfileController> {
  const _BasicsSection();

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: TrKeys.profileAboutMe.tr,
      child: Column(
        children: [
          _Field(label: TrKeys.setDisplayName.tr, controller: controller.nameCtrl),
          _Field(
            label: TrKeys.age.tr,
            controller: controller.ageCtrl,
            keyboardType: TextInputType.number,
            formatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(2),
            ],
          ),
          _Field(
            label: TrKeys.setBio.tr,
            hint: TrKeys.setBioHint.tr,
            controller: controller.bioCtrl,
            minLines: 3,
            maxLines: 6,
          ),
        ],
      ),
    );
  }
}

class _PreferencesSection extends GetView<EditProfileController> {
  const _PreferencesSection();

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: TrKeys.profileMyPreferences.tr,
      child: Column(
        children: [
          _OptionField(
            label: TrKeys.setMyGender.tr,
            options: SettingsOptions.gender,
            selected: controller.gender,
            onChanged: (v) => controller.select(controller.gender, v),
          ),
          _OptionField(
            label: TrKeys.setLookingFor.tr,
            options: SettingsOptions.lookingFor,
            selected: controller.lookingFor,
            onChanged: (v) => controller.select(controller.lookingFor, v),
          ),
          Obx(() => _Dropdown<String>(
                label: TrKeys.setTargetAgeRange.tr,
                value: controller.ageRange.value,
                items: [
                  for (final range in controller.ageRanges)
                    DropdownMenuItem(value: range, child: Text(range)),
                ],
                onChanged: (v) => controller.select(controller.ageRange, v),
              )),
        ],
      ),
    );
  }
}

class _LocationSection extends GetView<EditProfileController> {
  const _LocationSection();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return _Section(
      title: TrKeys.setSectionLocation.tr,
      child: Column(
        children: [
          Obx(() {
            final coords = controller.coordinates.value;
            return Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: controller.locating.value
                        ? null
                        : controller.useCurrentPosition,
                    icon: controller.locating.value
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location_rounded, size: 18),
                    label: Text(
                      coords == null
                          ? TrKeys.setGetPosition.tr
                          : TrKeys.setUpdatePosition.tr,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                if (coords != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    // Said the way people say it — latitude first — even though
                    // it travels the other way round.
                    TrKeys.setCoordinates.trParams({
                      'lat': coords.$2.toStringAsFixed(4),
                      'lng': coords.$1.toStringAsFixed(4),
                    }),
                    style: text.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 16),
              ],
            );
          }),
          _Field(
            label: TrKeys.setCountry.tr,
            hint: TrKeys.setCountryHint.tr,
            controller: controller.countryCtrl,
          ),
          _Field(
            label: TrKeys.setRegion.tr,
            hint: TrKeys.setRegionHint.tr,
            controller: controller.departmentCtrl,
          ),
          _Field(
            label: TrKeys.setCity.tr,
            hint: TrKeys.setCityHint.tr,
            controller: controller.cityCtrl,
          ),
          _Field(
            label: TrKeys.setPublicAddress.tr,
            hint: TrKeys.setPublicAddressHint.tr,
            controller: controller.locationCtrl,
          ),
        ],
      ),
    );
  }
}

class _InterestsSection extends GetView<EditProfileController> {
  const _InterestsSection();

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: TrKeys.setSectionInterests.tr,
      child: Column(
        children: [
          _Field(
            label: TrKeys.psHobbiesLabel.tr,
            hint: TrKeys.psHobbiesHint.tr,
            controller: controller.hobbiesCtrl,
          ),
          _Field(
            label: TrKeys.setActivities.tr,
            hint: TrKeys.setActivitiesHint.tr,
            controller: controller.activitiesCtrl,
          ),
          Obx(() => _Dropdown<String>(
                label: TrKeys.psZodiacLabel.tr,
                value: controller.zodiacSign.value,
                items: [
                  for (final sign in controller.zodiacOptions)
                    DropdownMenuItem(
                      value: sign.value,
                      child: Text(sign.labelKey.tr),
                    ),
                ],
                onChanged: (v) => controller.select(controller.zodiacSign, v),
              )),
          _Field(
            label: TrKeys.profileReligion.tr,
            hint: TrKeys.setReligionHint.tr,
            controller: controller.religionCtrl,
          ),
          _OptionField(
            label: TrKeys.profileChildren.tr,
            options: SettingsOptions.children,
            selected: controller.children,
            onChanged: (v) => controller.select(controller.children, v),
          ),
        ],
      ),
    );
  }
}

class _AppearanceSection extends GetView<EditProfileController> {
  const _AppearanceSection();

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: TrKeys.setSectionAppearance.tr,
      child: Column(
        children: [
          _Field(
            label: TrKeys.psHeightLabel.tr,
            hint: TrKeys.psHeightHint.tr,
            controller: controller.heightCtrl,
            keyboardType: TextInputType.number,
            formatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3),
            ],
          ),
          _Field(
            label: TrKeys.setWeight.tr,
            hint: TrKeys.setWeightHint.tr,
            controller: controller.weightCtrl,
            keyboardType: TextInputType.number,
            formatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3),
            ],
          ),
          _Field(
            label: TrKeys.profileEyes.tr,
            hint: TrKeys.setEyeColourHint.tr,
            controller: controller.eyeColorCtrl,
          ),
          _Field(
            label: TrKeys.profileHair.tr,
            hint: TrKeys.setHairColourHint.tr,
            controller: controller.hairColorCtrl,
          ),
        ],
      ),
    );
  }
}

class _LifestyleSection extends GetView<EditProfileController> {
  const _LifestyleSection();

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: TrKeys.setSectionLifestyle.tr,
      child: Column(
        children: [
          _OptionField(
            label: TrKeys.fSmoke.tr,
            options: SettingsOptions.smoke,
            selected: controller.smoke,
            onChanged: (v) => controller.select(controller.smoke, v),
          ),
          _OptionField(
            label: TrKeys.fAlcohol.tr,
            options: SettingsOptions.alcohol,
            selected: controller.alcohol,
            onChanged: (v) => controller.select(controller.alcohol, v),
          ),
        ],
      ),
    );
  }
}

class _SecuritySection extends StatelessWidget {
  const _SecuritySection();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return _Section(
      title: TrKeys.setSectionSecurity.tr,
      child: Material(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(kRadius),
        child: InkWell(
          onTap: () => Get.toNamed(AppRoutes.changePassword),
          borderRadius: BorderRadius.circular(kRadius),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(kRadius),
              border: Border.all(color: scheme.outline.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Icon(Icons.lock_outline_rounded, size: 20, color: scheme.primary),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    TrKeys.changePasswordTitle.tr,
                    style: const TextStyle(
                        fontSize: 14.5, fontWeight: FontWeight.w600),
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    size: 20, color: scheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Shared pieces ───────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.subtitle});

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: text.headlineMedium),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle!, style: text.bodySmall),
        ],
        const SizedBox(height: 14),
        child,
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    this.hint,
    this.keyboardType,
    this.formatters,
    this.minLines,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? formatters;
  final int? minLines;
  final int? maxLines;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: formatters,
          minLines: minLines,
          maxLines: maxLines,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(labelText: label, hintText: hint),
        ),
      );
}

class _OptionField extends StatelessWidget {
  const _OptionField({
    required this.label,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final String label;
  final List<SettingsOption> options;
  final RxnString selected;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Obx(() => _Dropdown<String>(
          label: label,
          value: selected.value,
          items: [
            for (final option in options)
              DropdownMenuItem(
                value: option.value,
                child: Text(option.labelKey.tr),
              ),
          ],
          onChanged: onChanged,
        ));
  }
}

class _Dropdown<T> extends StatelessWidget {
  const _Dropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: DropdownButtonFormField<T>(
          initialValue: value,
          isExpanded: true,
          decoration: InputDecoration(labelText: label),
          hint: Text(TrKeys.psSelect.tr),
          items: items,
          onChanged: onChanged,
        ),
      );
}
