import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/localization/translation_keys.dart';
import '../../data/providers/api_client.dart';
import '../../data/services/auth_service.dart';
import '../../routes/app_routes.dart';

class AuthController extends GetxController {
  final loginFormKey = GlobalKey<FormState>();
  final registerFormKey = GlobalKey<FormState>();

  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final ageCtrl = TextEditingController();

  final loading = false.obs;
  final obscurePassword = true.obs;

  @override
  void onClose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    nameCtrl.dispose();
    ageCtrl.dispose();
    super.onClose();
  }

  void toggleObscure() => obscurePassword.toggle();

  // --- Validators --------------------------------------------------------

  String? validateEmail(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return TrKeys.enterEmail.tr;
    if (!GetUtils.isEmail(v)) return TrKeys.emailLooksWrong.tr;
    return null;
  }

  String? validatePassword(String? value) {
    if ((value ?? '').isEmpty) return TrKeys.enterPassword.tr;
    if ((value ?? '').length < 6) return TrKeys.passwordTooShort.tr;
    return null;
  }

  String? validateName(String? value) =>
      (value ?? '').trim().isEmpty ? TrKeys.enterFirstName.tr : null;

  String? validateAge(String? value) {
    final age = int.tryParse((value ?? '').trim());
    if (age == null) return TrKeys.enterAge.tr;
    if (age < 18) return TrKeys.mustBe18.tr;
    if (age > 99) return TrKeys.invalidAge.tr;
    return null;
  }

  // --- Actions -----------------------------------------------------------

  Future<void> login() async {
    if (!(loginFormKey.currentState?.validate() ?? false)) return;
    await _run(() async {
      final user = await AuthService.to.login(
        email: emailCtrl.text,
        password: passwordCtrl.text,
      );
      Get.offAllNamed(user.needsProfileSetup ? AppRoutes.profileSetup : AppRoutes.home);
    });
  }

  Future<void> register() async {
    if (!(registerFormKey.currentState?.validate() ?? false)) return;
    await _run(() async {
      await AuthService.to.register(
        name: nameCtrl.text,
        email: emailCtrl.text,
        password: passwordCtrl.text,
        age: int.parse(ageCtrl.text.trim()),
      );
      Get.snackbar(
        TrKeys.accountCreated.tr,
        TrKeys.welcomeAboard.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      // Registration always lands on the wizard — a new account has no gender yet.
      Get.offAllNamed(AppRoutes.profileSetup);
    });
  }

  Future<void> forgotPassword() async {
    final email = emailCtrl.text.trim();
    if (validateEmail(email) != null) {
      _error(TrKeys.enterEmailFirst.tr);
      return;
    }
    await _run(() async {
      await AuthService.to.forgotPassword(email);
      // The website drops back to sign-in once the mail is away; do the same.
      if (Get.currentRoute == AppRoutes.forgotPassword) Get.back();
      Get.snackbar(
        TrKeys.emailSent.tr,
        TrKeys.resetLinkSent.tr,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    loading.value = true;
    try {
      await action();
    } on ApiException catch (e) {
      _error(e.message);
    } finally {
      loading.value = false;
    }
  }

  void _error(String message) => Get.snackbar(
        TrKeys.error.tr,
        message,
        snackPosition: SnackPosition.BOTTOM,
      );
}
