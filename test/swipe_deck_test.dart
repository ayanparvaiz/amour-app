import 'package:amour_app/app/core/widgets/swipe_card.dart';
import 'package:amour_app/app/core/widgets/swipe_deck.dart';
import 'package:amour_app/app/data/models/match_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _seed = [
  MatchModel(id: 'a', name: 'Camille', age: 27, location: 'Paris', matchPercent: 82),
  MatchModel(id: 'b', name: 'Léa', age: 29, location: 'Lyon', matchPercent: 71),
  MatchModel(id: 'c', name: 'Manon', age: 30, location: 'Marseille'),
  MatchModel(id: 'd', name: 'Inès', age: 26, location: 'Bordeaux'),
];

/// Hosts the deck the way Discover does, and records what leaves it.
class _Harness extends StatefulWidget {
  const _Harness({required this.swipes, this.controller});

  final List<(String, SwipeDirection)> swipes;
  final SwipeDeckController? controller;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  final List<MatchModel> _profiles = List.of(_seed);

  @override
  Widget build(BuildContext context) {
    // A plain MaterialApp: GetMaterialApp trips an ancestor lookup while the
    // test tears the tree down. Translations are loaded in _pump instead.
    return MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: SwipeDeck(
            profiles: _profiles,
            controller: widget.controller,
            onSwipe: (profile, direction) {
              widget.swipes.add((profile.id, direction));
              setState(() => _profiles.removeWhere((p) => p.id == profile.id));
            },
          ),
        ),
      ),
    );
  }
}

Future<List<(String, SwipeDirection)>> _pump(
  WidgetTester tester, {
  SwipeDeckController? controller,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  // No GetX locale here on purpose: updateLocale forces a rebuild of the whole
  // tree, which upsets the test's teardown. The stamp's wording is checked in
  // the translation tests; this file is about how the deck behaves.
  final swipes = <(String, SwipeDirection)>[];
  await tester.pumpWidget(_Harness(swipes: swipes, controller: controller));
  await tester.pump();
  return swipes;
}

void main() {
  testWidgets('deals the first profile face up', (tester) async {
    await _pump(tester);

    expect(find.text('Camille, 27'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps only a few cards built', (tester) async {
    // Four profiles, three in the stack — the rest are not photographs anyone
    // has reached yet.
    await _pump(tester);
    expect(find.byType(SwipeCard), findsNWidgets(3));
  });

  testWidgets('a short drag springs back and decides nothing', (tester) async {
    final swipes = await _pump(tester);

    await tester.drag(find.text('Camille, 27'), const Offset(40, 0));
    await tester.pumpAndSettle();

    expect(swipes, isEmpty);
    expect(find.text('Camille, 27'), findsOneWidget);
  });

  testWidgets('dragging right is a like', (tester) async {
    final swipes = await _pump(tester);

    await tester.drag(find.text('Camille, 27'), const Offset(300, 0));
    await tester.pumpAndSettle();

    expect(swipes, [('a', SwipeDirection.like)]);
    expect(find.text('Camille, 27'), findsNothing);
    expect(find.text('Léa, 29'), findsOneWidget);
  });

  testWidgets('dragging left is a pass', (tester) async {
    final swipes = await _pump(tester);

    await tester.drag(find.text('Camille, 27'), const Offset(-300, 0));
    await tester.pumpAndSettle();

    expect(swipes, [('a', SwipeDirection.pass)]);
  });

  testWidgets('the stamp appears while dragging, not before', (tester) async {
    await _pump(tester);
    expect(find.byType(SwipeStamp), findsNothing);

    final gesture =
        await tester.startGesture(tester.getCenter(find.text('Camille, 27')));
    // A finger sends a stream of moves, and the first one only crosses the
    // touch slop — the card follows from the move after it. Sending the whole
    // 80 at once would start the drag and move nothing.
    await gesture.moveBy(const Offset(20, 0));
    await gesture.moveBy(const Offset(60, 0));
    await tester.pump();

    expect(find.byType(SwipeStamp), findsOneWidget);
    final stamp = tester.widget<SwipeStamp>(find.byType(SwipeStamp));
    expect(stamp.direction, SwipeDirection.like);

    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('the buttons throw the card the same way a drag does',
      (tester) async {
    final controller = SwipeDeckController();
    final swipes = await _pump(tester, controller: controller);

    controller.like();
    await tester.pumpAndSettle();
    expect(swipes, [('a', SwipeDirection.like)]);

    controller.pass();
    await tester.pumpAndSettle();
    expect(swipes.last, ('b', SwipeDirection.pass));
  });

  testWidgets('empties one card at a time without error', (tester) async {
    final controller = SwipeDeckController();
    final swipes = await _pump(tester, controller: controller);

    for (var i = 0; i < _seed.length; i++) {
      controller.like();
      await tester.pumpAndSettle();
    }

    expect(swipes.length, _seed.length);
    expect(find.byType(SwipeCard), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
