import 'dart:io';

import 'package:amour_app/app/data/services/socket_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('startup order', () {
    // Regression: SocketService used to read the member's id from AuthService.
    // AuthService opens the socket from inside its own init(), and GetX only
    // registers a service once init() has returned — so the lookup failed and
    // the app died on launch with "AuthService not found". The id is passed in
    // now, and this service must not reach back for it.
    test('does not depend on AuthService', () {
      final source =
          File('lib/app/data/services/socket_service.dart').readAsStringSync();

      // Comments are allowed to name it — the file explains why it must not
      // use it. Only the code is checked.
      final code = source
          .split('\n')
          .where((line) => !line.trimLeft().startsWith('//'))
          .join('\n');

      expect(code.contains('auth_service.dart'), isFalse,
          reason: 'the socket must not import AuthService');
      expect(code.contains('AuthService'), isFalse,
          reason: 'the socket must not reach back for AuthService');
    });

    test('AuthService hands the id over rather than being asked for it', () {
      final source =
          File('lib/app/data/services/auth_service.dart').readAsStringSync();

      // Connecting without an argument is what the broken version did.
      expect(source.contains('SocketService.to.connect()'), isFalse);
      expect(source.contains('SocketService.to.connect(id)'), isTrue);
    });
  });

  group('connect', () {
    test('ignores an empty id instead of opening a nameless socket', () {
      // No id means nobody to register as, and the server keys presence by it.
      final service = SocketService();
      service.connect('');

      expect(service.connected.value, isFalse);
      expect(service.onlineUsers, isEmpty);
    });

    test('reports nobody online before anything has connected', () {
      final service = SocketService();
      expect(service.isOnline('anyone'), isFalse);
    });
  });
}
