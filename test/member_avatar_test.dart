import 'package:amour_app/app/core/widgets/member_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A 1×1 red PNG — enough for the widget to take the photo path.
const _photo = 'data:image/png;base64,'
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmM'
    'IQAAAABJRU5ErkJggg==';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(MaterialApp(home: Center(child: child)));
  await tester.pump();
}

void main() {
  group('the circular avatar', () {
    // Regression: the circle was left to the container's own `clipBehavior`,
    // which takes its shape from the decoration. On device the photo came out
    // with square corners in the drawer. ClipOval says what is meant.
    testWidgets('clips the photo to an oval', (tester) async {
      await _pump(
        tester,
        const MemberAvatar(initial: 'A', photo: _photo, size: 60),
      );

      expect(
        find.ancestor(
          of: find.byType(Image),
          matching: find.byType(ClipOval),
        ),
        findsOneWidget,
      );
    });

    testWidgets('clips the fallback initial to an oval too', (tester) async {
      // A member with no photo gets their letter on the brand gradient, and
      // that has to be round as well.
      await _pump(tester, const MemberAvatar(initial: 'A', size: 60));

      expect(find.text('A'), findsOneWidget);
      expect(
        find.ancestor(of: find.text('A'), matching: find.byType(ClipOval)),
        findsOneWidget,
      );
    });

    testWidgets('keeps the size it was given, border and all', (tester) async {
      await _pump(
        tester,
        const MemberAvatar(
            initial: 'A', photo: _photo, size: 60, borderColor: Colors.white),
      );

      expect(tester.getSize(find.byType(MemberAvatar)), const Size(60, 60));
    });
  });

  group('the fill variant', () {
    testWidgets('is not made round — it fills the card it is given',
        (tester) async {
      await _pump(
        tester,
        const SizedBox(
          width: 120,
          height: 200,
          child: MemberAvatar.fill(initial: 'A', photo: _photo),
        ),
      );

      expect(find.byType(ClipOval), findsNothing);
      expect(tester.getSize(find.byType(MemberAvatar)), const Size(120, 200));
    });

    testWidgets('rounds its corners when asked', (tester) async {
      await _pump(
        tester,
        const SizedBox(
          width: 120,
          height: 200,
          child: MemberAvatar.fill(initial: 'A', photo: _photo, fillRadius: 12),
        ),
      );

      expect(find.byType(ClipRRect), findsWidgets);
    });
  });

  testWidgets('falls back to the initial when the photo is malformed',
      (tester) async {
    // Photos arrive as base64 inside the user document, so a truncated one is
    // a real possibility. It must not take the screen down with it.
    await _pump(
      tester,
      const MemberAvatar(initial: 'Z', photo: 'data:image/png;base64,@@@@'),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Z'), findsOneWidget);
  });
}
