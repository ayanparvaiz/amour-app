import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'auth_controller.dart';

/// Sends the reset email. The link inside it opens the website, where the
/// member sets a new password and then returns here to sign in — the app does
/// not yet register a deep link for `/reset-password/<token>`.
class ForgotPasswordView extends GetView<AuthController> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mot de passe oublié'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: Get.back,
          tooltip: 'Retour',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.lock_reset_rounded, size: 44, color: scheme.primary),
                  const SizedBox(height: 16),
                  Text('Réinitialiser le mot de passe',
                      style: text.headlineMedium, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text(
                    'Entrez votre email et nous vous enverrons un lien pour choisir un nouveau mot de passe.',
                    style: text.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 26),

                  TextFormField(
                    controller: controller.emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.email],
                    onFieldSubmitted: (_) => controller.forgotPassword(),
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'vous@exemple.com',
                    ),
                  ),
                  const SizedBox(height: 20),

                  Obx(() => FilledButton(
                        onPressed: controller.loading.value
                            ? null
                            : controller.forgotPassword,
                        child: controller.loading.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.2, color: Colors.white),
                              )
                            : const Text('Envoyer le lien'),
                      )),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline_rounded,
                            size: 18, color: scheme.onSurfaceVariant),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Le lien s\'ouvrira dans votre navigateur. Une fois votre '
                            'mot de passe modifié, revenez ici pour vous connecter. '
                            'Le lien expire après une heure.',
                            style: text.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
