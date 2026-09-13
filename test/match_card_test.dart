import 'package:amour_app/app/core/widgets/match_card.dart';
import 'package:amour_app/app/data/models/match_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _profile = MatchModel(
  id: 'u1',
  name: 'Camille',
  age: 27,
  location: 'Paris',
  matchPercent: 82,
);

/// A long name and place, to catch text that pushes the card out of shape.
const _longProfile = MatchModel(
  id: 'u2',
  name: 'Marie-Christine Delacroix-Beaumont',
  age: 31,
  location: 'Saint-Rémy-de-Provence, Bouches-du-Rhône',
  matchPercent: 65,
);

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

/// The grid exactly as Discover builds it, so the test fails for the same
/// reason the screen would.
Widget _discoverGrid(List<MatchModel> profiles) => _wrap(
      GridView.builder(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 230,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.62,
        ),
        itemCount: profiles.length,
        itemBuilder: (_, i) => MatchCard(
          match: profiles[i],
          onLike: () {},
          onPass: () {},
          onMessage: () {},
        ),
      ),
    );

void main() {
  group('sizing', () {
    testWidgets('lays out in a horizontal row when given a width',
        (tester) async {
      // Regression: making `width` nullable so a grid could size the card left
      // the home row passing nothing, and a horizontal list cannot size an
      // unbounded child — the section rendered blank.
      await tester.pumpWidget(_wrap(
        SizedBox(
          height: 246,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [MatchCard(match: _profile, width: 168)],
          ),
        ),
      ));

      expect(tester.takeException(), isNull);
      expect(find.text('Camille, 27'), findsOneWidget);
      expect(tester.getSize(find.byType(MatchCard)).width, 168);
    });

    // Regression: the photo used a fixed aspect ratio and the grid cell had to
    // guess a height that would fit it plus the name and buttons. It guessed
    // 52 pixels short and every card overflowed. The photo now takes what is
    // left instead, so these widths all have to pass.
    for (final width in [360.0, 390.0, 393.0, 430.0]) {
      testWidgets('the Discover grid fits at ${width.toInt()}px wide',
          (tester) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(_discoverGrid(
          List.filled(4, _profile) + List.filled(2, _longProfile),
        ));
        await tester.pump();

        expect(tester.takeException(), isNull,
            reason: 'a card overflowed its grid cell at ${width.toInt()}px');
      });
    }

    testWidgets('long names and places do not break the card', (tester) async {
      await tester.pumpWidget(_wrap(
        Center(child: SizedBox(width: 168, height: 246, child: MatchCard(match: _longProfile))),
      ));

      expect(tester.takeException(), isNull);
      expect(find.textContaining('Marie-Christine'), findsOneWidget);
    });
  });

  group('contents', () {
    testWidgets('shows the action row only when handlers are supplied',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const Center(
          child: SizedBox(
              width: 168, height: 246, child: MatchCard(match: _profile)),
        ),
      ));
      expect(find.byIcon(Icons.close_rounded), findsNothing);
      expect(find.byIcon(Icons.chat_bubble_outline_rounded), findsNothing);
      // The heart appears once regardless — it is also the match-percent badge.
      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);

      await tester.pumpWidget(_wrap(
        Center(
          child: SizedBox(
            width: 168,
            height: 300,
            child: MatchCard(
              match: _profile,
              onLike: () {},
              onPass: () {},
              onMessage: () {},
            ),
          ),
        ),
      ));
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      expect(find.byIcon(Icons.chat_bubble_outline_rounded), findsOneWidget);
      expect(find.byIcon(Icons.favorite_rounded), findsNWidgets(2));
    });

    testWidgets('falls back to the initial when there is no photo',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const Center(
          child: SizedBox(
              width: 168, height: 246, child: MatchCard(match: _profile)),
        ),
      ));
      expect(find.text('C'), findsOneWidget);
    });

    testWidgets('omits the badge when the server sent no score', (tester) async {
      const unscored = MatchModel(id: 'u3', name: 'Léa', age: 29);
      await tester.pumpWidget(_wrap(
        const Center(
          child: SizedBox(
              width: 168, height: 246, child: MatchCard(match: unscored)),
        ),
      ));

      expect(tester.takeException(), isNull);
      expect(find.byIcon(Icons.favorite_rounded), findsNothing);
      expect(find.text('Léa, 29'), findsOneWidget);
    });
  });
}
