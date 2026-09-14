import 'package:get/get.dart';

import '../../core/localization/translation_keys.dart';
import '../../data/models/match_model.dart';
import '../../data/providers/api_client.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/services/auth_service.dart';

class MatchesController extends GetxController {
  MatchesController({UserRepository? repository})
      : _repo = repository ?? UserRepository();

  final UserRepository _repo;

  final mutual = <MatchModel>[].obs;
  final received = <MatchModel>[].obs;
  final sent = <MatchModel>[].obs;

  /// How many members have liked this one. The server blanks [received] for
  /// free accounts but still sends the count, so the paywall can say how many
  /// are waiting — which is the whole reason the count exists.
  final receivedCount = 0.obs;

  final loading = true.obs;
  final error = RxnString();

  bool get canSeeReceived => AuthService.to.user?.canSeeWhoLikedYou ?? false;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    error.value = null;
    try {
      final result = await _repo.affinities();
      mutual.assignAll(result.matches);
      received.assignAll(result.likedBy);
      sent.assignAll(result.likesSent);
      receivedCount.value = result.likedByCount;
    } on ApiException catch (e) {
      error.value = e.message;
    } finally {
      loading.value = false;
    }
  }

  /// Liking somebody back from the received tab. A mutual like makes a match,
  /// so the lists are re-read rather than patched.
  Future<void> like(MatchModel member) async {
    try {
      final result = await _repo.like(member.id);
      Get.snackbar(
        result.isMatch ? TrKeys.discoverItsAMatch.tr : TrKeys.discoverLiked.tr,
        result.message,
        snackPosition: SnackPosition.BOTTOM,
      );
      await load();
    } on ApiException catch (e) {
      _error(e.message);
    }
  }

  Future<void> pass(MatchModel member) async {
    received.removeWhere((m) => m.id == member.id);
    try {
      await _repo.pass(member.id);
    } on ApiException catch (e) {
      _error(e.message);
      await load(); // put it back the way the server sees it
    }
  }

  void _error(String message) =>
      Get.snackbar(TrKeys.error.tr, message, snackPosition: SnackPosition.BOTTOM);
}
