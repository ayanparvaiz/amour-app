import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/core/dev_flags.dart';
import 'app/core/localization/app_translations.dart';
import 'app/core/theme/app_theme.dart';
import 'app/data/services/auth_service.dart';
import 'app/data/services/socket_service.dart';
import 'app/data/services/storage_service.dart';
import 'app/routes/app_pages.dart';

// Development switches (language, subscription tier) live in
// app/core/dev_flags.dart.

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Order matters: AuthService reads the cached session out of StorageService.
  await Get.putAsync(() => StorageService().init(), permanent: true);
  // Before AuthService, which opens the socket as soon as it finds a session.
  await Get.putAsync(() => SocketService().init(), permanent: true);
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
      locale: DevFlags.previewInFrench
          ? AppTranslations.french
          : AppTranslations.english,
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
