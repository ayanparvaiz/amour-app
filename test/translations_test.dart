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
    // TrKeys is the list of what the app asks for; the maps are what it gets.
    const declared = <String>{
      TrKeys.appName, TrKeys.back, TrKeys.error, TrKeys.update,
      TrKeys.showPassword, TrKeys.hidePassword,
      TrKeys.showPasswords, TrKeys.hidePasswords,
      TrKeys.loginTitle, TrKeys.loginSubtitle, TrKeys.email, TrKeys.emailHint,
      TrKeys.password, TrKeys.forgotPasswordLink, TrKeys.signIn,
      TrKeys.noAccountYet, TrKeys.signUp,
      TrKeys.registerTitle, TrKeys.registerHeadline, TrKeys.firstName,
      TrKeys.firstNameHint, TrKeys.age, TrKeys.ageHint, TrKeys.createAccount,
      TrKeys.minimumAgeNotice, TrKeys.alreadyHaveAccount, TrKeys.accountCreated,
      TrKeys.welcomeAboard,
      TrKeys.forgotPasswordTitle, TrKeys.forgotPasswordHeadline,
      TrKeys.forgotPasswordBlurb, TrKeys.sendLink, TrKeys.resetLinkOpensBrowser,
      TrKeys.emailSent, TrKeys.resetLinkSent, TrKeys.enterEmailFirst,
      TrKeys.changePasswordTitle, TrKeys.currentPassword, TrKeys.newPassword,
      TrKeys.confirmNewPassword, TrKeys.passwordChanged,
      TrKeys.passwordChangedBody,
      TrKeys.enterEmail, TrKeys.emailLooksWrong, TrKeys.enterPassword,
      TrKeys.passwordTooShort, TrKeys.enterFirstName, TrKeys.enterAge,
      TrKeys.mustBe18, TrKeys.invalidAge, TrKeys.enterCurrentPassword,
      TrKeys.enterNewPassword, TrKeys.chooseDifferentPassword,
      TrKeys.passwordsDoNotMatch,
      TrKeys.sessionEnded, TrKeys.sessionExpired, TrKeys.accountSuspended,
      TrKeys.accountDeleted, TrKeys.serverTooSlow, TrKeys.cannotReachServer,
      TrKeys.unexpectedResponse, TrKeys.somethingWentWrong, TrKeys.noValidSession,
      TrKeys.greeting, TrKeys.signOut, TrKeys.screensComingNext,
      TrKeys.entSendMessages, TrKeys.entSeeWhoLikedYou, TrKeys.entAdvancedFilters,
      TrKeys.entProfileVisitors, TrKeys.entSuperLikes,
      TrKeys.entSuperLikesWithQuota,
      TrKeys.tierFree,
      TrKeys.comingSoon, TrKeys.registerPlaceholderNote, TrKeys.yourProfile,
      TrKeys.profileSetupNote,
    };

    final untranslated = declared.where((k) => !en.containsKey(k)).toSet();
    expect(untranslated, isEmpty, reason: 'Declared but never translated');
  });

  test('placeholders survive translation', () {
    // GetX substitutes @name / @count / @code. If one language drops the token,
    // that language renders the literal placeholder instead of the value.
    const withTokens = {
      TrKeys.greeting: '@name',
      TrKeys.entSuperLikesWithQuota: '@count',
      TrKeys.unexpectedResponse: '@code',
    };

    withTokens.forEach((key, token) {
      expect(en[key], contains(token), reason: 'English $key lost $token');
      expect(fr[key], contains(token), reason: 'French $key lost $token');
    });
  });

  test('French is genuinely translated, not copied English', () {
    // A few keys are the same word in both languages and should stay that way:
    // the brand name, "Email", the example values, and "Super Likes" — which
    // the backend itself leaves in English inside French sentences
    // ("Les Super Likes sont réservés aux membres Premium et Prestige").
    const sameInBoth = {
      TrKeys.appName,
      TrKeys.email,
      TrKeys.emailHint,
      TrKeys.firstNameHint,
      TrKeys.ageHint,
      TrKeys.entSuperLikes,
    };

    final copied = en.keys
        .where((k) => !sameInBoth.contains(k) && en[k] == fr[k])
        .toSet();

    expect(copied, isEmpty, reason: 'Still showing English in French: $copied');
  });
}
