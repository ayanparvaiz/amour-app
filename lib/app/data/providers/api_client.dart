import 'dart:async';
import 'dart:convert';

// GetX is imported for `.tr`; http.Response stays prefixed so the two
// `Response` types never collide.
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../../core/localization/translation_keys.dart';
import '../services/storage_service.dart';

/// Thrown for any non-successful response. [code] carries the backend's own
/// error code when it sent one (`ACCOUNT_SUSPENDED`, `ACCOUNT_DELETED`).
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.code});

  final String message;
  final int? statusCode;
  final String? code;

  @override
  String toString() => message;
}

/// Single place every network call goes through — the Flutter equivalent of
/// `apiFetch` in the web client's `src/lib/api.ts`, and it must keep the same
/// contract with the backend:
///
///   * a 401 carrying one of [ApiErrorCodes.expiredSessionMessages] means the
///     seven-day JWT has run out,
///   * `code: ACCOUNT_SUSPENDED` / `ACCOUNT_DELETED` means the account is gone.
///
/// All three force the user back to sign-in. [onUnauthenticated] is wired up by
/// AuthService rather than imported here, to keep this file free of navigation.
class ApiClient {
  ApiClient({http.Client? client}) : _http = client ?? http.Client();

  final http.Client _http;

  /// Called when the session is no longer valid. Set once, at startup.
  static void Function(String reason)? onUnauthenticated;

  static const Duration _timeout = Duration(seconds: 20);

  Map<String, String> _headers({bool withAuth = true}) {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (withAuth) {
      final token = StorageService.to.token;
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    if (query == null || query.isEmpty) return uri;
    return uri.replace(
      queryParameters: {
        ...uri.queryParameters,
        for (final e in query.entries)
          if (e.value != null && '${e.value}'.isNotEmpty) e.key: '${e.value}',
      },
    );
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
    bool withAuth = true,
  }) =>
      _send(() => _http.get(_uri(path, query), headers: _headers(withAuth: withAuth)));

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool withAuth = true,
  }) =>
      _send(() => _http.post(
            _uri(path),
            headers: _headers(withAuth: withAuth),
            body: jsonEncode(body ?? const {}),
          ));

  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
  }) =>
      _send(() => _http.patch(
            _uri(path),
            headers: _headers(),
            body: jsonEncode(body ?? const {}),
          ));

  Future<Map<String, dynamic>> delete(String path) =>
      _send(() => _http.delete(_uri(path), headers: _headers()));

  Future<Map<String, dynamic>> _send(Future<http.Response> Function() request) async {
    final http.Response response;
    try {
      response = await request().timeout(_timeout);
    } on TimeoutException {
      throw ApiException(TrKeys.serverTooSlow.tr);
    } catch (_) {
      throw ApiException(TrKeys.cannotReachServer.tr);
    }

    Map<String, dynamic> body = const {};
    if (response.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map) body = Map<String, dynamic>.from(decoded);
      } on FormatException {
        // nginx can return an HTML error page; fall through to the status check.
        throw ApiException(
          TrKeys.unexpectedResponse.trParams({'code': '${response.statusCode}'}),
          statusCode: response.statusCode,
        );
      }
    }

    final code = body['code'] as String?;
    final message = (body['message'] ?? '').toString();

    if (code == ApiErrorCodes.accountSuspended) {
      onUnauthenticated?.call(TrKeys.accountSuspended.tr);
      throw ApiException(message, statusCode: response.statusCode, code: code);
    }
    if (code == ApiErrorCodes.accountDeleted) {
      onUnauthenticated?.call(TrKeys.accountDeleted.tr);
      throw ApiException(message, statusCode: response.statusCode, code: code);
    }
    if (response.statusCode == 401 &&
        ApiErrorCodes.expiredSessionMessages.contains(message)) {
      onUnauthenticated?.call(TrKeys.sessionExpired.tr);
      throw ApiException(message, statusCode: 401);
    }

    final ok = response.statusCode >= 200 && response.statusCode < 300;
    if (!ok || body['success'] == false) {
      throw ApiException(
        message.isNotEmpty ? message : TrKeys.somethingWentWrong.tr,
        statusCode: response.statusCode,
        code: code,
      );
    }

    return body;
  }

  void dispose() => _http.close();
}
