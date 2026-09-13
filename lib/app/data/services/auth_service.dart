import 'package:get/get.dart';

import '../../core/constants/api_constants.dart';
import '../../core/localization/translation_keys.dart';
import '../../routes/app_routes.dart';
import '../models/user_model.dart';
import '../providers/api_client.dart';
import 'storage_service.dart';

/// Holds the signed-in member for the whole app. Injected permanently, so any
/// controller can read `AuthService.to.user` without passing it around.
class AuthService extends GetxService {
  static AuthService get to => Get.find();

  final ApiClient _api = ApiClient();

  final Rxn<UserModel> _user = Rxn<UserModel>();
  UserModel? get user => _user.value;
  bool get isLoggedIn => StorageService.to.hasToken && _user.value != null;

  Future<AuthService> init() async {
    // Any call that comes back suspended, deleted or with a dead token lands here.
    ApiClient.onUnauthenticated = _forceSignOut;

    final cached = StorageService.to.cachedUser;
    if (cached != null) _user.value = UserModel.fromJson(cached);
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
  /// photos vanish from the cache after any navigation.
  Future<UserModel?> refresh() async {
    if (!StorageService.to.hasToken) return null;
    try {
      final body = await _api.get(ApiConstants.me);
      final fresh = UserModel.fromJson(Map<String, dynamic>.from(body['user'] as Map));
      final merged = _user.value?.mergedWith(fresh) ?? fresh;
      _user.value = merged;
      await StorageService.to.saveUser(merged.toJson());
      return merged;
    } on ApiException {
      // A dead session has already been handled by ApiClient.onUnauthenticated.
      return null;
    }
  }

  /// Saves profile fields. Unlike [refresh], the response from `PATCH
  /// /users/me` carries every field, so it replaces the cached user outright
  /// rather than being merged into it.
  Future<UserModel> updateProfile(Map<String, dynamic> fields) async {
    final body = await _api.patch(ApiConstants.me, body: fields);
    final user = UserModel.fromJson(Map<String, dynamic>.from(body['user'] as Map));
    _user.value = user;
    await StorageService.to.saveUser(user.toJson());
    return user;
  }

  Future<UserModel> _persistSession(Map<String, dynamic> body) async {
    final token = (body['token'] ?? '').toString();
    if (token.isEmpty) {
      throw ApiException(TrKeys.noValidSession.tr);
    }
    await StorageService.to.saveToken(token);

    final user = UserModel.fromJson(Map<String, dynamic>.from(body['user'] as Map));
    _user.value = user;
    await StorageService.to.saveUser(user.toJson());
    return user;
  }

  Future<void> signOut() async {
    await StorageService.to.clear();
    _user.value = null;
    Get.offAllNamed(AppRoutes.login);
  }

  void _forceSignOut(String reason) {
    if (!StorageService.to.hasToken) return; // already signed out
    StorageService.to.clear();
    _user.value = null;
    Get.offAllNamed(AppRoutes.login);
    Get.snackbar(TrKeys.sessionEnded.tr, reason, snackPosition: SnackPosition.BOTTOM);
  }
}
