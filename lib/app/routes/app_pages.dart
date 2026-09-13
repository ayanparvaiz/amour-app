import 'package:get/get.dart';

import '../modules/auth/auth_controller.dart';
import '../modules/auth/login_view.dart';
import '../modules/home/home_view.dart';
import '../modules/placeholder/placeholder_view.dart';
import '../modules/splash/splash_view.dart';
import 'app_routes.dart';

/// Binding for the auth screens. `fenix` lets the controller be rebuilt if the
/// user returns to sign-in after it was disposed.
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
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
      page: () => const PlaceholderView(
        title: 'Créer un compte',
        note: "Le formulaire d'inscription arrive avec les autres écrans.",
      ),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.profileSetup,
      page: () => const PlaceholderView(
        title: 'Votre profil',
        note: 'Les neuf étapes de configuration du profil arrivent ensuite.',
      ),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
    ),
  ];
}
