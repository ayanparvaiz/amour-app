import '../localization/translation_keys.dart';

typedef SettingsOption = ({String value, String labelKey});

/// The choices the profile editor writes.
///
/// ── A warning about three of these ─────────────────────────────────────────
/// The website stores some of them with one vocabulary and filters Discover
/// with a different one, so those filters match nobody:
///
///   field     stored by settings           searched for in Discover
///   smoke     no / occasionally / yes      Non-fumeur / Fumeur occasionnel /
///                                          Fumeur régulier
///   children  none / want / have /         Pas d'enfants / A des enfants /
///             dont_want                    Souhaite en avoir
///   alcohol   never / occasionally /       the same — this one works
///             regularly
///
/// The app writes what the website writes. Introducing a second dialect would
/// split members into groups that cannot match each other, which is worse than
/// the existing bug. Fixing it properly means migrating the stored values and
/// changing both clients at once — a decision for the product, not a detail to
/// settle quietly here.
abstract class SettingsOptions {
  /// The `User` schema permits only `man`, `woman` and empty. The website's
  /// form also offers "Autre", which saves as `other` and is rejected by
  /// validation — so that option is left out rather than carried over broken.
  static const List<SettingsOption> gender = [
    (value: 'man', labelKey: TrKeys.psMan),
    (value: 'woman', labelKey: TrKeys.psWoman),
  ];

  static const List<SettingsOption> lookingFor = [
    (value: 'man', labelKey: TrKeys.psMan),
    (value: 'woman', labelKey: TrKeys.psWoman),
    (value: 'everyone', labelKey: TrKeys.psEveryone),
  ];

  static const List<SettingsOption> children = [
    (value: 'none', labelKey: TrKeys.setChildrenNone),
    (value: 'want', labelKey: TrKeys.setChildrenWant),
    (value: 'have', labelKey: TrKeys.setChildrenHave),
    (value: 'dont_want', labelKey: TrKeys.setChildrenDontWant),
  ];

  static const List<SettingsOption> smoke = [
    (value: 'no', labelKey: TrKeys.setSmokeNo),
    (value: 'occasionally', labelKey: TrKeys.setSmokeSometimes),
    (value: 'yes', labelKey: TrKeys.setSmokeYes),
  ];

  /// The one lifestyle field whose stored values match what Discover searches.
  static const List<SettingsOption> alcohol = [
    (value: 'never', labelKey: TrKeys.fAlcoholNever),
    (value: 'occasionally', labelKey: TrKeys.fAlcoholOccasionally),
    (value: 'regularly', labelKey: TrKeys.fAlcoholRegularly),
  ];
}
