import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/localization/translation_keys.dart';
import '../../core/widgets/app_logo.dart';
import 'auth_controller.dart';

/// Same fields the website's registration form collects: prénom, âge, email
/// and password. The backend assigns the Free plan and signs the member in, so
/// this goes straight to the profile wizard on success.
class RegisterView extends GetView<AuthController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(TrKeys.registerTitle.tr),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: Get.back,
          tooltip: TrKeys.back.tr,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: controller.registerFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: AppLogo(size: 64)),
                    const SizedBox(height: 18),
                    Text(TrKeys.registerHeadline.tr,
                        style: text.headlineMedium, textAlign: TextAlign.center),
                    const SizedBox(height: 26),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: controller.nameCtrl,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.givenName],
                            decoration: InputDecoration(
                              labelText: TrKeys.firstName.tr,
                              hintText: TrKeys.firstNameHint.tr,
                            ),
                            validator: controller.validateName,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: controller.ageCtrl,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: TrKeys.age.tr,
                              hintText: TrKeys.ageHint.tr,
                            ),
                            validator: controller.validateAge,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: controller.emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      decoration: InputDecoration(
                        labelText: TrKeys.email.tr,
                        hintText: TrKeys.emailHint.tr,
                      ),
                      validator: controller.validateEmail,
                    ),
                    const SizedBox(height: 14),

                    Obx(() => TextFormField(
                          controller: controller.passwordCtrl,
                          obscureText: controller.obscurePassword.value,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.newPassword],
                          onFieldSubmitted: (_) => controller.register(),
                          decoration: InputDecoration(
                            labelText: TrKeys.password.tr,
                            suffixIcon: IconButton(
                              icon: Icon(controller.obscurePassword.value
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined),
                              onPressed: controller.toggleObscure,
                              tooltip: controller.obscurePassword.value
                                  ? TrKeys.showPassword.tr
                                  : TrKeys.hidePassword.tr,
                            ),
                          ),
                          validator: controller.validatePassword,
                        )),
                    const SizedBox(height: 24),

                    Obx(() => FilledButton(
                          onPressed:
                              controller.loading.value ? null : controller.register,
                          child: controller.loading.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.2, color: Colors.white),
                                )
                              : Text(TrKeys.createAccount.tr),
                        )),
                    const SizedBox(height: 14),

                    Text(
                      TrKeys.minimumAgeNotice.tr,
                      style: text.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),

                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(TrKeys.alreadyHaveAccount.tr, style: text.bodySmall),
                        TextButton(
                          onPressed: Get.back,
                          child: Text(TrKeys.signIn.tr),
                        ),
                      ],
                    ),
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
