import '../localization/translation_keys.dart';

/// A filter choice: [value] is what travels to the server and is compared
/// against what members stored, [labelKey] is only what it reads as on screen.
typedef FilterOption = ({String? value, String labelKey});

/// The search and filter choices, taken from the website's Discover panel.
///
/// Every [value] here is matched against a string already saved on member
/// records, so the spellings are fixed — including the inconsistency the
/// website carries, where smoking and children are stored in French but
/// drinking is stored in lowercase English. Changing any of them would simply
/// stop matching the people who are already in the database.
abstract class FilterOptions {
  /// `null` means "no preference" and is left out of the request entirely.
  static const List<FilterOption> smoke = [
    (value: null, labelKey: TrKeys.fSmokeAny),
    (value: 'Non-fumeur', labelKey: TrKeys.fSmokeNo),
    (value: 'Fumeur occasionnel', labelKey: TrKeys.fSmokeOccasional),
    (value: 'Fumeur régulier', labelKey: TrKeys.fSmokeRegular),
  ];

  static const List<FilterOption> alcohol = [
    (value: null, labelKey: TrKeys.fAlcoholAny),
    (value: 'never', labelKey: TrKeys.fAlcoholNever),
    (value: 'occasionally', labelKey: TrKeys.fAlcoholOccasionally),
    (value: 'regularly', labelKey: TrKeys.fAlcoholRegularly),
  ];

  static const List<FilterOption> children = [
    (value: null, labelKey: TrKeys.fChildrenAny),
    (value: "Pas d'enfants", labelKey: TrKeys.fChildrenNone),
    (value: 'A des enfants', labelKey: TrKeys.fChildrenHas),
    (value: 'Souhaite en avoir', labelKey: TrKeys.fChildrenWants),
  ];

  static const List<FilterOption> eyeColor = [
    (value: null, labelKey: TrKeys.fEyesAny),
    (value: 'Bleu', labelKey: TrKeys.cBlue),
    (value: 'Vert', labelKey: TrKeys.cGreen),
    (value: 'Marron', labelKey: TrKeys.cBrown),
    (value: 'Gris', labelKey: TrKeys.cGrey),
    (value: 'Noisette', labelKey: TrKeys.cHazel),
  ];

  static const List<FilterOption> hairColor = [
    (value: null, labelKey: TrKeys.fHairAny),
    (value: 'Noir', labelKey: TrKeys.cBlack),
    (value: 'Brun', labelKey: TrKeys.cDarkBrown),
    (value: 'Blond', labelKey: TrKeys.cBlond),
    (value: 'Roux', labelKey: TrKeys.cRed),
    (value: 'Gris', labelKey: TrKeys.cGrey),
    (value: 'Blanc', labelKey: TrKeys.cWhite),
  ];
}

/// How wide to search. The server reads this as `searchLevel`, except for
/// [radius], which additionally needs the member's coordinates and a distance.
enum SearchLevel {
  worldwide('worldwide', TrKeys.fLevelWorldwide),
  country('country', TrKeys.fLevelCountry),
  department('department', TrKeys.fLevelDepartment),
  radius('radius', TrKeys.fLevelRadius);

  const SearchLevel(this.value, this.labelKey);

  final String value;
  final String labelKey;
}
