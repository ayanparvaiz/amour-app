import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/localization/translation_keys.dart';
import '../../data/models/profile_details.dart';
import '../../data/models/user_model.dart';
import '../../data/providers/api_client.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/services/auth_service.dart';
import '../../routes/app_routes.dart';

/// Shows one member's profile — the signed-in member when no id was passed,
/// somebody else when one was.
class ProfileController extends GetxController {
  ProfileController({UserRepository? repository, String? memberId})
      : _repo = repository ?? UserRepository(),
        _injectedId = memberId;

  final UserRepository _repo;

  /// Passed in by a test. Otherwise the id arrives as the route's argument.
  final String? _injectedId;

  /// Resolved in [onInit], never in the constructor: a binding runs before the
  /// route's arguments are attached, so reading them any earlier sees null —
  /// and null here means "my own profile", which is how every member's profile
  /// turned into your own.
  String? _memberId;

  final profile = Rxn<ProfileDetails>();
  final loading = true.obs;
  final error = RxnString();
  final activePhoto = 0.obs;
  final acting = false.obs;

  /// Keeps this screen on the session while it is open — see [onInit].
  Worker? _sessionWatch;

  /// No id means this is your own profile. An id that happens to be yours —
  /// tapping yourself in a list — counts as the same thing.
  bool get isOwn {
    if (_memberId == null || _memberId!.isEmpty) return true;
    final myId =
        Get.isRegistered<AuthService>() ? AuthService.to.user?.id : null;
    return _memberId == myId;
  }

  /// Whose profile this is showing. Exposed for tests and for the header.
  String? get memberId => _memberId;

  @override
  void onInit() {
    super.onInit();
    resolveMemberId();

    // The edit screen writes the saved profile straight into the session and
    // pops. Following the session means the change is already on screen when
    // the member lands back here, rather than after a pull to refresh.
    if (isOwn && Get.isRegistered<AuthService>()) {
      _sessionWatch = ever<UserModel?>(AuthService.to.userRx, (user) {
        if (user != null) profile.value = ProfileDetails.own(user);
      });
    }

    load();
  }

  @override
  void onClose() {
    _sessionWatch?.dispose();
    super.onClose();
  }

  /// Reads whose profile was asked for. Separate from [onInit] so it can be
  /// exercised without the screen's services being up.
  @visibleForTesting
  void resolveMemberId() {
    _memberId =
        _injectedId ?? (Get.arguments is String ? Get.arguments as String : null);
  }

  Future<void> load() async {
    loading.value = true;
    error.value = null;
    try {
      if (isOwn) {
        // Re-read first: the cached copy can be missing detail the server has,
        // and this screen is where that would show.
        final user = await AuthService.to.refresh() ?? AuthService.to.user;
        profile.value = user == null ? null : ProfileDetails.own(user);
      } else {
        profile.value = ProfileDetails.other(await _repo.profile(_memberId!));
      }
      activePhoto.value = 0;
    } on ApiException catch (e) {
      error.value = e.message;
    } finally {
      loading.value = false;
    }
  }

  void showPhoto(int index) => activePhoto.value = index;

  Future<void> like() async {
    final member = profile.value;
    if (member == null || acting.value) return;

    acting.value = true;
    try {
      final result = await _repo.like(member.id);
      Get.snackbar(
        result.isMatch ? TrKeys.discoverItsAMatch.tr : TrKeys.discoverLiked.tr,
        result.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } on ApiException catch (e) {
      _error(e.message);
    } finally {
      acting.value = false;
    }
  }

  Future<void> block() async {
    final member = profile.value;
    if (member == null) return;

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text(TrKeys.profileBlockTitle.trParams({'name': member.name})),
        content: Text(TrKeys.profileBlockBody.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(TrKeys.cancel.tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(TrKeys.profileBlock.tr),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _repo.block(member.id);
      // Blocking is mutual on the server, so there is nothing left to show.
      Get.offAllNamed(AppRoutes.discover);
      Get.snackbar(TrKeys.profileBlocked.tr, member.name,
          snackPosition: SnackPosition.BOTTOM);
    } on ApiException catch (e) {
      _error(e.message);
    }
  }

  Future<void> report() async {
    final member = profile.value;
    if (member == null) return;

    final reasonCtrl = TextEditingController();
    final reason = await Get.dialog<String>(
      AlertDialog(
        title: Text(TrKeys.profileReportTitle.trParams({'name': member.name})),
        content: TextField(
          controller: reasonCtrl,
          autofocus: true,
          minLines: 2,
          maxLines: 4,
          decoration: InputDecoration(hintText: TrKeys.profileReportHint.tr),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(TrKeys.cancel.tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: reasonCtrl.text.trim()),
            child: Text(TrKeys.profileReportSend.tr),
          ),
        ],
      ),
    );
    reasonCtrl.dispose();

    if (reason == null || reason.isEmpty) return;

    try {
      await _repo.report(userId: member.id, reason: reason);
      Get.snackbar(TrKeys.profileReport.tr, TrKeys.profileReported.tr,
          snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 4));
    } on ApiException catch (e) {
      _error(e.message);
    }
  }

  void _error(String message) =>
      Get.snackbar(TrKeys.error.tr, message, snackPosition: SnackPosition.BOTTOM);
}
