import 'package:amour_app/app/core/localization/app_translations.dart';
import 'package:amour_app/app/data/models/match_model.dart';
import 'package:amour_app/app/modules/matches/matches_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

const _members = [
  MatchModel(
    id: 'a',
    name: 'Marie-Christine Delacroix',
    age: 31,
    location: 'Saint-Rémy-de-Provence, Bouches-du-Rhône',
    matchPercent: 78,
  ),
  MatchModel(id: 'b', name: 'Léa', age: 29, location: 'Lyon', matchPercent: 64),
  MatchModel(id: 'c', name: 'Camille', age: 27, location: 'Paris'),
];

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  Size size = const Size(390, 900),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    GetMaterialApp(
      translations: AppTranslations(),
      locale: AppTranslations.french,
      fallbackLocale: AppTranslations.french,
      home: Scaffold(body: child),
    ),
  );
  await tester.pump();
}

void main() {
  group('grid', () {
    for (final width in [320.0, 360.0, 390.0, 430.0]) {
      testWidgets('fits at ${width.toInt()}px', (tester) async {
        await _pump(
          tester,
          MatchesGrid(
            members: _members,
            buildActions: (m) => MatchCardActions(
              onLike: () {},
              onPass: () {},
              onMessage: () {},
            ),
          ),
          size: Size(width, 1000),
        );
        expect(tester.takeException(), isNull,
            reason: 'overflowed at ${width.toInt()}px');
      });
    }

    testWidgets('a matched member is offered a message, not a like',
        (tester) async {
      // There is nothing left to like or pass once it is mutual.
      await _pump(
        tester,
        MatchesGrid(
          members: _members,
          buildActions: (m) => MatchCardActions(onMessage: () {}),
        ),
      );

      expect(find.byIcon(Icons.chat_bubble_outline_rounded), findsNWidgets(3));
      expect(find.byIcon(Icons.close_rounded), findsNothing);
    });

    testWidgets('a sent like carries no actions at all', (tester) async {
      await _pump(tester, const MatchesGrid(members: _members));

      expect(find.byIcon(Icons.chat_bubble_outline_rounded), findsNothing);
      expect(find.byIcon(Icons.close_rounded), findsNothing);
      expect(find.text('Camille, 27'), findsOneWidget);
    });
  });

  group('received likes paywall', () {
    testWidgets('counts one person in the singular', (tester) async {
      await _pump(tester, const ReceivedLikesPaywall(count: 1));

      expect(find.textContaining('Une personne'), findsOneWidget);
      expect(find.text('Voir les forfaits'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('counts several in the plural', (tester) async {
      await _pump(tester, const ReceivedLikesPaywall(count: 7));

      expect(find.textContaining('7 personnes'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    for (final width in [320.0, 430.0]) {
      testWidgets('fits at ${width.toInt()}px', (tester) async {
        await _pump(tester, const ReceivedLikesPaywall(count: 12),
            size: Size(width, 700));
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('empty states', () {
    testWidgets('offers a way out when there is nothing to show',
        (tester) async {
      await _pump(
        tester,
        MatchesEmptyState(
          icon: Icons.auto_awesome_rounded,
          title: 'Aucun match pour le moment',
          body: 'Élargissez vos critères dans Découvrir.',
          actionLabel: 'Commencer à découvrir',
          onAction: () {},
        ),
      );

      expect(find.text('Aucun match pour le moment'), findsOneWidget);
      expect(find.text('Commencer à découvrir'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('fits at 320px with long French copy', (tester) async {
      await _pump(
        tester,
        MatchesEmptyState(
          icon: Icons.favorite_border_rounded,
          title: "Personne n'a encore liké votre profil",
          body: 'Ajoutez de belles photos et une description pour attirer '
              'plus de likes.',
          actionLabel: 'Commencer à découvrir',
          onAction: () {},
        ),
        size: const Size(320, 700),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
