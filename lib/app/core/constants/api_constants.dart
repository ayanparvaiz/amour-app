/// Endpoints for the existing Express backend.
///
/// The doubled `/api/api` is deliberate and load-bearing: production nginx maps
/// `/api/*` to the Node process, which itself mounts every router under `/api/*`.
/// Do not "fix" it — see CLAUDE.md in the parent folder.
///
/// Override at build time for a local backend:
///   flutter run --dart-define=API_BASE=http://10.0.2.2:5001/api
/// (10.0.2.2 is the host machine from the Android emulator; use localhost on iOS.)
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE',
    defaultValue: 'https://amour-et-sincerite.com/api/api',
  );

  /// Socket.IO connects to the server root, not the API path.
  static const String socketUrl = String.fromEnvironment(
    'SOCKET_URL',
    defaultValue: 'https://amour-et-sincerite.com',
  );

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/auth/change-password';

  // Users
  static const String me = '/users/me';
  static const String matches = '/users/matches';
  static const String affinities = '/users/affinities';
  static const String visitors = '/users/visitors';
  static String publicProfile(String id) => '/users/profile/$id';
  static String like(String id) => '/users/like/$id';
  static String superLike(String id) => '/users/superlike/$id';
  static String pass(String id) => '/users/pass/$id';
  static String block(String id) => '/users/block/$id';
  static const String report = '/users/report';

  // Messages
  static const String chats = '/messages/chats';
  static const String messages = '/messages';
  static String conversation(String userId) => '/messages/$userId';

  // Plans
  static const String plans = '/plans';
}

/// Error codes the backend returns that must force the user back to sign-in.
/// The web client keys off these same strings in `src/lib/api.ts`; both clients
/// must keep agreeing with the backend.
class ApiErrorCodes {
  ApiErrorCodes._();

  static const String accountSuspended = 'ACCOUNT_SUSPENDED';
  static const String accountDeleted = 'ACCOUNT_DELETED';

  static const List<String> expiredSessionMessages = [
    'Token invalid or expired.',
    'Not authorized, no token.',
  ];
}
