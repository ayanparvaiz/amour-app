import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/api_constants.dart';
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
      (v ?? '').isEmpty ? 'Entrez votre mot de passe actuel' : null;

  String? validateNew(String? v) {
    if ((v ?? '').isEmpty) return 'Entrez le nouveau mot de passe';
    if ((v ?? '').length < 6) return 'Au moins 6 caractères';
    if (v == currentCtrl.text) return 'Choisissez un mot de passe différent';
    return null;
  }

  String? validateConfirm(String? v) =>
      v != newCtrl.text ? 'Les mots de passe ne correspondent pas' : null;

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
        'Mot de passe modifié',
        'Votre mot de passe a été mis à jour 🎉',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on ApiException catch (e) {
      Get.snackbar('Erreur', e.message, snackPosition: SnackPosition.BOTTOM);
    } finally {
      loading.value = false;
    }
  }
}
