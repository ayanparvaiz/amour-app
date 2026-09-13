import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/storage_service.dart';
import '../../routes/app_routes.dart';

/// Decides where the member lands. Runs once, before any other screen.
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _decide());
  }

  Future<void> _decide() async {
    if (!StorageService.to.hasToken) {
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    // A valid token still has to be checked against the server: the account may
    // have been suspended or deleted, or the subscription may have lapsed.
    final user = await AuthService.to.refresh();
    if (!mounted) return;

    if (user == null) {
      // ApiClient has already redirected if the session was rejected.
      if (StorageService.to.hasToken) Get.offAllNamed(AppRoutes.login);
      return;
    }

    Get.offAllNamed(user.needsProfileSetup ? AppRoutes.profileSetup : AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.favorite_rounded, size: 64, color: Colors.white),
              SizedBox(height: 18),
              Text(
                'Amour Et Sincérité',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                ),
              ),
              SizedBox(height: 28),
              SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
