import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/filter_options.dart';
import '../../core/localization/translation_keys.dart';
import '../../data/models/match_model.dart';
import '../../data/providers/api_client.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/services/auth_service.dart';

class DiscoverController extends GetxController {
  DiscoverController({UserRepository? repository})
      : _repo = repository ?? UserRepository();

  final UserRepository _repo;

  final profiles = <MatchModel>[].obs;
  final loading = true.obs;
  final error = RxnString();

  // --- Filters -----------------------------------------------------------
  final searchLevel = SearchLevel.worldwide.obs;
  final radiusKm = 50.0.obs;
  final smoke = RxnString();
  final alcohol = RxnString();
  final children = RxnString();
  final eyeColor = RxnString();
  final hairColor = RxnString();
  final ageMinCtrl = TextEditingController();
  final ageMaxCtrl = TextEditingController();
  final keywordCtrl = TextEditingController();

  /// Whether the advanced section is usable. The server applies those filters
  /// only for Premium and Prestige and silently drops them otherwise, so the
  /// panel locks them rather than letting someone set criteria that quietly do
  /// nothing.
  bool get canUseAdvanced => AuthService.to.user?.canUseAdvancedFilters ?? false;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  @override
  void onClose() {
    ageMinCtrl.dispose();
    ageMaxCtrl.dispose();
    keywordCtrl.dispose();
    super.onClose();
  }

  Future<void> load() async {
    loading.value = true;
    error.value = null;
    try {
      final result = await _repo.matches(
        // Discover relaxes the two-way gender and age requirements, so it shows
        // more people than the home row does. The website sends the same flag.
        discoverMode: true,
        searchLevel: searchLevel.value.value,
        filters: _query(),
      );
      profiles.assignAll(result);
    } on ApiException catch (e) {
      error.value = e.message;
    } finally {
      loading.value = false;
    }
  }

  Map<String, dynamic> _query() {
    final user = AuthService.to.user;
    final query = <String, dynamic>{
      'smoke': ?smoke.value,
      'alcohol': ?alcohol.value,
      'children': ?children.value,
    };

    if (searchLevel.value == SearchLevel.radius) {
      query['radius'] = radiusKm.value.round();
      // The server needs coordinates for a radius search. They come from the
      // profile, which only has them once the member has granted location.
      final coords = user?.coordinates;
      if (coords != null) {
        query['lng'] = coords.$1;
        query['lat'] = coords.$2;
      }
    }

    if (canUseAdvanced) {
      query.addAll({
        'eyeColor': ?eyeColor.value,
        'hairColor': ?hairColor.value,
        'ageMin': ?_digits(ageMinCtrl.text),
        'ageMax': ?_digits(ageMaxCtrl.text),
        'keyword': ?_trimmed(keywordCtrl.text),
      });
    }

    return query;
  }

  String? _digits(String raw) {
    final n = int.tryParse(raw.trim());
    return n == null ? null : '$n';
  }

  String? _trimmed(String raw) => raw.trim().isEmpty ? null : raw.trim();

  void reset() {
    searchLevel.value = SearchLevel.worldwide;
    radiusKm.value = 50;
    smoke.value = null;
    alcohol.value = null;
    children.value = null;
    eyeColor.value = null;
    hairColor.value = null;
    ageMinCtrl.clear();
    ageMaxCtrl.clear();
    keywordCtrl.clear();
  }

  // --- Actions -----------------------------------------------------------

  /// Liking and passing both remove the profile from the list, because the
  /// server excludes it from every later response anyway — leaving it on screen
  /// would let someone act on it twice.
  Future<void> like(MatchModel profile) async {
    final removed = _remove(profile);
    try {
      final result = await _repo.like(profile.id);
      Get.snackbar(
        result.isMatch ? TrKeys.discoverItsAMatch.tr : TrKeys.discoverLiked.tr,
        result.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } on ApiException catch (e) {
      _restore(profile, removed);
      _error(e.message);
    }
  }

  Future<void> pass(MatchModel profile) async {
    final removed = _remove(profile);
    try {
      await _repo.pass(profile.id);
    } on ApiException catch (e) {
      _restore(profile, removed);
      _error(e.message);
    }
  }

  int _remove(MatchModel profile) {
    final index = profiles.indexWhere((p) => p.id == profile.id);
    if (index >= 0) profiles.removeAt(index);
    return index;
  }

  /// Put a profile back where it was when the server rejected the action.
  void _restore(MatchModel profile, int index) {
    if (index < 0) return;
    profiles.insert(index.clamp(0, profiles.length), profile);
  }

  void _error(String message) =>
      Get.snackbar(TrKeys.error.tr, message, snackPosition: SnackPosition.BOTTOM);
}
