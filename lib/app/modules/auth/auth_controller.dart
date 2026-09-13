import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    if (v.isEmpty) return 'Entrez votre email';
    if (!GetUtils.isEmail(v)) return 'Cet email ne semble pas valide';
    return null;
  }

  String? validatePassword(String? value) {
    if ((value ?? '').isEmpty) return 'Entrez votre mot de passe';
    if ((value ?? '').length < 6) return 'Au moins 6 caractères';
    return null;
  }

  String? validateName(String? value) =>
      (value ?? '').trim().isEmpty ? 'Entrez votre prénom' : null;

  String? validateAge(String? value) {
    final age = int.tryParse((value ?? '').trim());
    if (age == null) return 'Entrez votre âge';
    if (age < 18) return 'Vous devez avoir au moins 18 ans';
    if (age > 99) return 'Âge invalide';
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
      // Registration always lands on the wizard — a new account has no gender yet.
      Get.offAllNamed(AppRoutes.profileSetup);
    });
  }

  Future<void> forgotPassword() async {
    final email = emailCtrl.text.trim();
    if (validateEmail(email) != null) {
      _error('Entrez d\'abord votre email, puis réessayez.');
      return;
    }
    await _run(() async {
      await AuthService.to.forgotPassword(email);
      Get.snackbar(
        'Email envoyé',
        'Un lien de réinitialisation a été envoyé à votre adresse email.',
        snackPosition: SnackPosition.BOTTOM,
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
        'Erreur',
        message,
        snackPosition: SnackPosition.BOTTOM,
      );
}
