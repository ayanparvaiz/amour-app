import 'package:get/get.dart';

import '../core/localization/translation_keys.dart';
import '../modules/auth/auth_controller.dart';
import '../modules/auth/change_password_view.dart';
import '../modules/auth/forgot_password_view.dart';
import '../modules/auth/login_view.dart';
import '../modules/auth/password_controller.dart';
import '../modules/auth/register_view.dart';
import '../modules/home/home_view.dart';
import '../modules/placeholder/placeholder_view.dart';
import '../modules/splash/splash_view.dart';
import 'app_routes.dart';

/// Binding for the signed-out auth screens. They share one controller so the
/// email typed on sign-in is still there on the forgot-password screen, the way
/// the website's single auth page behaves. `fenix` rebuilds it if the member
/// comes back after it was disposed.
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
  }
}

class PasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PasswordController>(() => PasswordController());
  }
}

class AppPages {
  AppPages._();

  static const initial = AppRoutes.splash;

  static final routes = <GetPage>[
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.changePassword,
      page: () => const ChangePasswordView(),
      binding: PasswordBinding(),
    ),
    GetPage(
      name: AppRoutes.profileSetup,
      page: () => PlaceholderView(
        title: TrKeys.yourProfile.tr,
        note: TrKeys.profileSetupNote.tr,
      ),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
    ),
  ];
}
