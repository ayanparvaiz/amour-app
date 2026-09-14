import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/localization/translation_keys.dart';
import '../../data/providers/api_client.dart';
import '../../data/services/auth_service.dart';
import '../profile_setup/profile_setup_controller.dart';

/// Editing the signed-in member's own profile.
class SettingsController extends GetxController {
  SettingsController({ImagePicker? picker, GeolocatorPlatform? geolocator})
      : _picker = picker ?? ImagePicker(),
        _geolocator = geolocator ?? GeolocatorPlatform.instance;

  final ImagePicker _picker;
  final GeolocatorPlatform _geolocator;

  final nameCtrl = TextEditingController();
  final ageCtrl = TextEditingController();
  final bioCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final countryCtrl = TextEditingController();
  final departmentCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final hobbiesCtrl = TextEditingController();
  final activitiesCtrl = TextEditingController();
  final religionCtrl = TextEditingController();
  final heightCtrl = TextEditingController();
  final weightCtrl = TextEditingController();
  final eyeColorCtrl = TextEditingController();
  final hairColorCtrl = TextEditingController();

  final gender = RxnString();
  final lookingFor = RxnString();
  final ageRange = RxnString();
  final zodiacSign = RxnString();
  final children = RxnString();
  final smoke = RxnString();
  final alcohol = RxnString();

  /// Every photo, main one first. The server keeps `photo` and `photos`
  /// separately; the first entry here is sent as `photo`.
  final photos = <String>[].obs;
  final coordinates = Rxn<(double, double)>();

  final saving = false.obs;
  final locating = false.obs;
  final dirty = false.obs;

  @override
  void onInit() {
    super.onInit();
    _fill();
    for (final c in _textControllers) {
      c.addListener(() => dirty.value = true);
    }
  }

  List<TextEditingController> get _textControllers => [
        nameCtrl, ageCtrl, bioCtrl, locationCtrl, countryCtrl, departmentCtrl,
        cityCtrl, hobbiesCtrl, activitiesCtrl, religionCtrl, heightCtrl,
        weightCtrl, eyeColorCtrl, hairColorCtrl,
      ];

  @override
  void onClose() {
    for (final c in _textControllers) {
      c.dispose();
    }
    super.onClose();
  }

  void _fill() {
    final user = AuthService.to.user;
    if (user == null) return;

    nameCtrl.text = user.name;
    ageCtrl.text = user.age?.toString() ?? '';
    bioCtrl.text = user.bio ?? '';
    locationCtrl.text = user.location ?? '';
    countryCtrl.text = user.country ?? '';
    departmentCtrl.text = user.department ?? '';
    cityCtrl.text = user.city ?? '';
    hobbiesCtrl.text = user.hobbies ?? '';
    activitiesCtrl.text = user.favoriteActivities ?? '';
    religionCtrl.text = user.religion ?? '';
    heightCtrl.text = user.height ?? '';
    weightCtrl.text = user.weight ?? '';
    eyeColorCtrl.text = user.eyeColor ?? '';
    hairColorCtrl.text = user.hairColor ?? '';

    gender.value = _orNull(user.gender);
    lookingFor.value = _orNull(user.lookingFor);
    ageRange.value = _orNull(user.ageRange);
    zodiacSign.value = _orNull(user.zodiacSign);
    children.value = _orNull(user.children);
    smoke.value = _orNull(user.smoke);
    alcohol.value = _orNull(user.alcohol);

    // The main photo is not always inside `photos`, so merge and de-duplicate
    // the way the profile screen does.
    photos.assignAll({
      if ((user.photo ?? '').isNotEmpty) user.photo!,
      ...user.photos.where((p) => p.isNotEmpty),
    });
    coordinates.value = user.coordinates;

    // Filling the fields fires their listeners; the form is not dirty yet.
    dirty.value = false;
  }

  String? _orNull(String? v) => (v ?? '').isEmpty ? null : v;

  void select(RxnString field, String? value) {
    field.value = value;
    dirty.value = true;
  }

  // --- Photos ------------------------------------------------------------

  Future<void> addPhoto(ImageSource source) async {
    try {
      // Same treatment as the setup wizard: the photo is stored as base64
      // inside the user document, so it has to be small before it is sent.
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 70,
      );
      if (file == null) return;

      final bytes = await file.readAsBytes();
      photos.add('data:image/jpeg;base64,${base64Encode(bytes)}');
      dirty.value = true;
    } catch (_) {
      _error(TrKeys.psPhotoError.tr);
    }
  }

  void removePhoto(int index) {
    if (index < 0 || index >= photos.length) return;
    photos.removeAt(index);
    dirty.value = true;
  }

  /// Promotes a photo to first place, which is what the server stores as the
  /// main one.
  void makeMain(int index) {
    if (index <= 0 || index >= photos.length) return;
    final photo = photos.removeAt(index);
    photos.insert(0, photo);
    dirty.value = true;
  }

  // --- Location ----------------------------------------------------------

  Future<void> useCurrentPosition() async {
    locating.value = true;
    try {
      if (!await _geolocator.isLocationServiceEnabled()) {
        _error(TrKeys.setLocationOff.tr);
        return;
      }

      var permission = await _geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await _geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _error(TrKeys.setLocationDenied.tr);
        return;
      }

      // Distance search is by kilometres, so a rough fix is plenty and is much
      // quicker to obtain than a precise one.
      final position = await _geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
      );
      coordinates.value = (position.longitude, position.latitude);
      dirty.value = true;
    } catch (_) {
      _error(TrKeys.setLocationDenied.tr);
    } finally {
      locating.value = false;
    }
  }

  // --- Saving ------------------------------------------------------------

  Future<void> save() async {
    if (saving.value) return;
    saving.value = true;
    try {
      await AuthService.to.updateProfile({
        'name': nameCtrl.text.trim(),
        'age': int.tryParse(ageCtrl.text.trim()),
        'bio': bioCtrl.text.trim(),
        'gender': gender.value ?? '',
        'lookingFor': lookingFor.value ?? '',
        'ageRange': ageRange.value ?? '',
        'location': locationCtrl.text.trim(),
        'country': countryCtrl.text.trim(),
        'department': departmentCtrl.text.trim(),
        'city': cityCtrl.text.trim(),
        'hobbies': hobbiesCtrl.text.trim(),
        'favoriteActivities': activitiesCtrl.text.trim(),
        'zodiacSign': zodiacSign.value ?? '',
        'religion': religionCtrl.text.trim(),
        'children': children.value ?? '',
        'height': heightCtrl.text.trim(),
        'weight': weightCtrl.text.trim(),
        'eyeColor': eyeColorCtrl.text.trim(),
        'hairColor': hairColorCtrl.text.trim(),
        'smoke': smoke.value ?? '',
        'alcohol': alcohol.value ?? '',
        // The first photo is the main one; the rest form the gallery.
        'photo': photos.isEmpty ? '' : photos.first,
        'photos': photos.toList(),
        if (coordinates.value != null)
          'locationCoords': {
            'type': 'Point',
            'coordinates': [coordinates.value!.$1, coordinates.value!.$2],
          },
      });

      dirty.value = false;
      Get.back();
      Get.snackbar(TrKeys.setSaved.tr, nameCtrl.text.trim(),
          snackPosition: SnackPosition.BOTTOM);
    } on ApiException catch (e) {
      _error(e.message);
    } finally {
      saving.value = false;
    }
  }

  /// Guards the back arrow when there are unsaved edits.
  Future<bool> confirmLeave() async {
    if (!dirty.value) return true;

    final leave = await Get.dialog<bool>(
      AlertDialog(
        title: Text(TrKeys.setUnsavedTitle.tr),
        content: Text(TrKeys.setUnsavedBody.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(TrKeys.cancel.tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(TrKeys.setDiscard.tr),
          ),
        ],
      ),
    );
    return leave ?? false;
  }

  /// Star signs, shared with the setup wizard so both write the same strings.
  List<ZodiacOption> get zodiacOptions => ProfileSetupController.zodiacSigns;

  List<String> get ageRanges => ProfileSetupController.ageRanges;

  void _error(String message) =>
      Get.snackbar(TrKeys.error.tr, message, snackPosition: SnackPosition.BOTTOM);
}
