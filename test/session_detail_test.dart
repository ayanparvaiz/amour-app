import 'package:amour_app/app/data/models/plan_model.dart';
import 'package:amour_app/app/data/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// Exactly what `GET /users/me` and the sign-in reply send: the session, the
/// plan, the preferences — and none of the profile detail.
UserModel _session() => UserModel.fromJson({
      'id': 'u1',
      'name': 'Ayan',
      'email': 'ayan@example.com',
      'role': 'admin',
      'gender': 'Man',
      'lookingFor': 'Woman',
      'ageRange': '25-35',
      'age': 30,
      'location': 'Paris',
      'photo': 'data:image/jpeg;base64,AAAA',
      'plan': {'name': 'Prestige 6 mois', 'tier': 'Prestige'},
      'subscriptionStatus': 'active',
    });

/// Exactly what `GET /users/:id` sends: all the detail, and no session at all —
/// no email, no role, no plan, no preferences.
UserModel _detail() => UserModel.fromJson({
      'id': 'u1',
      'name': 'Ayan',
      'age': 30,
      'location': 'Paris',
      'gender': 'Man',
      'photo': 'data:image/jpeg;base64,AAAA',
      'photos': ['data:image/jpeg;base64,AAAA', 'data:image/jpeg;base64,BBBB'],
      'bio': 'Passionné de randonnée.',
      'hobbies': 'Randonnée, cuisine',
      'favoriteActivities': 'Cinéma',
      'zodiacSign': 'Cancer',
      'religion': 'Aucune',
      'children': 'Non',
      'height': '180',
      'weight': '75',
      'eyeColor': 'Marron',
      'hairColor': 'Noir',
      'smoke': 'Non',
      'alcohol': 'Occasionnellement',
    });

/// What `PATCH /users/me` replies with. It echoes every editable field the app
/// sent — except the bio, which it stores and then does not mention.
UserModel _saveReply({String? bio}) => UserModel.fromJson({
      'id': 'u1',
      'name': 'Ayan',
      'email': 'ayan@example.com',
      'role': 'user',
      'gender': 'Man',
      'lookingFor': 'Woman',
      'ageRange': '25-35',
      'age': 30,
      'location': 'Paris',
      'hobbies': 'Randonnée, cuisine',
      'religion': 'Aucune',
      'plan': {'name': 'Gratuit', 'tier': 'Free'},
      'bio': ?bio,
    });

void main() {
  // The app folds what it sent over what came back, then merges the pair onto
  // the session. Without that the bio vanished the instant it was written:
  // the reply omits it, and the reply used to replace the session outright.
  group('saving a profile', () {
    /// The same fold AuthService.updateProfile performs.
    UserModel applySave(UserModel session, Map<String, dynamic> sent,
        UserModel reply) {
      final saved = UserModel.fromJson({
        ...reply.toJson(),
        if (sent.containsKey('bio')) 'bio': sent['bio'],
      });
      return session.mergedWith(saved);
    }

    test('keeps a bio the reply never echoes back', () {
      final session = _session();
      final merged = applySave(
        session,
        {'bio': 'Passionné de randonnée.'},
        _saveReply(),
      );

      expect(merged.bio, 'Passionné de randonnée.');
    });

    test('still lets a bio be cleared on purpose', () {
      // An emptied field arrives as '' rather than null, so it must win over
      // whatever the session was holding.
      final session = _detail().mergedWith(_session());
      expect(session.bio, isNotEmpty);

      final merged = applySave(session, {'bio': ''}, _saveReply());
      expect(merged.bio, '');
    });

    test('leaves the bio alone when the save was not about it', () {
      final session = _detail().mergedWith(_session());
      final merged = applySave(session, {'name': 'Ayan'}, _saveReply());

      expect(merged.bio, 'Passionné de randonnée.');
    });

    test('does not let the reply blank the detail it omits', () {
      // The reply carries no photos and no star sign here; merging must keep
      // what the session already knew rather than swapping it for nothing.
      final session = _detail().mergedWith(_session());
      final merged = applySave(session, {'bio': 'Salut'}, _saveReply());

      expect(merged.photos.length, 2);
      expect(merged.zodiacSign, 'Cancer');
      expect(merged.children, 'Non');
    });
  });

  // The two endpoints are folded as `detail.mergedWith(session)`. The order is
  // load-bearing and easy to get backwards, which is why it is pinned here:
  // the detail record reports role 'user' and tier Free simply because it is
  // not asked about them, so merging the other way would demote an admin and
  // strip a paying member's plan on every refresh.
  group('the profile detail folded into the session', () {
    test('fills in everything the session endpoints leave out', () {
      final merged = _detail().mergedWith(_session());

      expect(merged.hobbies, 'Randonnée, cuisine');
      expect(merged.favoriteActivities, 'Cinéma');
      expect(merged.zodiacSign, 'Cancer');
      expect(merged.religion, 'Aucune');
      expect(merged.children, 'Non');
      expect(merged.bio, 'Passionné de randonnée.');
      expect(merged.height, '180');
      expect(merged.eyeColor, 'Marron');
      expect(merged.smoke, 'Non');
      expect(merged.photos.length, 2);
    });

    test('never takes the plan, the role or the session from the detail', () {
      final merged = _detail().mergedWith(_session());

      expect(merged.tier, PlanTier.prestige);
      expect(merged.planName, 'Prestige 6 mois');
      expect(merged.role, 'admin');
      expect(merged.isAdmin, isTrue);
      expect(merged.email, 'ayan@example.com');
      expect(merged.subscriptionStatus, 'active');
    });

    test('keeps the preferences, which only the session carries', () {
      final merged = _detail().mergedWith(_session());

      expect(merged.lookingFor, 'Woman');
      expect(merged.ageRange, '25-35');
    });

    test('merged the other way round it would lose the plan', () {
      // Not how the app does it — recorded so the mistake is visible if the
      // order is ever flipped.
      final wrong = _session().mergedWith(_detail());

      expect(wrong.tier, PlanTier.free);
      expect(wrong.role, 'user');
    });

    test('a detail record that has nothing to add changes nothing', () {
      // A member who has filled in no detail yet: every field comes back null
      // and must not blank what the session already holds.
      final empty = UserModel.fromJson({'id': 'u1', 'name': 'Ayan'});
      final merged = empty.mergedWith(_session());

      expect(merged.name, 'Ayan');
      expect(merged.location, 'Paris');
      expect(merged.tier, PlanTier.prestige);
      expect(merged.hobbies, isNull);
    });
  });
}
