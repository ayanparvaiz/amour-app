import 'package:amour_app/app/core/localization/app_translations.dart';
import 'package:amour_app/app/core/widgets/swipe_card.dart';
import 'package:amour_app/app/data/models/match_model.dart';
import 'package:amour_app/app/modules/home/home_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

const _members = [
  MatchModel(id: 'a', name: 'Camille', age: 27, location: 'Paris', matchPercent: 82),
  MatchModel(id: 'b', name: 'Léa', age: 29, location: 'Lyon', matchPercent: 71),
  MatchModel(
    id: 'c',
    name: 'Marie-Christine Delacroix-Beaumont',
    age: 31,
    location: 'Saint-Rémy-de-Provence, Bouches-du-Rhône',
    bio: 'Une longue description qui ne doit jamais tenir sur une petite carte.',
    matchPercent: 65,
  ),
];

/// Pumped in French, at a phone width, the way a member will see it.
Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  double width = 390,
}) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(GetMaterialApp(
    translations: AppTranslations(),
    locale: AppTranslations.french,
    fallbackLocale: AppTranslations.french,
    home: Scaffold(
      body: ListView(padding: const EdgeInsets.all(20), children: [child]),
    ),
  ));
  await tester.pump();
}

/// The whole screen's worth of pieces, stacked as HomeView stacks them, so a
/// width that breaks one of them breaks the test.
Widget _wholeScreen() => Column(
      children: [
        HomeGreeting(
          name: 'Marie-Christine',
          location: 'Saint-Rémy-de-Provence',
          planLabel: 'Prestige 6 mois',
          onTapPlan: () {},
        ),
        const SizedBox(height: 18),
        LikesCard(
            count: 12, unlocked: true, faces: _members, onTap: () {}),
        const SizedBox(height: 16),
        DiscoverHero(onTap: () {}),
        const SizedBox(height: 24),
        MatchRow(matches: _members, onTap: (_) {}),
        const SizedBox(height: 24),
        UpgradeCard(planLabel: 'Gratuit', onTap: () {}),
      ],
    );

void main() {
  group('layout', () {
    for (final width in [320.0, 360.0, 390.0, 430.0]) {
      testWidgets('the whole screen fits at ${width.toInt()}px', (tester) async {
        await _pump(tester, _wholeScreen(), width: width);

        expect(tester.takeException(), isNull,
            reason: 'the home screen overflowed at ${width.toInt()}px');
      });
    }

    testWidgets('a long plan name shortens instead of shoving the greeting out',
        (tester) async {
      await _pump(
        tester,
        HomeGreeting(
          name: 'Marie-Christine',
          location: 'Paris',
          planLabel: 'Prestige abonnement de six mois',
          onTapPlan: () {},
        ),
        width: 320,
      );

      expect(tester.takeException(), isNull);

      // The greeting keeps most of the row whatever the plan is called.
      final row = tester.getRect(find.byType(HomeGreeting)).width;
      final greeting = tester.getRect(find.textContaining('Marie-Christine'));
      expect(greeting.width, greaterThan(row * 0.6),
          reason: 'the plan pill has squeezed the greeting');
      expect(find.text('Prestige abonnement de six mois'), findsOneWidget);
    });
  });

  group('the likes card', () {
    testWidgets('shows the faces and offers the list when it is unlocked',
        (tester) async {
      var tapped = false;
      await _pump(
        tester,
        LikesCard(
          count: 3,
          unlocked: true,
          faces: _members,
          onTap: () => tapped = true,
        ),
      );

      expect(find.text('3 personnes vous ont aimé'), findsOneWidget);
      expect(find.text('Voir qui'), findsOneWidget);
      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
      expect(find.byIcon(Icons.lock_rounded), findsNothing);

      await tester.tap(find.byType(LikesCard));
      expect(tapped, isTrue);
    });

    testWidgets('keeps the count but hides the faces when it is locked',
        (tester) async {
      // The server blanks the list for free accounts and sends only the
      // number. Showing a face here would be showing something we were not
      // given — and the whole point of the count is the paywall.
      await _pump(
        tester,
        LikesCard(count: 7, unlocked: false, onTap: () {}),
      );

      expect(find.text('7 personnes vous ont aimé'), findsOneWidget);
      expect(find.text('Voir les forfaits'), findsOneWidget);
      expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
      expect(find.byType(CircleAvatar), findsNothing);
    });

    testWidgets('says it in the singular for one person', (tester) async {
      await _pump(tester, LikesCard(count: 1, unlocked: true, onTap: () {}));

      expect(find.text('Une personne vous a aimé'), findsOneWidget);
      expect(find.textContaining('1 personnes'), findsNothing);
    });
  });

  group('the match row', () {
    testWidgets('deals the same card the deck does, only smaller',
        (tester) async {
      await _pump(tester, MatchRow(matches: _members, onTap: (_) {}));

      expect(find.byType(SwipeCard), findsWidgets);
      expect(tester.getSize(find.byType(SwipeCard).first).width,
          kHomeCardWidth);

      // Compact cards drop the description — two lines of it are unreadable
      // at a third of the width.
      expect(find.textContaining('Une longue description'), findsNothing);
      expect(find.text('Camille, 27'), findsOneWidget);
    });

    testWidgets('reports which profile was tapped', (tester) async {
      final tapped = <String>[];
      await _pump(tester, MatchRow(matches: _members, onTap: (m) => tapped.add(m.id)));

      await tester.tap(find.text('Camille, 27'));
      expect(tapped, ['a']);
    });

    testWidgets('holds the same height as its skeleton', (tester) async {
      // Otherwise the row jumps when the profiles land.
      await _pump(tester, MatchRow(matches: _members, onTap: (_) {}));
      expect(tester.getSize(find.byType(MatchRow)).height, kHomeCardHeight);
    });
  });
}
