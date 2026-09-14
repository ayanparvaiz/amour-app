import 'package:amour_app/app/core/localization/app_translations.dart';
import 'package:amour_app/app/data/models/match_model.dart';
import 'package:amour_app/app/data/models/profile_details.dart';
import 'package:amour_app/app/data/models/user_model.dart';
import 'package:amour_app/app/modules/profile/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// A member with every field filled and deliberately long French text — the
/// worst case for a narrow screen.
const _fullProfile = MatchModel(
  id: 'other-1',
  name: 'Marie-Christine Delacroix',
  age: 31,
  location: 'Saint-Rémy-de-Provence, Bouches-du-Rhône',
  gender: 'woman',
  bio: 'Architecte, amoureuse des vieux cafés, des librairies poussiéreuses '
      'et des longues balades le dimanche matin.',
  hobbies: 'photographie, voyage, cuisine, lecture',
  favoriteActivities: 'randonnée en montagne, marchés de producteurs',
  zodiacSign: 'Balance',
  religion: 'Catholique',
  children: "Pas d'enfants",
  height: '172',
  eyeColor: 'Noisette',
  hairColor: 'Brun',
  smoke: 'Non-fumeur',
  alcohol: 'occasionally',
  matchPercent: 78,
);

final _ownUser = UserModel(
  id: 'me-1',
  name: 'Ayan',
  email: 'ayan@example.com',
  age: 30,
  gender: 'man',
  lookingFor: 'woman',
  ageRange: '25–35',
  location: 'Paris',
  bio: 'Bonjour.',
  hobbies: 'cuisine',
  planName: 'Premium (1 Mois)',
);

/// Renders the profile body the way the app does — French, app translations —
/// but without any service, because [ProfileContent] takes data and callbacks
/// rather than reading a controller.
Future<void> _pump(
  WidgetTester tester,
  ProfileDetails member, {
  Size size = const Size(390, 1400),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    GetMaterialApp(
      translations: AppTranslations(),
      locale: AppTranslations.french,
      fallbackLocale: AppTranslations.french,
      home: Scaffold(
        body: SingleChildScrollView(child: ProfileContent(member: member)),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('ProfileDetails', () {
    test('marks its own profile and carries the plan', () {
      final own = ProfileDetails.own(_ownUser);
      expect(own.isOwn, isTrue);
      expect(own.planName, 'Premium (1 Mois)');
      expect(own.ageRange, '25–35');
    });

    test('never carries a plan or preferences for somebody else', () {
      // Nobody is shown another member's subscription or what they are after.
      final other = ProfileDetails.other(_fullProfile);
      expect(other.isOwn, isFalse);
      expect(other.planName, isNull);
      expect(other.lookingFor, isNull);
      expect(other.ageRange, isNull);
    });

    test('gallery puts the main photo first and drops duplicates', () {
      const member = MatchModel(
        id: 'x',
        name: 'Léa',
        photo: 'data:a',
        photos: ['data:b', 'data:a', 'data:c'],
      );
      expect(ProfileDetails.other(member).gallery, ['data:a', 'data:b', 'data:c']);
    });

    test('gallery is empty when there are no photos', () {
      const member = MatchModel(id: 'x', name: 'Léa');
      expect(ProfileDetails.other(member).gallery, isEmpty);
    });

    test('falls back to a question mark when the name is blank', () {
      const member = MatchModel(id: 'x', name: '   ');
      expect(ProfileDetails.other(member).initial, '?');
    });
  });

  group('layout', () {
    // French runs longer than English, so the shipped language is what the
    // layout has to survive.
    for (final width in [320.0, 360.0, 390.0, 430.0]) {
      testWidgets('someone else fits at ${width.toInt()}px', (tester) async {
        await _pump(tester, ProfileDetails.other(_fullProfile),
            size: Size(width, 1400));
        expect(tester.takeException(), isNull,
            reason: 'overflowed at ${width.toInt()}px');
      });

      testWidgets('own profile fits at ${width.toInt()}px', (tester) async {
        await _pump(tester, ProfileDetails.own(_ownUser), size: Size(width, 1400));
        expect(tester.takeException(), isNull,
            reason: 'overflowed at ${width.toInt()}px');
      });
    }
  });

  group('somebody else', () {
    testWidgets('shows the details they filled in', (tester) async {
      await _pump(tester, ProfileDetails.other(_fullProfile));

      expect(find.textContaining('Marie-Christine'), findsWidgets);
      expect(find.textContaining('Architecte'), findsOneWidget);
      expect(find.text('Balance'), findsOneWidget);
      expect(find.text('Noisette'), findsOneWidget);
      expect(find.text('172 cm'), findsOneWidget);
    });

    testWidgets('offers like, message, block and report', (tester) async {
      await _pump(tester, ProfileDetails.other(_fullProfile));

      expect(find.text("J'aime"), findsOneWidget);
      expect(find.text('Message'), findsOneWidget);
      expect(find.text('Bloquer'), findsOneWidget);
      expect(find.text('Signaler'), findsOneWidget);
    });

    testWidgets('keeps subscription and preferences private', (tester) async {
      await _pump(tester, ProfileDetails.other(_fullProfile));

      expect(find.text('ABONNEMENT'), findsNothing);
      expect(find.text('Mes préférences'), findsNothing);
      expect(find.text('Modifier'), findsNothing);
    });

    testWidgets('hides rows they left empty', (tester) async {
      await _pump(
        tester,
        ProfileDetails.other(
          const MatchModel(id: 'sparse', name: 'Léa', age: 29, gender: 'woman'),
        ),
      );

      expect(tester.takeException(), isNull);
      // An empty row invites you to fill it in on your own profile; on someone
      // else's it is only noise.
      expect(find.text('Ajouter'), findsNothing);
      expect(find.text('ZODIAQUE'), findsNothing);
    });
  });

  group('own profile', () {
    testWidgets('shows the plan, preferences and edit actions', (tester) async {
      await _pump(tester, ProfileDetails.own(_ownUser));

      expect(find.text('ABONNEMENT'), findsOneWidget);
      expect(find.text('Premium (1 Mois)'), findsOneWidget);
      expect(find.text('Mes préférences'), findsOneWidget);
      expect(find.text('Modifier'), findsOneWidget);
      // Settings is a drawer destination of its own; the profile does not
      // repeat it as a second button that goes to the same place.
      expect(find.text('Paramètres'), findsNothing);
    });

    testWidgets('offers no like, block or report on yourself', (tester) async {
      await _pump(tester, ProfileDetails.own(_ownUser));

      expect(find.text("J'aime"), findsNothing);
      expect(find.text('Bloquer'), findsNothing);
      expect(find.text('Signaler'), findsNothing);
    });

    testWidgets('invites you to fill in what is missing', (tester) async {
      await _pump(tester, ProfileDetails.own(_ownUser));

      // Empty detail rows stay visible and read "Ajouter" so they can be tapped
      // through to settings.
      expect(find.text('Ajouter'), findsWidgets);
      expect(find.text('ZODIAQUE'), findsOneWidget);
    });
  });
}
