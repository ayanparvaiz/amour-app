import 'package:get/get.dart';

import '../modules/auth/auth_controller.dart';
import '../modules/auth/change_password_view.dart';
import '../modules/auth/forgot_password_view.dart';
import '../modules/auth/login_view.dart';
import '../modules/auth/password_controller.dart';
import '../modules/auth/register_view.dart';
import '../core/localization/translation_keys.dart';
import '../modules/home/home_controller.dart';
import '../modules/home/home_view.dart';
import '../modules/placeholder/placeholder_view.dart';
import '../modules/profile_setup/profile_setup_controller.dart';
import '../modules/profile_setup/profile_setup_view.dart';
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

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
  }
}

class ProfileSetupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileSetupController>(() => ProfileSetupController());
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
      page: () => const ProfileSetupView(),
      binding: ProfileSetupBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),

    // Still to be built. They are registered rather than omitted so every
    // drawer entry leads somewhere and the flow can be walked now.
    ..._comingNext,
  ];

  static final _comingNext = <GetPage>[
    for (final (route, titleKey) in <(String, String)>[
      (AppRoutes.discover, TrKeys.navDiscover),
      (AppRoutes.matches, TrKeys.navMatches),
      (AppRoutes.messages, TrKeys.navMessages),
      (AppRoutes.profile, TrKeys.navProfile),
      (AppRoutes.plans, TrKeys.navPlans),
      (AppRoutes.settings, TrKeys.navSettings),
      (AppRoutes.terms, TrKeys.navTerms),
      (AppRoutes.admin, TrKeys.navAdmin),
    ])
      GetPage(
        name: route,
        page: () => PlaceholderView(
          title: titleKey.tr,
          note: TrKeys.homeComingSoonBody.tr,
          drawerRoute: route,
        ),
      ),
  ];
}
