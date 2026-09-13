/// Route names. Kept as plain constants so they can be referenced from services
/// without importing the page list.
abstract class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const changePassword = '/change-password';

  /// The nine-step profile wizard shown when `gender` is still empty.
  static const profileSetup = '/profile-setup';

  static const home = '/home';

  // Destinations reachable from the drawer. The ones still to be built show a
  // "coming next" screen rather than being hidden, so the navigation can be
  // walked end to end while the screens land one at a time.
  static const discover = '/discover';
  static const matches = '/matches';
  static const messages = '/messages';
  static const chat = '/chat';
  static const profile = '/profile';
  static const settings = '/settings';
  static const plans = '/plans';
  static const terms = '/terms';

  /// Web-only on the website; kept here because the drawer shows it to admins.
  static const admin = '/admin';
}
