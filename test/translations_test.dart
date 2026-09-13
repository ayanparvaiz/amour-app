import 'dart:io';

import 'package:amour_app/app/core/localization/app_translations.dart';
import 'package:amour_app/app/core/localization/translation_keys.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final translations = AppTranslations().keys;
  final en = translations['en_US']!;
  final fr = translations['fr_FR']!;

  test('both languages define exactly the same keys', () {
    // Catches a string added in one language and forgotten in the other, which
    // would otherwise ship as the raw key on screen.
    expect(AppTranslations.missingKeys, isEmpty,
        reason: 'Present in one language only: ${AppTranslations.missingKeys}');
  });

  test('no translation is left empty', () {
    for (final entry in [...en.entries, ...fr.entries]) {
      expect(entry.value.trim(), isNotEmpty, reason: 'Empty value for ${entry.key}');
    }
  });

  test('every key declared in TrKeys is translated', () {
    // Read the declarations rather than listing them here: a hand-kept list
    // silently stops covering whatever was added after it was written.
    final source = File('lib/app/core/localization/translation_keys.dart')
        .readAsStringSync();
    final declared = RegExp(r"static const \w+ = '([a-z0-9_]+)';")
        .allMatches(source)
        .map((m) => m.group(1)!)
        .toSet();

    expect(declared, isNotEmpty, reason: 'the regex stopped matching the file');

    final untranslated = declared.difference(en.keys.toSet());
    expect(untranslated, isEmpty, reason: 'Declared but never translated');
  });

  test('no translation is defined for a key nobody declares', () {
    final source = File('lib/app/core/localization/translation_keys.dart')
        .readAsStringSync();
    final declared = RegExp(r"static const \w+ = '([a-z0-9_]+)';")
        .allMatches(source)
        .map((m) => m.group(1)!)
        .toSet();

    expect(en.keys.toSet().difference(declared), isEmpty,
        reason: 'Translated but no longer declared — leftover after a rename');
  });

  test('placeholders survive translation', () {
    // GetX substitutes @name / @count / @code. If one language drops the token,
    // that language renders the literal placeholder instead of the value.
    const withTokens = {
      TrKeys.greeting: '@name',
      TrKeys.entSuperLikesWithQuota: '@count',
      TrKeys.unexpectedResponse: '@code',
      TrKeys.psStepOf: '@current',
      TrKeys.psYearsOld: '@count',
      TrKeys.homeMatchPercent: '@percent',
    };

    withTokens.forEach((key, token) {
      expect(en[key], contains(token), reason: 'English $key lost $token');
      expect(fr[key], contains(token), reason: 'French $key lost $token');
    });
  });

  test('French is genuinely translated, not copied English', () {
    // These read the same in both languages and should stay that way: the brand
    // name, words French borrowed unchanged, the example values, and the two
    // product names the backend itself leaves in English inside French
    // sentences ("Les Super Likes sont réservés aux membres Premium").
    const sameInBoth = {
      TrKeys.appName,
      TrKeys.email,
      TrKeys.emailHint,
      TrKeys.firstNameHint,
      TrKeys.ageHint,
      TrKeys.entSuperLikes,
      TrKeys.zCancer,
      TrKeys.navMessages,
      TrKeys.navMenu,
      TrKeys.discoverMessage,
      TrKeys.cBlond,
    };

    final copied = en.keys
        .where((k) => !sameInBoth.contains(k) && en[k] == fr[k])
        .toSet();

    expect(copied, isEmpty, reason: 'Still showing English in French: $copied');
  });
}
