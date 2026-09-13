import 'package:amour_app/app/data/models/plan_model.dart';
import 'package:amour_app/app/data/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlanTier.parse', () {
    test('accepts both spellings of the Essential tier', () {
      // The backend's Plan enum permits both. Live data uses "Essential", but
      // `scripts/seedPlans.js` writes "Essentiel" — a tier that fails to parse
      // would silently drop a paying member to Free.
      expect(PlanTier.parse('Essential'), PlanTier.essential);
      expect(PlanTier.parse('Essentiel'), PlanTier.essential);
    });

    test('is case and whitespace tolerant', () {
      expect(PlanTier.parse(' premium '), PlanTier.premium);
      expect(PlanTier.parse('PRESTIGE'), PlanTier.prestige);
    });

    test('falls back to free for null or unknown values', () {
      expect(PlanTier.parse(null), PlanTier.free);
      expect(PlanTier.parse(''), PlanTier.free);
      expect(PlanTier.parse('Platinum'), PlanTier.free);
    });
  });

  group('UserModel entitlements', () {
    UserModel userWith({String? tier, String role = 'user'}) => UserModel.fromJson({
          'id': 'u1',
          'name': 'Test',
          'email': 'test@example.com',
          'role': role,
          'plan': tier == null ? null : {'tier': tier, 'name': tier},
        });

    test('free members cannot send messages or see who liked them', () {
      final free = userWith(tier: 'Free');
      expect(free.canSendMessages, isFalse);
      expect(free.canSeeWhoLikedYou, isFalse);
      expect(free.hasUnlimitedBrowsing, isFalse);
    });

    test('a missing plan is treated as free', () {
      expect(userWith().canSendMessages, isFalse);
    });

    test('essential can message but has no advanced filters', () {
      final essential = userWith(tier: 'Essential');
      expect(essential.canSendMessages, isTrue);
      expect(essential.canSeeWhoLikedYou, isTrue);
      expect(essential.canUseAdvancedFilters, isFalse);
      expect(essential.canSeeProfileVisitors, isFalse);
      expect(essential.canSuperLike, isFalse);
    });

    test('super like quota matches the server: 3 for premium, 6 for prestige', () {
      expect(userWith(tier: 'Premium').weeklySuperLikes, 3);
      expect(userWith(tier: 'Prestige').weeklySuperLikes, 6);
      expect(userWith(tier: 'Essential').weeklySuperLikes, 0);
    });

    test('admins bypass every gate regardless of plan', () {
      final admin = userWith(tier: 'Free', role: 'admin');
      expect(admin.canSendMessages, isTrue);
      expect(admin.canUseAdvancedFilters, isTrue);
      expect(admin.canSuperLike, isTrue);
    });
  });

  group('UserModel.mergedWith', () {
    test('keeps fields that GET /users/me does not return', () {
      // /users/me omits photos and bio. Replacing rather than merging is what
      // makes the web client lose them after a navigation.
      final stored = UserModel.fromJson({
        'id': 'u1',
        'name': 'Test',
        'email': 'test@example.com',
        'bio': 'Bonjour',
        'photos': ['a.jpg', 'b.jpg'],
        'plan': {'tier': 'Premium', 'name': 'Premium'},
      });

      final fromMe = UserModel.fromJson({
        'id': 'u1',
        'name': 'Test',
        'email': 'test@example.com',
        'plan': {'tier': 'Premium', 'name': 'Premium'},
      });

      final merged = stored.mergedWith(fromMe);
      expect(merged.bio, 'Bonjour');
      expect(merged.photos, ['a.jpg', 'b.jpg']);
    });

    test('takes the fresh tier so an expired subscription is applied', () {
      final stored = UserModel.fromJson({
        'id': 'u1',
        'name': 'T',
        'email': 't@e.com',
        'plan': {'tier': 'Prestige', 'name': 'Prestige'},
      });
      final downgraded = UserModel.fromJson({
        'id': 'u1',
        'name': 'T',
        'email': 't@e.com',
        'plan': {'tier': 'Free', 'name': 'Gratuit'},
      });

      expect(stored.mergedWith(downgraded).tier, PlanTier.free);
    });
  });
}
