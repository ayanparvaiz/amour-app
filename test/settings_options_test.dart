import 'package:amour_app/app/core/constants/filter_options.dart';
import 'package:amour_app/app/core/constants/settings_options.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  List<String> values(List<SettingsOption> options) =>
      options.map((o) => o.value).toList();

  group('what the editor writes', () {
    test('gender offers only what the schema accepts', () {
      // The User schema's enum is ['man', 'woman', '']. The website's form also
      // offers "Autre", which saves as `other` and is rejected by validation,
      // so choosing it makes the whole save fail.
      expect(values(SettingsOptions.gender), ['man', 'woman']);
      expect(values(SettingsOptions.gender), isNot(contains('other')));
    });

    test('looking for includes everyone, which the schema does accept', () {
      expect(values(SettingsOptions.lookingFor), ['man', 'woman', 'everyone']);
    });

    test('children uses the vocabulary the website already stores', () {
      expect(values(SettingsOptions.children),
          ['none', 'want', 'have', 'dont_want']);
    });

    test('smoking uses the vocabulary the website already stores', () {
      expect(values(SettingsOptions.smoke), ['no', 'occasionally', 'yes']);
    });

    test('drinking uses the vocabulary the website already stores', () {
      expect(values(SettingsOptions.alcohol),
          ['never', 'occasionally', 'regularly']);
    });
  });

  group('agreement with the Discover filters', () {
    // Members are matched by comparing these stored strings, so a value written
    // here has to be one the filter can search for.
    Set<String> filterValues(List<FilterOption> options) =>
        options.map((o) => o.value).whereType<String>().toSet();

    test('drinking lines up', () {
      expect(values(SettingsOptions.alcohol).toSet(),
          filterValues(FilterOptions.alcohol));
    });

    test('smoking and children do NOT line up — a known website bug', () {
      // Kept as a statement of the current state rather than a wish: the app
      // writes what the website writes, because inventing a second vocabulary
      // would split members into groups that cannot match each other. Fixing it
      // properly means migrating the stored data and changing both clients at
      // once. If that ever happens, this test should start failing.
      expect(
        values(SettingsOptions.smoke).toSet(),
        isNot(filterValues(FilterOptions.smoke)),
        reason: 'if these now agree, the mismatch was fixed — update this test',
      );
      expect(
        values(SettingsOptions.children).toSet(),
        isNot(filterValues(FilterOptions.children)),
        reason: 'if these now agree, the mismatch was fixed — update this test',
      );
    });
  });

  test('every option carries a label key', () {
    for (final options in [
      SettingsOptions.gender,
      SettingsOptions.lookingFor,
      SettingsOptions.children,
      SettingsOptions.smoke,
      SettingsOptions.alcohol,
    ]) {
      for (final option in options) {
        expect(option.labelKey, isNotEmpty);
        expect(option.value, isNotEmpty);
      }
    }
  });
}
