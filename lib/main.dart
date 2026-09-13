import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/core/localization/app_translations.dart';
import 'app/core/theme/app_theme.dart';
import 'app/data/services/auth_service.dart';
import 'app/data/services/storage_service.dart';
import 'app/routes/app_pages.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Language while developing
//
//  false → English, easier to read while building the screens
//  true  → French, the language the app actually ships in
//
//  Flip this and hot-restart to check that the French wording fits. French runs
//  longer than English for the same sentence, so buttons and labels that look
//  comfortable in English are the ones that overflow — check here before
//  calling a screen finished.
//
//  This only chooses the starting language. Shipping to members should follow
//  the device instead: pass `Get.deviceLocale` as the locale, with French as
//  the fallback.
// ─────────────────────────────────────────────────────────────────────────────
const bool kPreviewInFrench = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Order matters: AuthService reads the cached session out of StorageService.
  await Get.putAsync(() => StorageService().init(), permanent: true);
  await Get.putAsync(() => AuthService().init(), permanent: true);

  runApp(const AmourApp());
}

class AmourApp extends StatelessWidget {
  const AmourApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Amour Et Sincérité',
      debugShowCheckedModeBanner: false,

      translations: AppTranslations(),
      locale: kPreviewInFrench ? AppTranslations.french : AppTranslations.english,
      fallbackLocale: AppTranslations.french,

      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      defaultTransition: Transition.cupertino,
    );
  }
}
