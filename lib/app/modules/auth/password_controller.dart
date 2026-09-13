import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/api_constants.dart';
import '../../core/localization/translation_keys.dart';
import '../../data/providers/api_client.dart';

/// Changing a password while signed in. Separate from [AuthController] because
/// it runs in a logged-in context and shares none of its fields.
///
/// Resetting a *forgotten* password is not here: the backend emails a link to
/// `FRONTEND_URL/reset-password/<token>`, which opens the website. Until the app
/// registers a deep link for that path, the reset finishes in the browser and
/// the member returns here to sign in — the same journey the website offers.
class PasswordController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final currentCtrl = TextEditingController();
  final newCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  final loading = false.obs;
  final obscure = true.obs;

  final ApiClient _api = ApiClient();

  @override
  void onClose() {
    currentCtrl.dispose();
    newCtrl.dispose();
    confirmCtrl.dispose();
    super.onClose();
  }

  void toggleObscure() => obscure.toggle();

  String? validateCurrent(String? v) =>
      (v ?? '').isEmpty ? TrKeys.enterCurrentPassword.tr : null;

  String? validateNew(String? v) {
    if ((v ?? '').isEmpty) return TrKeys.enterNewPassword.tr;
    if ((v ?? '').length < 6) return TrKeys.passwordTooShort.tr;
    if (v == currentCtrl.text) return TrKeys.chooseDifferentPassword.tr;
    return null;
  }

  String? validateConfirm(String? v) =>
      v != newCtrl.text ? TrKeys.passwordsDoNotMatch.tr : null;

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    loading.value = true;
    try {
      await _api.post(ApiConstants.changePassword, body: {
        'currentPassword': currentCtrl.text,
        'newPassword': newCtrl.text,
      });

      currentCtrl.clear();
      newCtrl.clear();
      confirmCtrl.clear();

      Get.back();
      Get.snackbar(
        TrKeys.passwordChanged.tr,
        TrKeys.passwordChangedBody.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } on ApiException catch (e) {
      Get.snackbar(TrKeys.error.tr, e.message, snackPosition: SnackPosition.BOTTOM);
    } finally {
      loading.value = false;
    }
  }
}
