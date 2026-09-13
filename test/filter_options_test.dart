import 'package:amour_app/app/core/constants/filter_options.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Every value below is compared against a string already stored on member
  // records. They are data, not copy: changing one silently stops matching
  // everyone who saved the old spelling on the website.
  group('filter values match what the website stores', () {
    List<String?> values(List<FilterOption> options) =>
        options.map((o) => o.value).toList();

    test('smoking is stored in French', () {
      expect(values(FilterOptions.smoke),
          [null, 'Non-fumeur', 'Fumeur occasionnel', 'Fumeur régulier']);
    });

    test('drinking is stored in lowercase English, unlike the rest', () {
      // The website's inconsistency, carried deliberately.
      expect(values(FilterOptions.alcohol),
          [null, 'never', 'occasionally', 'regularly']);
    });

    test('children is stored in French, apostrophe included', () {
      expect(values(FilterOptions.children),
          [null, "Pas d'enfants", 'A des enfants', 'Souhaite en avoir']);
    });

    test('eye and hair colours are stored in French', () {
      expect(values(FilterOptions.eyeColor),
          [null, 'Bleu', 'Vert', 'Marron', 'Gris', 'Noisette']);
      expect(values(FilterOptions.hairColor),
          [null, 'Noir', 'Brun', 'Blond', 'Roux', 'Gris', 'Blanc']);
    });

    test('every list opens with a no-preference entry', () {
      for (final options in [
        FilterOptions.smoke,
        FilterOptions.alcohol,
        FilterOptions.children,
        FilterOptions.eyeColor,
        FilterOptions.hairColor,
      ]) {
        expect(options.first.value, isNull);
        // Null is dropped from the request rather than sent as an empty string,
        // which the server would treat as a filter matching nobody.
        expect(options.skip(1).every((o) => (o.value ?? '').isNotEmpty), isTrue);
      }
    });
  });

  test('search levels use the names the server expects', () {
    expect(SearchLevel.values.map((l) => l.value).toList(),
        ['worldwide', 'country', 'department', 'radius']);
  });
}
