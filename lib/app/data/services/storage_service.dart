import 'dart:convert';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Local persistence. Mirrors the web app's localStorage keys so the two
/// clients stay conceptually aligned.
///
/// Note for the store release: `get_storage` writes plain JSON to the app's
/// documents directory, which is fine for the cached profile but not for the
/// token. Before launch the token should move to the iOS Keychain and the
/// Android Keystore (`flutter_secure_storage`); only [token] needs to change.
class StorageService extends GetxService {
  static StorageService get to => Get.find();

  static const _kToken = 'token';
  static const _kUser = 'user';

  late final GetStorage _box;

  Future<StorageService> init() async {
    await GetStorage.init();
    _box = GetStorage();
    return this;
  }

  String? get token => _box.read<String>(_kToken);

  bool get hasToken => (token ?? '').isNotEmpty;

  Future<void> saveToken(String value) => _box.write(_kToken, value);

  Map<String, dynamic>? get cachedUser {
    final raw = _box.read(_kUser);
    if (raw == null) return null;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    if (raw is String && raw.isNotEmpty) {
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    }
    return null;
  }

  Future<void> saveUser(Map<String, dynamic> json) => _box.write(_kUser, json);

  Future<void> clear() async {
    await _box.remove(_kToken);
    await _box.remove(_kUser);
  }
}
