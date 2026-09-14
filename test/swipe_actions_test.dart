import 'package:amour_app/app/core/localization/app_translations.dart';
import 'package:amour_app/app/core/widgets/swipe_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// Pumped in French, the language every member actually sees.
Future<void> _pump(
  WidgetTester tester, {
  double width = 390,
  bool canSuperLike = false,
  List<String>? tapped,
}) async {
  tester.view.physicalSize = Size(width, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(GetMaterialApp(
    locale: const Locale('fr', 'FR'),
    translations: AppTranslations(),
    home: Scaffold(
      body: Align(
        alignment: Alignment.bottomCenter,
        child: SwipeActions(
          canSuperLike: canSuperLike,
          onPass: () => tapped?.add('pass'),
          onSuperLike: () => tapped?.add('super'),
          onLike: () => tapped?.add('like'),
        ),
      ),
    ),
  ));
  await tester.pump();
}

void main() {
  // Regression: the three buttons were first laid out inside a FittedBox, which
  // hands a Row unbounded width — so it shrink-wrapped and they ended up
  // touching. The gaps are explicit now, and have to survive the narrowest
  // phone the app supports.
  for (final width in [320.0, 360.0, 390.0, 430.0]) {
    testWidgets('fits and stays apart at ${width.toInt()}px', (tester) async {
      await _pump(tester, width: width);

      expect(tester.takeException(), isNull,
          reason: 'the action row overflowed at ${width.toInt()}px');

      final pass = tester.getRect(find.byIcon(Icons.close_rounded));
      final superLike = tester.getRect(find.byIcon(Icons.star_rounded));
      final like = tester.getRect(find.byIcon(Icons.favorite_rounded));

      expect(superLike.left - pass.right, greaterThan(12),
          reason: 'pass and super like are crowding each other');
      expect(like.left - superLike.right, greaterThan(12),
          reason: 'super like and like are crowding each other');

      // Centred as a group, so the row does not drift to one side.
      final row = tester.getRect(find.byType(SwipeActions));
      expect(((pass.left - row.left) - (row.right - like.right)).abs(),
          lessThan(1.0),
          reason: 'the buttons are not centred');
    });
  }

  testWidgets('like is the biggest target, super like the smallest',
      (tester) async {
    // The decision people make most often should be the easiest to hit.
    await _pump(tester);

    double diameter(IconData icon) => tester
        .getSize(find.ancestor(
            of: find.byIcon(icon), matching: find.byType(SizedBox)))
        .width;

    expect(diameter(Icons.favorite_rounded), kSwipeActionLarge);
    expect(diameter(Icons.close_rounded), kSwipeActionLarge);
    expect(diameter(Icons.star_rounded), kSwipeActionSmall);
  });

  testWidgets('each button reports its own decision', (tester) async {
    final tapped = <String>[];
    await _pump(tester, tapped: tapped, canSuperLike: true);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.tap(find.byIcon(Icons.star_rounded));
    await tester.tap(find.byIcon(Icons.favorite_rounded));

    expect(tapped, ['pass', 'super', 'like']);
  });

  testWidgets('a locked super like still answers, so it can explain itself',
      (tester) async {
    // Going dead would read as a bug. Discover says why it is locked instead.
    final tapped = <String>[];
    await _pump(tester, tapped: tapped);

    await tester.tap(find.byIcon(Icons.star_rounded));
    expect(tapped, ['super']);
  });
}
