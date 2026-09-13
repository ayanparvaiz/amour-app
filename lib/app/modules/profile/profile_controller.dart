import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/localization/translation_keys.dart';
import '../../data/models/profile_details.dart';
import '../../data/providers/api_client.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/services/auth_service.dart';
import '../../routes/app_routes.dart';

/// Shows one member's profile — the signed-in member when no id was passed,
/// somebody else when one was.
class ProfileController extends GetxController {
  ProfileController({UserRepository? repository, String? memberId})
      : _repo = repository ?? UserRepository(),
        _memberId = memberId ?? (Get.arguments is String ? Get.arguments as String : null);

  final UserRepository _repo;
  final String? _memberId;

  final profile = Rxn<ProfileDetails>();
  final loading = true.obs;
  final error = RxnString();
  final activePhoto = 0.obs;
  final acting = false.obs;

  bool get isOwn => _memberId == null || _memberId == AuthService.to.user?.id;

  @override
  void onInit() {
    super.onInit();
    load();
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
