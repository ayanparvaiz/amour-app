import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/localization/translation_keys.dart';
import '../../data/providers/api_client.dart';
import '../../data/services/auth_service.dart';
import '../../routes/app_routes.dart';

/// A star sign option: the French [value] is what gets stored, [labelKey] is
/// only what the option reads as on screen.
typedef ZodiacOption = ({String value, String labelKey});

/// The nine-step wizard a member walks through after registering — the same
/// steps, in the same order, collecting the same fields as the website.
class ProfileSetupController extends GetxController {
  ProfileSetupController({ImagePicker? picker})
      : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  static const int stepCount = 9;

  /// Exactly the strings the website offers. They are stored as written and
  /// compared between members when matching, so they are values, not copy —
  /// translating them would stop members matching each other.
  static const List<String> ageRanges = ['18–25', '25–35', '35–45', '45+'];

  static const List<ZodiacOption> zodiacSigns = [
    (value: 'Bélier', labelKey: TrKeys.zAries),
    (value: 'Taureau', labelKey: TrKeys.zTaurus),
    (value: 'Gémeaux', labelKey: TrKeys.zGemini),
    (value: 'Cancer', labelKey: TrKeys.zCancer),
    (value: 'Lion', labelKey: TrKeys.zLeo),
    (value: 'Vierge', labelKey: TrKeys.zVirgo),
    (value: 'Balance', labelKey: TrKeys.zLibra),
    (value: 'Scorpion', labelKey: TrKeys.zScorpio),
    (value: 'Sagittaire', labelKey: TrKeys.zSagittarius),
    (value: 'Capricorne', labelKey: TrKeys.zCapricorn),
    (value: 'Verseau', labelKey: TrKeys.zAquarius),
    (value: 'Poissons', labelKey: TrKeys.zPisces),
  ];

  final step = 0.obs;
  final saving = false.obs;

  final gender = ''.obs;
  final lookingFor = ''.obs;
  final ageRange = ''.obs;
  final zodiacSign = RxnString();
  final photo = RxnString(); // data:image/jpeg;base64,...

  final ageCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final bioCtrl = TextEditingController();
  final hobbiesCtrl = TextEditingController();
  final religionCtrl = TextEditingController();
  final heightCtrl = TextEditingController();

  /// Drives the Next button, which has to react as fields are typed.
  final _formTick = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Registration already asked for an age; carry it over so the member is not
    // asked twice, exactly as the website does.
    final age = AuthService.to.user?.age;
    if (age != null) ageCtrl.text = '$age';

    for (final c in [ageCtrl, locationCtrl]) {
      c.addListener(() => _formTick.value++);
    }
  }

  @override
  void onClose() {
    for (final c in [
      ageCtrl,
      locationCtrl,
      bioCtrl,
      hobbiesCtrl,
      religionCtrl,
      heightCtrl,
    ]) {
      c.dispose();
    }
    super.onClose();
  }

  bool get isLastStep => step.value == stepCount - 1;

  /// Which steps are mandatory, matching the website's `canNext`. The last
  /// three collect optional detail and can be skipped straight through.
  bool get canContinue {
    _formTick.value; // read so Obx rebuilds when the text fields change
    return switch (step.value) {
      0 => gender.value.isNotEmpty,
      1 => (int.tryParse(ageCtrl.text.trim()) ?? 0) >= 18,
      2 => lookingFor.value.isNotEmpty,
      3 => ageRange.value.isNotEmpty,
      4 => locationCtrl.text.trim().isNotEmpty,
      5 => photo.value != null,
      _ => true,
    };
  }

  void next() {
    if (!canContinue || saving.value) return;
    if (isLastStep) {
      _save();
    } else {
      step.value++;
    }
  }

  void previous() {
    if (step.value > 0) step.value--;
  }

  Future<void> pickPhoto(ImageSource source) async {
    try {
      // The same treatment the website applies before upload: longest side
      // capped at 800 and re-encoded as JPEG, because the photo is stored as a
      // base64 string inside the user document and nginx caps the body size.
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 70,
      );
      if (file == null) return;

      final bytes = await file.readAsBytes();
      photo.value = 'data:image/jpeg;base64,${base64Encode(bytes)}';
    } catch (_) {
      Get.snackbar(TrKeys.error.tr, TrKeys.psPhotoError.tr,
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void removePhoto() => photo.value = null;

  Future<void> _save() async {
    saving.value = true;
    try {
      // Field for field what the website's wizard sends. `height` goes as a
      // string because that is how the backend stores it.
      await AuthService.to.updateProfile({
        'gender': gender.value,
        'lookingFor': lookingFor.value,
        'ageRange': ageRange.value,
        'location': locationCtrl.text.trim(),
        'photo': photo.value,
        'bio': bioCtrl.text.trim(),
        'hobbies': hobbiesCtrl.text.trim(),
        'zodiacSign': zodiacSign.value ?? '',
        'religion': religionCtrl.text.trim(),
        'height': heightCtrl.text.trim(),
        'age': int.tryParse(ageCtrl.text.trim()),
      });

      Get.offAllNamed(AppRoutes.home);
    } on ApiException catch (e) {
      Get.snackbar(TrKeys.error.tr, e.message,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      saving.value = false;
    }
  }
}
