import 'package:amour_app/app/modules/profile_setup/profile_setup_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('wizard shape', () {
    test('has the same nine steps as the website', () {
      expect(ProfileSetupController.stepCount, 9);
    });

    test('offers the website\'s four age ranges, unchanged', () {
      // These strings are stored and compared between members, and the backend
      // parses the digits out of them. Editing one would split the audience
      // into people who can and cannot match.
      expect(ProfileSetupController.ageRanges, ['18–25', '25–35', '35–45', '45+']);
    });

    test('age ranges use the en dash the website writes', () {
      // A plain hyphen would look identical on screen and still parse, but it
      // would not equal the value already stored for existing members.
      for (final range in ProfileSetupController.ageRanges.take(3)) {
        expect(range.contains('–'), isTrue, reason: '$range is not an en dash');
      }
    });

    test('stores star signs in French whatever the interface language', () {
      final values = ProfileSetupController.zodiacSigns.map((z) => z.value).toList();
      expect(values, [
        'Bélier', 'Taureau', 'Gémeaux', 'Cancer', 'Lion', 'Vierge',
        'Balance', 'Scorpion', 'Sagittaire', 'Capricorne', 'Verseau', 'Poissons',
      ]);
    });

    test('every star sign has its own label key', () {
      final keys = ProfileSetupController.zodiacSigns.map((z) => z.labelKey).toSet();
      expect(keys.length, ProfileSetupController.zodiacSigns.length);
    });
  });
}
