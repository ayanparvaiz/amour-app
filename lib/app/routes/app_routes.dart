/// Route names. Kept as plain constants so they can be referenced from services
/// without importing the page list.
abstract class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';

  /// The nine-step profile wizard shown when `gender` is still empty.
  static const profileSetup = '/profile-setup';

  static const home = '/home';

  // Reserved for the screens scheduled in the project plan.
  static const discover = '/discover';
  static const matches = '/matches';
  static const messages = '/messages';
  static const chat = '/chat';
  static const profile = '/profile';
  static const settings = '/settings';
  static const plans = '/plans';
}
