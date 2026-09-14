import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/api_constants.dart';
import '../../core/localization/translation_keys.dart';
import '../../data/providers/api_client.dart';
import '../../data/services/auth_service.dart';

/// The settings menu. Only account deletion needs any logic; everything else
/// on the screen is a link.
class SettingsController extends GetxController {
  SettingsController({ApiClient? api}) : _api = api ?? ApiClient();

  final ApiClient _api;

  final deleting = false.obs;

  /// Asks twice — a dialog, then the word itself typed out — because there is
  /// no way back from this one.
  Future<void> deleteAccount() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text(TrKeys.setDeleteConfirmTitle.tr),
        content: Text(TrKeys.setDeleteConfirmBody.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(TrKeys.cancel.tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              TrKeys.setDeleteAccount.tr,
              style: TextStyle(color: Get.theme.colorScheme.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    if (!await _typedTheWord()) return;

    deleting.value = true;
    try {
      await _api.delete(ApiConstants.me);
      await AuthService.to.signOut();
      Get.snackbar(TrKeys.setDeleteAccount.tr, TrKeys.setDeleted.tr,
          snackPosition: SnackPosition.BOTTOM);
    } on ApiException catch (e) {
      // The backend has no self-deletion route yet — only the admin one — so
      // this reports whatever it says until DELETE /users/me exists.
      Get.snackbar(TrKeys.error.tr, e.message,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5));
    } finally {
      deleting.value = false;
    }
  }

  Future<bool> _typedTheWord() async {
    final word = TrKeys.setDeleteWord.tr;
    final controller = TextEditingController();
    final match = false.obs;
    controller.addListener(
      () => match.value = controller.text.trim().toUpperCase() == word,
    );

    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(TrKeys.setDeleteConfirmTitle.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(TrKeys.setDeleteTypeToConfirm.trParams({'word': word})),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(hintText: word),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(TrKeys.cancel.tr),
          ),
          Obx(() => TextButton(
                onPressed: match.value ? () => Get.back(result: true) : null,
                child: Text(
                  TrKeys.setDeleteAccount.tr,
                  style: TextStyle(
                    color: match.value ? Get.theme.colorScheme.error : null,
                  ),
                ),
              )),
        ],
      ),
    );

    controller.dispose();
    return result ?? false;
  }

  Future<void> signOut() async {
    final leave = await Get.dialog<bool>(
      AlertDialog(
        title: Text(TrKeys.signOutConfirmTitle.tr),
        content: Text(TrKeys.signOutConfirmBody.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(TrKeys.cancel.tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(TrKeys.signOut.tr),
          ),
        ],
      ),
    );
    if (leave ?? false) await AuthService.to.signOut();
  }
}
