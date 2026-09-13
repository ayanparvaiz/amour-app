import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/localization/translation_keys.dart';
import '../../core/widgets/app_logo.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/storage_service.dart';
import '../../routes/app_routes.dart';

/// Decides where the member lands. Runs once, before any other screen.
///
/// The operating system shows the native splash first (see
/// flutter_native_splash.yaml). This screen paints the same background with the
/// mark in the same place, so the handover between the two is not visible.
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  /// Without a floor the session check finishes in a frame or two and the
  /// screen is gone before anyone sees it — which reads as having no splash
  /// at all. The check runs alongside this rather than after it, so a slow
  /// network costs nothing extra.
  static const _minimumHold = Duration(milliseconds: 1100);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _decide());
  }

  Future<void> _decide() async {
    final startedSignedIn = StorageService.to.hasToken;

    final held = Future<void>.delayed(_minimumHold);
    final route = await _resolveRoute();
    await held;

    if (!mounted) return;

    // A suspended or deleted account is signed out by ApiClient, which has
    // already navigated and raised a message. Navigating again would replace
    // its route and swallow the explanation.
    if (startedSignedIn && !StorageService.to.hasToken) return;

    Get.offAllNamed(route);
  }

  Future<String> _resolveRoute() async {
    if (!StorageService.to.hasToken) return AppRoutes.login;

    // A stored token still has to be checked: the account may have been
    // suspended, or the subscription may have lapsed since last time.
    final user = await AuthService.to.refresh();
    if (user == null) return AppRoutes.login;

    return user.needsProfileSetup ? AppRoutes.profileSetup : AppRoutes.home;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      // The mark stays dead centre, where the native splash leaves it, while
      // the name and spinner sit below without pushing it off centre.
      body: Stack(
        alignment: Alignment.center,
        children: [
          const AppLogo(size: 104),
          Align(
            alignment: const Alignment(0, 0.42),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  TrKeys.appName.tr,
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 26),
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: scheme.primary,
                    strokeWidth: 2.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
