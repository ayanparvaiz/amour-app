import 'package:amour_app/app/modules/profile/profile_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('whose profile is this', () {
    // Regression: the id was read in the constructor, which runs while the
    // route's binding is resolved — before GetX attaches the arguments. It saw
    // null, null means "mine", and so every member's profile opened as your
    // own. It is resolved in onInit now.

    test('no id at all means your own', () {
      final controller = ProfileController();
      controller.resolveMemberId();
      expect(controller.isOwn, isTrue);
      expect(controller.memberId, isNull);
    });

    test('an empty id means your own', () {
      final controller = ProfileController(memberId: '');
      controller.resolveMemberId();
      expect(controller.isOwn, isTrue);
    });

    test('someone else\'s id is not your own', () {
      final controller = ProfileController(memberId: 'other-member');
      controller.resolveMemberId();
      expect(controller.isOwn, isFalse);
      expect(controller.memberId, 'other-member');
    });

    test('the id is read after construction, not during it', () {
      // Nothing is read while the object is merely constructed.
      final controller = ProfileController(memberId: 'other-member');
      expect(controller.memberId, isNull);

      controller.resolveMemberId();
      expect(controller.memberId, 'other-member');
    });
  });
}
