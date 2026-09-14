import 'package:amour_app/app/core/widgets/entrance.dart';
import 'package:amour_app/app/data/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double _opacityOf(WidgetTester tester) =>
    tester.widget<Opacity>(find.byType(Opacity)).opacity;

void main() {
  group('the entrance animation', () {
    testWidgets('starts invisible and settles fully opaque', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Entrance(child: Text('Bonjour')),
      ));

      expect(_opacityOf(tester), 0);

      await tester.pumpAndSettle();
      expect(_opacityOf(tester), 1);
      expect(find.text('Bonjour'), findsOneWidget);
    });

    testWidgets('waits out its delay before moving', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Entrance(
          delay: const Duration(milliseconds: 300),
          child: const Text('Bonjour'),
        ),
      ));

      await tester.pump(const Duration(milliseconds: 200));
      expect(_opacityOf(tester), 0, reason: 'it moved before its turn');

      await tester.pumpAndSettle();
      expect(_opacityOf(tester), 1);
    });

    testWidgets('comes to rest where it would have been anyway',
        (tester) async {
      // It lifts into place, so nothing may be left displaced afterwards.
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: Entrance(child: SizedBox(width: 50, height: 50))),
      ));
      await tester.pumpAndSettle();

      final animated = tester.getTopLeft(find.byType(SizedBox).first);

      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: SizedBox(width: 50, height: 50)),
      ));
      await tester.pump();

      expect(animated, tester.getTopLeft(find.byType(SizedBox).first));
    });

    testWidgets('is torn down mid-flight without complaint', (tester) async {
      // Leaving the screen before the stagger finishes must not leave a timer
      // firing into a dead widget.
      await tester.pumpWidget(MaterialApp(
        home: Entrance(delay: Entrance.stagger(6), child: const Text('Bonjour')),
      ));
      await tester.pump(const Duration(milliseconds: 20));

      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    test('staggers each section by one step', () {
      expect(Entrance.stagger(0), Duration.zero);
      expect(Entrance.stagger(3), Entrance.step * 3);
    });
  });

  group('profile completion', () {
    UserModel user(Map<String, dynamic> fields) =>
        UserModel.fromJson({'id': 'u1', 'name': 'Ayan', ...fields});

    test('an untouched profile is at nothing', () {
      expect(user({}).profileCompletion, 0);
      expect(user({}).profileNeedsWork, isTrue);
    });

    test('counts only answers that were actually given', () {
      // Blank strings are what the edit form sends for a question skipped, and
      // the server scores nothing for them either.
      final thin = user({'bio': '   ', 'hobbies': '', 'religion': 'Aucune'});
      final full = user({'bio': 'Salut', 'hobbies': 'Randonnée', 'religion': 'Aucune'});

      expect(thin.profileCompletion, lessThan(full.profileCompletion));
    });

    test('a finished profile stops being nagged', () {
      final complete = user({
        'photo': 'data:image/png;base64,AA',
        'bio': 'Salut',
        'location': 'Paris',
        'hobbies': 'Randonnée',
        'favoriteActivities': 'Cinéma',
        'zodiacSign': 'Cancer',
        'religion': 'Aucune',
        'children': 'Non',
        'height': '180',
        'eyeColor': 'Marron',
        'hairColor': 'Noir',
        'smoke': 'Non',
        'alcohol': 'Jamais',
      });

      expect(complete.profileCompletion, 1);
      expect(complete.profileNeedsWork, isFalse);
    });

    test('never reports more than finished', () {
      expect(user({'bio': 'Salut'}).profileCompletion, lessThanOrEqualTo(1));
    });
  });
}
