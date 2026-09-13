import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/widgets/app_logo.dart';
import '../../routes/app_routes.dart';
import 'auth_controller.dart';

/// Deliberately plain for now — the real sign-in design comes with the rest of
/// the screens. This exists so the app runs end to end against the live API.
class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: controller.loginFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: AppLogo(size: 76)),
                    const SizedBox(height: 20),
                    Text('Bon retour parmi nous',
                        style: text.headlineMedium, textAlign: TextAlign.center),
                    const SizedBox(height: 6),
                    Text('Connectez-vous pour continuer',
                        style: text.bodySmall, textAlign: TextAlign.center),
                    const SizedBox(height: 30),

                    TextFormField(
                      controller: controller.emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'vous@exemple.com',
                      ),
                      validator: controller.validateEmail,
                    ),
                    const SizedBox(height: 14),

                    Obx(() => TextFormField(
                          controller: controller.passwordCtrl,
                          obscureText: controller.obscurePassword.value,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.password],
                          onFieldSubmitted: (_) => controller.login(),
                          decoration: InputDecoration(
                            labelText: 'Mot de passe',
                            suffixIcon: IconButton(
                              icon: Icon(controller.obscurePassword.value
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined),
                              onPressed: controller.toggleObscure,
                              tooltip: controller.obscurePassword.value
                                  ? 'Afficher le mot de passe'
                                  : 'Masquer le mot de passe',
                            ),
                          ),
                          validator: controller.validatePassword,
                        )),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: controller.forgotPassword,
                        child: const Text('Mot de passe oublié ?'),
                      ),
                    ),
                    const SizedBox(height: 8),

                    Obx(() => FilledButton(
                          onPressed: controller.loading.value ? null : controller.login,
                          child: controller.loading.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.2, color: Colors.white),
                                )
                              : const Text('Se connecter'),
                        )),
                    const SizedBox(height: 18),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Vous n'avez pas de compte ?", style: text.bodySmall),
                        TextButton(
                          onPressed: () => Get.toNamed(AppRoutes.register),
                          child: const Text("S'inscrire"),
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
