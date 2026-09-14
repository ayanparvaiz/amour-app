import 'package:get/get.dart';

import '../../data/models/match_model.dart';
import '../../data/providers/api_client.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/services/auth_service.dart';

class HomeController extends GetxController {
  HomeController({UserRepository? repository})
      : _repo = repository ?? UserRepository();

  final UserRepository _repo;

  final matches = <MatchModel>[].obs;
  final loading = true.obs;
  final error = RxnString();

  /// How many members have liked this one, and the first few of them.
  ///
  /// The server blanks the list for free accounts but still sends the count,
  /// so a free member is told how many are waiting without being shown who.
  final likedByCount = 0.obs;
  final likedBy = <MatchModel>[].obs;

  /// How many of the strict matches the home row shows. The rest live in
  /// Discover; this is a taste, not the full list.
  static const int previewCount = 6;

  /// Faces on the likes card. More than this and they stop reading as people.
  static const int facePileCount = 3;

  bool get canSeeWhoLikedYou =>
      AuthService.to.user?.canSeeWhoLikedYou ?? false;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    error.value = null;
    // Two independent reads, started together — the screen waits for the
    // slower of them rather than for their sum.
    final matchesCall = _loadMatches();
    final likesCall = _loadLikes();
    await Future.wait([matchesCall, likesCall]);
    loading.value = false;
  }

  Future<void> _loadMatches() async {
    try {
      // No discover mode here: the home row is the strict, two-way matches —
      // people whose own preferences point back at this member.
      final result = await _repo.matches();
      matches.assignAll(result.take(previewCount));
    } on ApiException catch (e) {
      error.value = e.message;
    }
  }

  /// A failure here is left silent on purpose. The likes card is an extra; if
  /// the call fails the card simply does not appear, rather than covering the
  /// profiles — which are what the screen is for — with an error.
  Future<void> _loadLikes() async {
    try {
      final result = await _repo.affinities();
      likedByCount.value = result.likedByCount;
      likedBy.assignAll(result.likedBy.take(facePileCount));
    } on ApiException {
      likedByCount.value = 0;
      likedBy.clear();
    }
  }

  /// Pull to refresh re-reads the profile as well, so a plan bought on the
  /// website shows up here without signing out and back in.
  Future<void> refreshAll() async {
    await AuthService.to.refresh();
    await load();
  }
}
