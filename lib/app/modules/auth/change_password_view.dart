import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/localization/translation_keys.dart';
import 'password_controller.dart';

/// Changing the password while signed in. The website puts this inside its
/// settings page; here it is its own screen, reachable once settings is built.
class ChangePasswordView extends GetView<PasswordController> {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TrKeys.changePasswordTitle.tr),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: Get.back,
          tooltip: TrKeys.back.tr,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Obx(() => TextFormField(
                          controller: controller.currentCtrl,
                          obscureText: controller.obscure.value,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.password],
                          decoration: InputDecoration(
                            labelText: TrKeys.currentPassword.tr,
                            suffixIcon: IconButton(
                              icon: Icon(controller.obscure.value
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined),
                              onPressed: controller.toggleObscure,
                              tooltip: controller.obscure.value
                                  ? TrKeys.showPasswords.tr
                                  : TrKeys.hidePasswords.tr,
                            ),
                          ),
                          validator: controller.validateCurrent,
                        )),
                    const SizedBox(height: 14),

                    Obx(() => TextFormField(
                          controller: controller.newCtrl,
                          obscureText: controller.obscure.value,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.newPassword],
                          decoration: InputDecoration(
                            labelText: TrKeys.newPassword.tr,
                          ),
                          validator: controller.validateNew,
                        )),
                    const SizedBox(height: 14),

                    Obx(() => TextFormField(
                          controller: controller.confirmCtrl,
                          obscureText: controller.obscure.value,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => controller.submit(),
                          decoration: InputDecoration(
                            labelText: TrKeys.confirmNewPassword.tr,
                          ),
                          validator: controller.validateConfirm,
                        )),
                    const SizedBox(height: 24),

                    Obx(() => FilledButton(
                          onPressed:
                              controller.loading.value ? null : controller.submit,
                          child: controller.loading.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.2, color: Colors.white),
                                )
                              : Text(TrKeys.update.tr),
                        )),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
