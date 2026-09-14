import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/filter_options.dart';
import '../../core/localization/translation_keys.dart';
import '../../core/widgets/swipe_card.dart';
import '../../core/widgets/swipe_deck.dart';
import '../../data/models/match_model.dart';
import '../../data/providers/api_client.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/services/auth_service.dart';

class DiscoverController extends GetxController {
  DiscoverController({UserRepository? repository})
      : _repo = repository ?? UserRepository();

  final UserRepository _repo;

  final profiles = <MatchModel>[].obs;

  /// Lets the buttons throw a card the same way a drag does, so deciding with
  /// a thumb and deciding with a finger behave identically.
  final deck = SwipeDeckController();
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

  // --- The deck ----------------------------------------------------------

  void likeTop() => deck.like();
  void passTop() => deck.pass();

  /// Super likes are Premium and Prestige only. The server refuses anyone else,
  /// so the card is not thrown — it would be dealt straight back.
  Future<void> superLikeTop() async {
    final profile = profiles.isEmpty ? null : profiles.first;
    if (profile == null || deck.isBusy) return;

    if (!(AuthService.to.user?.canSuperLike ?? false)) {
      Get.snackbar(TrKeys.swipeSuper.tr, TrKeys.swipeSuperLocked.tr,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4));
      return;
    }

    // Throw it first: waiting on the network before the card moves makes the
    // button feel broken.
    deck.like();
    try {
      final result = await _repo.superLike(profile.id);
      Get.snackbar(
        result.isMatch ? TrKeys.discoverItsAMatch.tr : TrKeys.swipeSuper.tr,
        result.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } on ApiException catch (e) {
      _error(e.message);
    }
  }

  /// Called once a card has left the screen. The profile is dropped either way:
  /// the server excludes a liked or passed member from every later response, so
  /// putting it back would only offer a decision that has already been recorded.
  Future<void> onSwiped(MatchModel profile, SwipeDirection direction) async {
    profiles.removeWhere((p) => p.id == profile.id);

    try {
      if (direction == SwipeDirection.like) {
        final result = await _repo.like(profile.id);
        if (result.isMatch) {
          Get.snackbar(TrKeys.discoverItsAMatch.tr, result.message,
              snackPosition: SnackPosition.BOTTOM);
        }
      } else {
        await _repo.pass(profile.id);
      }
    } on ApiException catch (e) {
      _error(e.message);
    }
  }

  void _error(String message) =>
      Get.snackbar(TrKeys.error.tr, message, snackPosition: SnackPosition.BOTTOM);
}
