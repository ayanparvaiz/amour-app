import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
        title: const Text('Créer un compte'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: Get.back,
          tooltip: 'Retour',
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
                    Text('Commencez votre voyage vers l\'amour',
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
                            decoration: const InputDecoration(
                              labelText: 'Prénom',
                              hintText: 'Emma',
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
                            decoration: const InputDecoration(
                              labelText: 'Âge',
                              hintText: '25',
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
                          autofillHints: const [AutofillHints.newPassword],
                          onFieldSubmitted: (_) => controller.register(),
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
                              : const Text('Créer un compte'),
                        )),
                    const SizedBox(height: 14),

                    Text(
                      'Vous devez avoir au moins 18 ans pour vous inscrire.',
                      style: text.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Vous avez déjà un compte ?', style: text.bodySmall),
                        TextButton(
                          onPressed: Get.back,
                          child: const Text('Se connecter'),
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
