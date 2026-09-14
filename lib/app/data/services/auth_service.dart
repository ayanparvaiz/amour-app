import 'package:get/get.dart';

import '../../core/constants/api_constants.dart';
import '../../core/dev_flags.dart';
import '../../core/localization/translation_keys.dart';
import '../../routes/app_routes.dart';
import '../models/plan_model.dart';
import '../models/user_model.dart';
import '../providers/api_client.dart';
import 'socket_service.dart';
import 'storage_service.dart';

/// Holds the signed-in member for the whole app. Injected permanently, so any
/// controller can read `AuthService.to.user` without passing it around.
class AuthService extends GetxService {
  static AuthService get to => Get.find();

  final ApiClient _api = ApiClient();

  final Rxn<UserModel> _user = Rxn<UserModel>();
  UserModel? get user => _user.value;

  /// The session to follow, rather than to sample once.
  ///
  /// A screen showing the member's own data — the profile — would otherwise
  /// hold whatever it loaded with and go stale the moment the edit screen
  /// saves, which is exactly when it must not.
  Rxn<UserModel> get userRx => _user;
  bool get isLoggedIn => StorageService.to.hasToken && _user.value != null;

  Future<AuthService> init() async {
    // Any call that comes back suspended, deleted or with a dead token lands here.
    ApiClient.onUnauthenticated = _forceSignOut;

    final cached = StorageService.to.cachedUser;
    if (cached != null) {
      _user.value = _withDevOverrides(UserModel.fromJson(cached));
      _openSocket();
    }
    return this;
  }

  Future<UserModel> login({required String email, required String password}) async {
    final body = await _api.post(
      ApiConstants.login,
      body: {'email': email.trim(), 'password': password},
      withAuth: false,
    );
    return _persistSession(body);
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required int age,
  }) async {
    final body = await _api.post(
      ApiConstants.register,
      body: {
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
        'age': age,
      },
      withAuth: false,
    );
    return _persistSession(body);
  }

  Future<void> forgotPassword(String email) => _api.post(
        ApiConstants.forgotPassword,
        body: {'email': email.trim()},
        withAuth: false,
      );

  /// Re-reads the profile from the server.
  ///
  /// `GET /users/me` deliberately returns fewer fields than a profile save does,
  /// so the result is merged into what we already hold instead of replacing it.
  /// Overwriting is the bug the web client still has, where a member's bio and
  /// photos vanish from the cache after any navigation. What it never sends at
  /// all is filled in by [_withProfileDetail].
  Future<UserModel?> refresh() async {
    if (!StorageService.to.hasToken) return null;
    try {
      final body = await _api.get(ApiConstants.me);
      final fresh = UserModel.fromJson(Map<String, dynamic>.from(body['user'] as Map));
      final merged =
          await _withProfileDetail(_user.value?.mergedWith(fresh) ?? fresh);
      // Cache the real tier; only what the UI reads is overridden.
      await StorageService.to.saveUser(merged.toJson());
      _user.value = _withDevOverrides(merged);
      return _user.value;
    } on ApiException {
      // A dead session has already been handled by ApiClient.onUnauthenticated.
      return null;
    }
  }

  /// Fills in everything the session endpoints leave out.
  ///
  /// Neither `GET /users/me` nor the sign-in response carries hobbies,
  /// activities, star sign, religion, children, height, weight, eye or hair
  /// colour, smoking, drinking or the photo gallery. `GET /users/:id` carries
  /// all of it, and reading one's own costs nothing — the server records a
  /// visit only when the viewer is somebody else.
  ///
  /// Without this the detail reached the app only as the reply to a profile
  /// save, so it survived exactly until the next sign-in: the profile screen
  /// then offered to "add" answers the member had already given, and the edit
  /// form — which fills itself from the same session — would have saved those
  /// blanks back over them.
  Future<UserModel> _withProfileDetail(UserModel session) async {
    if (session.id.isEmpty) return session;
    try {
      final body = await _api.get(ApiConstants.publicProfile(session.id));
      final detail =
          UserModel.fromJson(Map<String, dynamic>.from(body['user'] as Map));
      // Detail underneath, session on top: the session is the authority on the
      // plan, the role and the preferences, and carries nothing else.
      return detail.mergedWith(session);
    } catch (_) {
      // Caught wide on purpose: this runs inside sign-in, and the detail is an
      // enrichment. Neither a failed call nor a reply in an unexpected shape is
      // worth refusing somebody entry to the app.
      return session;
    }
  }

  /// Saves profile fields. Unlike [refresh], the response from `PATCH
  /// /users/me` carries every field, so it replaces the cached user outright
  /// rather than being merged into it.
  Future<UserModel> updateProfile(Map<String, dynamic> fields) async {
    final body = await _api.patch(ApiConstants.me, body: fields);
    final user = UserModel.fromJson(Map<String, dynamic>.from(body['user'] as Map));
    await StorageService.to.saveUser(user.toJson());
    _user.value = _withDevOverrides(user);
    return _user.value!;
  }

  Future<UserModel> _persistSession(Map<String, dynamic> body) async {
    final token = (body['token'] ?? '').toString();
    if (token.isEmpty) {
      throw ApiException(TrKeys.noValidSession.tr);
    }
    await StorageService.to.saveToken(token);

    // The sign-in reply is as narrow as `GET /users/me`, so the profile detail
    // is fetched before anything can read the session — the edit form fills
    // itself from it, and would save its blanks over the real answers.
    final user = await _withProfileDetail(
      UserModel.fromJson(Map<String, dynamic>.from(body['user'] as Map)),
    );
    await StorageService.to.saveUser(user.toJson());
    _user.value = _withDevOverrides(user);
    _openSocket();
    return _user.value!;
  }

  /// The socket follows the session: it needs the member's id to register, so
  /// it cannot open before sign-in and must close on the way out.
  ///
  /// The id is handed over rather than looked up. This runs from inside
  /// `init()`, and GetX only registers a service once its `init()` has
  /// returned — so anything reaching back for AuthService here would not find
  /// it, and the app would die on launch.
  void _openSocket() {
    final id = _user.value?.id;
    if (id == null || id.isEmpty) return;
    if (Get.isRegistered<SocketService>()) SocketService.to.connect(id);
  }

  void _closeSocket() {
    if (Get.isRegistered<SocketService>()) SocketService.to.disconnect();
  }

  /// Applies the development tier override, if it is switched on and this is a
  /// debug build. The stored copy keeps the real tier — only what the screens
  /// read is lifted, and the server is unaffected either way.
  UserModel _withDevOverrides(UserModel user) =>
      DevFlags.previewAsPrestige ? user.withTier(PlanTier.prestige) : user;

  Future<void> signOut() async {
    _closeSocket();
    await StorageService.to.clear();
    _user.value = null;
    Get.offAllNamed(AppRoutes.login);
  }

  void _forceSignOut(String reason) {
    if (!StorageService.to.hasToken) return; // already signed out
    _closeSocket();
    StorageService.to.clear();
    _user.value = null;
    Get.offAllNamed(AppRoutes.login);
    Get.snackbar(TrKeys.sessionEnded.tr, reason, snackPosition: SnackPosition.BOTTOM);
  }
}
