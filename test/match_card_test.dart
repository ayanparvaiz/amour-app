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

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('lays out inside a horizontal list when given a width',
      (tester) async {
    // Regression: `width` was made nullable so a grid could size the card, and
    // the home row then passed nothing. A horizontal list cannot size an
    // unbounded child, so the whole section failed to lay out and rendered
    // blank.
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

  testWidgets('lays out inside a grid without a width', (tester) async {
    await tester.pumpWidget(_wrap(
      GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 0.58,
        children: const [MatchCard(match: _profile, photoAspectRatio: 3 / 4)],
      ),
    ));

    expect(tester.takeException(), isNull);
    expect(find.text('Paris'), findsOneWidget);
  });

  testWidgets('shows the action row only when handlers are supplied',
      (tester) async {
    await tester.pumpWidget(_wrap(
      const Center(child: MatchCard(match: _profile, width: 168)),
    ));
    expect(find.byIcon(Icons.close_rounded), findsNothing);
    expect(find.byIcon(Icons.chat_bubble_outline_rounded), findsNothing);
    // The heart appears once regardless — it is also the match-percent badge.
    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);

    await tester.pumpWidget(_wrap(
      Center(
        child: MatchCard(
          match: _profile,
          width: 168,
          onLike: () {},
          onPass: () {},
          onMessage: () {},
        ),
      ),
    ));
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    expect(find.byIcon(Icons.chat_bubble_outline_rounded), findsOneWidget);
    // Badge plus the like button.
    expect(find.byIcon(Icons.favorite_rounded), findsNWidgets(2));
  });

  testWidgets('falls back to the initial when there is no photo',
      (tester) async {
    await tester.pumpWidget(_wrap(
      const Center(child: MatchCard(match: _profile, width: 168)),
    ));
    expect(find.text('C'), findsOneWidget);
  });
}
