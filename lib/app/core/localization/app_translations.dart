import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'translation_keys.dart';

/// English and French copy, side by side so a wording change can be made in
/// both at once.
///
/// French is the language the product ships in — the strings are taken from the
/// website so the two clients say the same thing. English exists to make the
/// app readable while it is being built; flip `kPreviewInFrench` in main.dart
/// to see the French laid out, which is the version that has to fit.
///
/// Use it as `TrKeys.signIn.tr`, or `TrKeys.greeting.trParams({'name': ...})`
/// where a value is substituted in.
class AppTranslations extends Translations {
  static const Locale english = Locale('en', 'US');
  static const Locale french = Locale('fr', 'FR');

  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': _en,
        'fr_FR': _fr,
      };

  static const Map<String, String> _en = {
    // Common
    TrKeys.appName: 'Amour Et Sincérité',
    TrKeys.back: 'Back',
    TrKeys.error: 'Error',
    TrKeys.update: 'Update',
    TrKeys.showPassword: 'Show password',
    TrKeys.hidePassword: 'Hide password',
    TrKeys.showPasswords: 'Show passwords',
    TrKeys.hidePasswords: 'Hide passwords',

    // Sign in
    TrKeys.loginTitle: 'Welcome back',
    TrKeys.loginSubtitle: 'Sign in to continue',
    TrKeys.email: 'Email',
    TrKeys.emailHint: 'you@example.com',
    TrKeys.password: 'Password',
    TrKeys.forgotPasswordLink: 'Forgot your password?',
    TrKeys.signIn: 'Sign in',
    TrKeys.noAccountYet: "Don't have an account?",
    TrKeys.signUp: 'Sign up',

    // Register
    TrKeys.registerTitle: 'Create an account',
    TrKeys.registerHeadline: 'Start your journey to love',
    TrKeys.firstName: 'First name',
    TrKeys.firstNameHint: 'Emma',
    TrKeys.age: 'Age',
    TrKeys.ageHint: '25',
    TrKeys.createAccount: 'Create account',
    TrKeys.minimumAgeNotice: 'You must be at least 18 to sign up.',
    TrKeys.alreadyHaveAccount: 'Already have an account?',
    TrKeys.accountCreated: 'Account created',
    TrKeys.welcomeAboard: 'Welcome aboard 🎉',

    // Forgot password
    TrKeys.forgotPasswordTitle: 'Forgot password',
    TrKeys.forgotPasswordHeadline: 'Reset your password',
    TrKeys.forgotPasswordBlurb:
        'Enter your email and we will send you a link to choose a new password.',
    TrKeys.sendLink: 'Send the link',
    TrKeys.resetLinkOpensBrowser:
        'The link opens in your browser. Once your password is changed, come '
            'back here to sign in. The link expires after one hour.',
    TrKeys.emailSent: 'Email sent',
    TrKeys.resetLinkSent: 'A reset link has been sent to your email address.',
    TrKeys.enterEmailFirst: 'Enter your email first, then try again.',

    // Change password
    TrKeys.changePasswordTitle: 'Change password',
    TrKeys.currentPassword: 'Current password',
    TrKeys.newPassword: 'New password',
    TrKeys.confirmNewPassword: 'Confirm new password',
    TrKeys.passwordChanged: 'Password changed',
    TrKeys.passwordChangedBody: 'Your password has been updated 🎉',

    // Validation
    TrKeys.enterEmail: 'Enter your email',
    TrKeys.emailLooksWrong: 'This email does not look valid',
    TrKeys.enterPassword: 'Enter your password',
    TrKeys.passwordTooShort: 'At least 6 characters',
    TrKeys.enterFirstName: 'Enter your first name',
    TrKeys.enterAge: 'Enter your age',
    TrKeys.mustBe18: 'You must be at least 18',
    TrKeys.invalidAge: 'Invalid age',
    TrKeys.enterCurrentPassword: 'Enter your current password',
    TrKeys.enterNewPassword: 'Enter the new password',
    TrKeys.chooseDifferentPassword: 'Choose a different password',
    TrKeys.passwordsDoNotMatch: 'The passwords do not match',

    // Session and network
    TrKeys.sessionEnded: 'Session ended',
    TrKeys.sessionExpired: 'Your session has expired. Please sign in again.',
    TrKeys.accountSuspended: 'Your account has been suspended by the administrator.',
    TrKeys.accountDeleted: 'Your account has been deleted.',
    TrKeys.serverTooSlow: 'The server is taking too long to respond.',
    TrKeys.cannotReachServer: 'Cannot reach the server. Check your connection.',
    TrKeys.unexpectedResponse: 'Unexpected response from the server (@code).',
    TrKeys.somethingWentWrong: 'Something went wrong.',
    TrKeys.noValidSession: 'The server did not return a valid session.',

    // Home
    TrKeys.greeting: 'Hello @name 👋',
    TrKeys.signOut: 'Sign out',
    TrKeys.screensComingNext: 'The rest of the app is coming next.',

    // Entitlements
    TrKeys.entSendMessages: 'Send messages',
    TrKeys.entSeeWhoLikedYou: 'See who liked you',
    TrKeys.entAdvancedFilters: 'Advanced filters',
    TrKeys.entProfileVisitors: 'Profile visitors',
    TrKeys.entSuperLikes: 'Super Likes',
    TrKeys.entSuperLikesWithQuota: 'Super Likes (@count/week)',

    // Plan tiers
    TrKeys.tierFree: 'Free',

    // Profile setup wizard
    TrKeys.psStepOf: 'Step @current of @total',
    TrKeys.psNext: 'Next',
    TrKeys.psFindProfiles: 'Find profiles',
    TrKeys.psSaving: 'Saving...',
    TrKeys.psSavingTitle: 'Saving...',
    TrKeys.psSavingBlurb:
        'This can take a few seconds if you added a high quality photo.',
    TrKeys.psGenderTitle: 'I am...',
    TrKeys.psAMan: 'A man',
    TrKeys.psAWoman: 'A woman',
    TrKeys.psAgeTitle: 'Your age',
    TrKeys.psAgeBlurb: 'Please confirm your age for better matches.',
    TrKeys.psAgeFieldHint: 'e.g. 25',
    TrKeys.psAgeNotice: 'You must be at least 18.',
    TrKeys.psLookingForTitle: 'Looking for a...',
    TrKeys.psMan: 'Man',
    TrKeys.psWoman: 'Woman',
    TrKeys.psEveryone: 'Both',
    TrKeys.psAgeRangeTitle: 'Preferred age range',
    TrKeys.psLocationTitle: 'Your city',
    TrKeys.psLocationHint: 'e.g. Paris, Lyon, Bordeaux...',
    TrKeys.psPhotoTitle: 'Your photo',
    TrKeys.psChoosePhoto: 'Choose a photo',
    TrKeys.psChangePhoto: 'Change photo',
    TrKeys.psRemovePhoto: 'Remove photo',
    TrKeys.psTakePhoto: 'Take a photo',
    TrKeys.psFromGallery: 'Choose from gallery',
    TrKeys.psPhotoError: 'Could not process the image.',
    TrKeys.psAboutTitle: 'About you',
    TrKeys.psBioLabel: 'Your bio',
    TrKeys.psBioHint: 'Tell us about yourself...',
    TrKeys.psHobbiesLabel: 'Hobbies',
    TrKeys.psHobbiesHint: 'Music, travel, cooking...',
    TrKeys.psDetailsTitle: 'Essential details',
    TrKeys.psZodiacLabel: 'Star sign',
    TrKeys.psSelect: 'Select',
    TrKeys.psReligionLabel: 'Religion (optional)',
    TrKeys.psHeightLabel: 'Height (cm)',
    TrKeys.psHeightHint: 'e.g. 175',
    TrKeys.psReadyTitle: "You're all set! 🎉",
    TrKeys.psReadyBlurb: 'We will find the best profiles for you.',
    TrKeys.psSummaryAge: 'Age:',
    TrKeys.psSummaryGender: 'Gender:',
    TrKeys.psSummaryLocation: 'Location:',
    TrKeys.psYearsOld: '@count years old',
    TrKeys.zAries: 'Aries',
    TrKeys.zTaurus: 'Taurus',
    TrKeys.zGemini: 'Gemini',
    TrKeys.zCancer: 'Cancer',
    TrKeys.zLeo: 'Leo',
    TrKeys.zVirgo: 'Virgo',
    TrKeys.zLibra: 'Libra',
    TrKeys.zScorpio: 'Scorpio',
    TrKeys.zSagittarius: 'Sagittarius',
    TrKeys.zCapricorn: 'Capricorn',
    TrKeys.zAquarius: 'Aquarius',
    TrKeys.zPisces: 'Pisces',

    // Navigation
    TrKeys.navDiscover: 'Discover',
    TrKeys.navMatches: 'Matches',
    TrKeys.navMessages: 'Messages',
    TrKeys.navProfile: 'Profile',
    TrKeys.navPlans: 'Plans',
    TrKeys.navSettings: 'Settings',
    TrKeys.navTerms: 'Terms',
    TrKeys.navAdmin: 'Admin dashboard',
    TrKeys.navMenu: 'Menu',

    // Home
    TrKeys.homePerfectMatches: 'Perfect matches',
    TrKeys.homeSeeAll: 'See all',
    TrKeys.homeNoMatches: 'No matches yet',
    TrKeys.homeNoMatchesHint:
        'Widen your preferences in Discover and new profiles will appear here.',
    TrKeys.homeRetry: 'Try again',
    TrKeys.homeUpgrade: 'Upgrade',
    TrKeys.homeFreeLimit:
        'Free members see five profiles. Upgrade to browse without a limit.',
    TrKeys.homeMatchPercent: '@percent% match',
    TrKeys.homeComingSoonTitle: 'Coming next',
    TrKeys.homeComingSoonBody: 'This part of the app is still being built.',
    TrKeys.signOutConfirmTitle: 'Sign out?',
    TrKeys.signOutConfirmBody: 'You will need your password to sign back in.',
    TrKeys.cancel: 'Cancel',

    // Discover
    TrKeys.discoverFilters: 'Filters',
    TrKeys.discoverCriteria: 'Search criteria',
    TrKeys.discoverApply: 'Apply filters',
    TrKeys.discoverReset: 'Reset',
    TrKeys.discoverFound: '@count profiles found',
    TrKeys.discoverLocked: 'Advanced criteria locked',
    TrKeys.discoverLockedBody:
        'Upgrade to Premium to narrow your search by height, eye colour, '
            'keyword and more.',
    TrKeys.discoverUnlock: 'Unlock with Premium',
    TrKeys.discoverLike: 'Like',
    TrKeys.discoverPass: 'Pass',
    TrKeys.discoverMessage: 'Message',
    TrKeys.discoverItsAMatch: "It's a match!",
    TrKeys.discoverLiked: 'Profile liked',
    TrKeys.discoverPassed: 'Profile skipped',

    TrKeys.fSectionLocation: 'Location',
    TrKeys.fSectionLifestyle: 'Lifestyle',
    TrKeys.fSectionAdvanced: 'Advanced criteria',
    TrKeys.fDistance: 'Distance: @km km',
    TrKeys.fAgeMin: 'Min age',
    TrKeys.fAgeMax: 'Max age',
    TrKeys.fKeyword: 'Keyword',
    TrKeys.fKeywordHint: 'e.g. sport, cooking...',
    TrKeys.fEyes: 'Eyes',
    TrKeys.fHair: 'Hair',
    TrKeys.fSmoke: 'Smoking',
    TrKeys.fAlcohol: 'Drinking',
    TrKeys.fChildren: 'Children',

    TrKeys.fLevelWorldwide: '🌍  Worldwide',
    TrKeys.fLevelCountry: '🏳️  My country',
    TrKeys.fLevelDepartment: '🏠  My region',
    TrKeys.fLevelRadius: '📍  Nearby',

    TrKeys.fSmokeAny: 'No preference',
    TrKeys.fSmokeNo: 'Non-smoker',
    TrKeys.fSmokeOccasional: 'Occasional smoker',
    TrKeys.fSmokeRegular: 'Regular smoker',
    TrKeys.fAlcoholAny: 'No preference',
    TrKeys.fAlcoholNever: 'Never',
    TrKeys.fAlcoholOccasionally: 'Occasionally',
    TrKeys.fAlcoholRegularly: 'Regularly',
    TrKeys.fChildrenAny: 'No preference',
    TrKeys.fChildrenNone: 'No children',
    TrKeys.fChildrenHas: 'Has children',
    TrKeys.fChildrenWants: 'Would like children',
    TrKeys.fEyesAny: 'Any',
    TrKeys.fHairAny: 'Any',
    TrKeys.cBlue: 'Blue',
    TrKeys.cGreen: 'Green',
    TrKeys.cBrown: 'Brown',
    TrKeys.cGrey: 'Grey',
    TrKeys.cHazel: 'Hazel',
    TrKeys.cBlack: 'Black',
    TrKeys.cDarkBrown: 'Dark brown',
    TrKeys.cBlond: 'Blond',
    TrKeys.cRed: 'Red',
    TrKeys.cWhite: 'White',

    // Profile
    TrKeys.profileNotFound: 'Member not found',
    TrKeys.profileNotFoundBody: 'The profile you are looking for does not exist.',
    TrKeys.profileBackToDiscover: 'Back to Discover',
    TrKeys.profileAboutMe: 'About me',
    TrKeys.profileAboutOther: 'About @name',
    TrKeys.profileNoBio: 'Nothing written yet.',
    TrKeys.profileQuickInfo: 'At a glance',
    TrKeys.profileMyPreferences: 'My preferences',
    TrKeys.profileDetails: 'Personal details',
    TrKeys.profileEdit: 'Edit',
    TrKeys.profileSubscription: 'Subscription',
    TrKeys.profileIAm: 'I am',
    TrKeys.profileLookingFor: 'Looking for',
    TrKeys.profileNotSet: 'Not set',
    TrKeys.profileAdd: 'Add',
    TrKeys.profileSafetyTitle: 'Stay safe',
    TrKeys.profileSafetyBody:
        'Follow our advice and put your safety first when meeting new people.',
    TrKeys.profileLike: 'Like',
    TrKeys.profileBlock: 'Block',
    TrKeys.profileReport: 'Report',
    TrKeys.profileBlockTitle: 'Block @name?',
    TrKeys.profileBlockBody:
        'You will no longer see each other anywhere in the app.',
    TrKeys.profileBlocked: 'Member blocked',
    TrKeys.profileReportTitle: 'Report @name',
    TrKeys.profileReportHint: 'What is the problem?',
    TrKeys.profileReportSend: 'Send report',
    TrKeys.profileReported: 'Report sent. Our moderators will review it.',
    TrKeys.profileHobbies: 'Hobbies',
    TrKeys.profileActivities: 'Activities',
    TrKeys.profileZodiac: 'Star sign',
    TrKeys.profileReligion: 'Religion',
    TrKeys.profileChildren: 'Children',
    TrKeys.profileHeight: 'Height',
    TrKeys.profileHeightCm: '@value cm',
    TrKeys.profileEyes: 'Eyes',
    TrKeys.profileHair: 'Hair',
    TrKeys.profileSmoke: 'Smoking',
    TrKeys.profileAlcohol: 'Drinking',
    TrKeys.profileGender: 'Gender',

    // Matches
    TrKeys.matchesTitle: 'My connections',
    TrKeys.matchesSubtitle: 'Who liked you, and the feelings that were mutual.',
    TrKeys.matchesTabMutual: 'Matches',
    TrKeys.matchesTabReceived: 'Received',
    TrKeys.matchesTabSent: 'Sent',
    TrKeys.matchesNoneTitle: 'No matches yet',
    TrKeys.matchesNoneBody:
        'Widen your preferences in Discover and new profiles will appear here.',
    TrKeys.matchesStartDiscovering: 'Start discovering',
    TrKeys.matchesNoLikesTitle: 'Nobody has liked your profile yet',
    TrKeys.matchesNoLikesBody:
        'Add a few good photos and a description to attract more likes.',
    TrKeys.matchesNoSentTitle: 'You have not liked anyone yet',
    TrKeys.matchesNoSentBody: 'Do not be shy — make the first move.',
    TrKeys.matchesLockedTitle: 'See who likes you',
    TrKeys.matchesLockedOne:
        'One person has already fallen for you. Upgrade to see their profile.',
    TrKeys.matchesLockedMany:
        '@count people have already fallen for you. Upgrade to see their profiles.',
    TrKeys.matchesSeePlans: 'See the plans',

    // Settings
    TrKeys.setTitle: 'Edit profile',
    TrKeys.setSave: 'Save',
    TrKeys.setSaving: 'Saving...',
    TrKeys.setSaved: 'Profile saved',
    TrKeys.setPhotos: 'Profile photos',
    TrKeys.setPhotosHint: 'Add several — the first one is shown everywhere.',
    TrKeys.setPhotoMain: 'Main',
    TrKeys.setPhotoMakeMain: 'Use as main photo',
    TrKeys.setAdd: 'Add',
    TrKeys.setDisplayName: 'Display name',
    TrKeys.setBio: 'Bio',
    TrKeys.setBioHint: 'Tell us about yourself and what you love...',
    TrKeys.setMyGender: 'My gender',
    TrKeys.setLookingFor: 'Looking for',
    TrKeys.setTargetAgeRange: 'Preferred age range',
    TrKeys.setSectionLocation: 'Location',
    TrKeys.setGetPosition: 'Use my current position',
    TrKeys.setUpdatePosition: 'Update my position',
    TrKeys.setCoordinates: 'Coordinates: @lat, @lng',
    TrKeys.setLocationDenied:
        'Location permission was refused. Allow it in system settings to search '
            'by distance.',
    TrKeys.setLocationOff: 'Turn on location services to use this.',
    TrKeys.setCountry: 'Country',
    TrKeys.setCountryHint: 'e.g. France, Belgium...',
    TrKeys.setRegion: 'Region',
    TrKeys.setRegionHint: 'e.g. Île-de-France, PACA...',
    TrKeys.setCity: 'City',
    TrKeys.setCityHint: 'e.g. Paris, Lyon...',
    TrKeys.setPublicAddress: 'Shown on your profile',
    TrKeys.setPublicAddressHint: 'e.g. Paris, France',
    TrKeys.setSectionInterests: 'Interests',
    TrKeys.setActivities: 'Favourite activities',
    TrKeys.setActivitiesHint: 'e.g. hiking, reading, cinema',
    TrKeys.setReligionHint: 'e.g. Christian, Muslim...',
    TrKeys.setSectionAppearance: 'Appearance',
    TrKeys.setWeight: 'Weight (kg)',
    TrKeys.setWeightHint: 'e.g. 70',
    TrKeys.setEyeColourHint: 'e.g. Brown, Blue',
    TrKeys.setHairColourHint: 'e.g. Black, Blond',
    TrKeys.setSectionLifestyle: 'Lifestyle',
    TrKeys.setSectionSecurity: 'Security',
    TrKeys.setUnsavedTitle: 'Leave without saving?',
    TrKeys.setUnsavedBody: 'Your changes will be lost.',
    TrKeys.setDiscard: 'Discard',
    TrKeys.setChildrenNone: 'None',
    TrKeys.setChildrenWant: 'Would like some',
    TrKeys.setChildrenHave: 'Already have',
    TrKeys.setChildrenDontWant: 'Do not want any',
    TrKeys.setSmokeNo: 'No',
    TrKeys.setSmokeSometimes: 'Occasionally',
    TrKeys.setSmokeYes: 'Yes',

    // Placeholders
    TrKeys.comingSoon: 'This screen will be built soon.',
    TrKeys.registerPlaceholderNote:
        'The registration form comes with the other screens.',
    TrKeys.yourProfile: 'Your profile',
    TrKeys.profileSetupNote: 'The nine profile setup steps come next.',
  };

  static const Map<String, String> _fr = {
    // Common
    TrKeys.appName: 'Amour Et Sincérité',
    TrKeys.back: 'Retour',
    TrKeys.error: 'Erreur',
    TrKeys.update: 'Mettre à jour',
    TrKeys.showPassword: 'Afficher le mot de passe',
    TrKeys.hidePassword: 'Masquer le mot de passe',
    TrKeys.showPasswords: 'Afficher les mots de passe',
    TrKeys.hidePasswords: 'Masquer les mots de passe',

    // Sign in
    TrKeys.loginTitle: 'Bon retour parmi nous',
    TrKeys.loginSubtitle: 'Connectez-vous pour continuer',
    TrKeys.email: 'Email',
    TrKeys.emailHint: 'vous@exemple.com',
    TrKeys.password: 'Mot de passe',
    TrKeys.forgotPasswordLink: 'Mot de passe oublié ?',
    TrKeys.signIn: 'Se connecter',
    TrKeys.noAccountYet: "Vous n'avez pas de compte ?",
    TrKeys.signUp: "S'inscrire",

    // Register
    TrKeys.registerTitle: 'Créer un compte',
    TrKeys.registerHeadline: "Commencez votre voyage vers l'amour",
    TrKeys.firstName: 'Prénom',
    TrKeys.firstNameHint: 'Emma',
    TrKeys.age: 'Âge',
    TrKeys.ageHint: '25',
    TrKeys.createAccount: 'Créer un compte',
    TrKeys.minimumAgeNotice:
        'Vous devez avoir au moins 18 ans pour vous inscrire.',
    TrKeys.alreadyHaveAccount: 'Vous avez déjà un compte ?',
    TrKeys.accountCreated: 'Compte créé',
    TrKeys.welcomeAboard: 'Bienvenue parmi nous 🎉',

    // Forgot password
    TrKeys.forgotPasswordTitle: 'Mot de passe oublié',
    TrKeys.forgotPasswordHeadline: 'Réinitialiser le mot de passe',
    TrKeys.forgotPasswordBlurb:
        'Entrez votre email et nous vous enverrons un lien pour choisir un '
            'nouveau mot de passe.',
    TrKeys.sendLink: 'Envoyer le lien',
    TrKeys.resetLinkOpensBrowser:
        "Le lien s'ouvrira dans votre navigateur. Une fois votre mot de passe "
            'modifié, revenez ici pour vous connecter. Le lien expire après une heure.',
    TrKeys.emailSent: 'Email envoyé',
    TrKeys.resetLinkSent:
        'Un lien de réinitialisation a été envoyé à votre adresse email.',
    TrKeys.enterEmailFirst: "Entrez d'abord votre email, puis réessayez.",

    // Change password
    TrKeys.changePasswordTitle: 'Changer le mot de passe',
    TrKeys.currentPassword: 'Mot de passe actuel',
    TrKeys.newPassword: 'Nouveau mot de passe',
    TrKeys.confirmNewPassword: 'Confirmer le nouveau mot de passe',
    TrKeys.passwordChanged: 'Mot de passe modifié',
    TrKeys.passwordChangedBody: 'Votre mot de passe a été mis à jour 🎉',

    // Validation
    TrKeys.enterEmail: 'Entrez votre email',
    TrKeys.emailLooksWrong: 'Cet email ne semble pas valide',
    TrKeys.enterPassword: 'Entrez votre mot de passe',
    TrKeys.passwordTooShort: 'Au moins 6 caractères',
    TrKeys.enterFirstName: 'Entrez votre prénom',
    TrKeys.enterAge: 'Entrez votre âge',
    TrKeys.mustBe18: 'Vous devez avoir au moins 18 ans',
    TrKeys.invalidAge: 'Âge invalide',
    TrKeys.enterCurrentPassword: 'Entrez votre mot de passe actuel',
    TrKeys.enterNewPassword: 'Entrez le nouveau mot de passe',
    TrKeys.chooseDifferentPassword: 'Choisissez un mot de passe différent',
    TrKeys.passwordsDoNotMatch: 'Les mots de passe ne correspondent pas',

    // Session and network
    TrKeys.sessionEnded: 'Session terminée',
    TrKeys.sessionExpired: 'Votre session a expiré. Veuillez vous reconnecter.',
    TrKeys.accountSuspended:
        "Votre compte a été suspendu par l'administrateur.",
    TrKeys.accountDeleted: 'Votre compte a été supprimé.',
    TrKeys.serverTooSlow: 'Le serveur met trop de temps à répondre.',
    TrKeys.cannotReachServer:
        'Impossible de contacter le serveur. Vérifiez votre connexion.',
    TrKeys.unexpectedResponse: 'Réponse inattendue du serveur (@code).',
    TrKeys.somethingWentWrong: 'Une erreur est survenue.',
    TrKeys.noValidSession: "Le serveur n'a pas renvoyé de session valide.",

    // Home
    TrKeys.greeting: 'Bonjour @name 👋',
    TrKeys.signOut: 'Se déconnecter',
    TrKeys.screensComingNext: "Les écrans de l'application arrivent ensuite.",

    // Entitlements
    TrKeys.entSendMessages: 'Envoyer des messages',
    TrKeys.entSeeWhoLikedYou: 'Voir qui vous a liké',
    TrKeys.entAdvancedFilters: 'Filtres avancés',
    TrKeys.entProfileVisitors: 'Visiteurs du profil',
    TrKeys.entSuperLikes: 'Super Likes',
    TrKeys.entSuperLikesWithQuota: 'Super Likes (@count/semaine)',

    // Plan tiers
    TrKeys.tierFree: 'Gratuit',

    // Profile setup wizard
    TrKeys.psStepOf: 'Étape @current sur @total',
    TrKeys.psNext: 'Suivant',
    TrKeys.psFindProfiles: 'Trouver des Profils',
    TrKeys.psSaving: 'Sauvegarde...',
    TrKeys.psSavingTitle: 'Sauvegarde en cours...',
    TrKeys.psSavingBlurb:
        'Ceci peut prendre quelques secondes si vous avez ajouté une photo de '
            'haute qualité.',
    TrKeys.psGenderTitle: 'Je suis...',
    TrKeys.psAMan: 'Un Homme',
    TrKeys.psAWoman: 'Une Femme',
    TrKeys.psAgeTitle: 'Votre Âge',
    TrKeys.psAgeBlurb: 'Veuillez confirmer votre âge pour de meilleurs matchs.',
    TrKeys.psAgeFieldHint: 'ex. 25',
    TrKeys.psAgeNotice: 'Vous devez avoir au moins 18 ans.',
    TrKeys.psLookingForTitle: "À la recherche d'un(e)...",
    TrKeys.psMan: 'Homme',
    TrKeys.psWoman: 'Femme',
    TrKeys.psEveryone: 'Tous les deux',
    TrKeys.psAgeRangeTitle: "Tranche d'âge préférée",
    TrKeys.psLocationTitle: 'Votre ville/lieu',
    TrKeys.psLocationHint: 'ex. Paris, Lyon, Bordeaux...',
    TrKeys.psPhotoTitle: 'Votre Photo',
    TrKeys.psChoosePhoto: 'Choisir une Photo',
    TrKeys.psChangePhoto: 'Changer la Photo',
    TrKeys.psRemovePhoto: 'Supprimer la photo',
    TrKeys.psTakePhoto: 'Prendre une photo',
    TrKeys.psFromGallery: 'Choisir dans la galerie',
    TrKeys.psPhotoError: "Erreur de traitement de l'image.",
    TrKeys.psAboutTitle: 'À propos de vous',
    TrKeys.psBioLabel: 'Votre Bio',
    TrKeys.psBioHint: 'Parlez-nous de vous...',
    TrKeys.psHobbiesLabel: 'Loisirs (Hobbies)',
    TrKeys.psHobbiesHint: 'Musique, Voyage, Cuisine...',
    TrKeys.psDetailsTitle: 'Détails essentiels',
    TrKeys.psZodiacLabel: 'Signe Astrologique',
    TrKeys.psSelect: 'Sélectionner',
    TrKeys.psReligionLabel: 'Religion (Facultatif)',
    TrKeys.psHeightLabel: 'Taille (cm)',
    TrKeys.psHeightHint: 'ex: 175',
    TrKeys.psReadyTitle: 'Vous êtes prêt ! 🎉',
    TrKeys.psReadyBlurb: 'Nous trouverons les meilleurs profils pour vous.',
    TrKeys.psSummaryAge: 'Âge :',
    TrKeys.psSummaryGender: 'Genre :',
    TrKeys.psSummaryLocation: 'Lieu :',
    TrKeys.psYearsOld: '@count ans',
    TrKeys.zAries: 'Bélier',
    TrKeys.zTaurus: 'Taureau',
    TrKeys.zGemini: 'Gémeaux',
    TrKeys.zCancer: 'Cancer',
    TrKeys.zLeo: 'Lion',
    TrKeys.zVirgo: 'Vierge',
    TrKeys.zLibra: 'Balance',
    TrKeys.zScorpio: 'Scorpion',
    TrKeys.zSagittarius: 'Sagittaire',
    TrKeys.zCapricorn: 'Capricorne',
    TrKeys.zAquarius: 'Verseau',
    TrKeys.zPisces: 'Poissons',

    // Navigation
    TrKeys.navDiscover: 'Découvrir',
    TrKeys.navMatches: 'Matchs',
    TrKeys.navMessages: 'Messages',
    TrKeys.navProfile: 'Profil',
    TrKeys.navPlans: 'Forfaits',
    TrKeys.navSettings: 'Paramètres',
    TrKeys.navTerms: 'Conditions',
    TrKeys.navAdmin: 'Tableau de bord admin',
    TrKeys.navMenu: 'Menu',

    // Home
    TrKeys.homePerfectMatches: 'Matchs Parfaits',
    TrKeys.homeSeeAll: 'Voir tout',
    TrKeys.homeNoMatches: 'Aucun match pour le moment',
    TrKeys.homeNoMatchesHint:
        'Élargissez vos critères dans Découvrir et de nouveaux profils '
            'apparaîtront ici.',
    TrKeys.homeRetry: 'Réessayer',
    TrKeys.homeUpgrade: 'Passer à un forfait',
    TrKeys.homeFreeLimit:
        'Les membres gratuits voient cinq profils. Passez à un forfait '
            'supérieur pour explorer sans limite.',
    TrKeys.homeMatchPercent: '@percent% de compatibilité',
    TrKeys.homeComingSoonTitle: 'Bientôt disponible',
    TrKeys.homeComingSoonBody: "Cette partie de l'application est en construction.",
    TrKeys.signOutConfirmTitle: 'Se déconnecter ?',
    TrKeys.signOutConfirmBody:
        'Vous aurez besoin de votre mot de passe pour vous reconnecter.',
    TrKeys.cancel: 'Annuler',

    // Discover
    TrKeys.discoverFilters: 'Filtres avancés',
    TrKeys.discoverCriteria: 'Critères de recherche',
    TrKeys.discoverApply: 'Appliquer les filtres',
    TrKeys.discoverReset: 'Réinitialiser',
    TrKeys.discoverFound: '@count profils trouvés',
    TrKeys.discoverLocked: 'Critères Avancés verrouillés',
    TrKeys.discoverLockedBody:
        'Passez à Premium pour affiner votre recherche par taille, couleur des '
            'yeux, mot-clé, etc.',
    TrKeys.discoverUnlock: 'Débloquer (Premium)',
    TrKeys.discoverLike: 'Liker',
    TrKeys.discoverPass: 'Ignorer',
    TrKeys.discoverMessage: 'Message',
    TrKeys.discoverItsAMatch: "C'est un match !",
    TrKeys.discoverLiked: 'Profil liké',
    TrKeys.discoverPassed: 'Profil ignoré',

    TrKeys.fSectionLocation: 'Localisation',
    TrKeys.fSectionLifestyle: 'Style de vie',
    TrKeys.fSectionAdvanced: 'Critères Avancés',
    TrKeys.fDistance: 'Distance : @km km',
    TrKeys.fAgeMin: 'Âge min',
    TrKeys.fAgeMax: 'Âge max',
    TrKeys.fKeyword: 'Mot-clé',
    TrKeys.fKeywordHint: 'ex : sport, cuisine...',
    TrKeys.fEyes: 'Yeux',
    TrKeys.fHair: 'Cheveux',
    TrKeys.fSmoke: 'Fumeur',
    TrKeys.fAlcohol: 'Alcool',
    TrKeys.fChildren: 'Enfants',

    TrKeys.fLevelWorldwide: '🌍  Monde entier',
    TrKeys.fLevelCountry: '🏳️  Mon pays',
    TrKeys.fLevelDepartment: '🏠  Mon département',
    TrKeys.fLevelRadius: '📍  À proximité',

    TrKeys.fSmokeAny: 'Peu importe',
    TrKeys.fSmokeNo: 'Non-fumeur',
    TrKeys.fSmokeOccasional: 'Fumeur occasionnel',
    TrKeys.fSmokeRegular: 'Fumeur régulier',
    TrKeys.fAlcoholAny: 'Peu importe',
    TrKeys.fAlcoholNever: 'Jamais',
    TrKeys.fAlcoholOccasionally: 'Occasionnellement',
    TrKeys.fAlcoholRegularly: 'Régulièrement',
    TrKeys.fChildrenAny: 'Peu importe',
    TrKeys.fChildrenNone: "Pas d'enfants",
    TrKeys.fChildrenHas: 'A des enfants',
    TrKeys.fChildrenWants: 'Souhaite en avoir',
    TrKeys.fEyesAny: 'Tous',
    TrKeys.fHairAny: 'Tous',
    TrKeys.cBlue: 'Bleu',
    TrKeys.cGreen: 'Vert',
    TrKeys.cBrown: 'Marron',
    TrKeys.cGrey: 'Gris',
    TrKeys.cHazel: 'Noisette',
    TrKeys.cBlack: 'Noir',
    TrKeys.cDarkBrown: 'Brun',
    TrKeys.cBlond: 'Blond',
    TrKeys.cRed: 'Roux',
    TrKeys.cWhite: 'Blanc',

    // Profile
    TrKeys.profileNotFound: 'Utilisateur non trouvé',
    TrKeys.profileNotFoundBody: "Le profil que vous recherchez n'existe pas.",
    TrKeys.profileBackToDiscover: 'Retour à Découvrir',
    TrKeys.profileAboutMe: 'À propos de moi',
    TrKeys.profileAboutOther: 'À propos de @name',
    TrKeys.profileNoBio: 'Rien décrit pour le moment.',
    TrKeys.profileQuickInfo: 'Infos rapides',
    TrKeys.profileMyPreferences: 'Mes préférences',
    TrKeys.profileDetails: 'Détails personnels',
    TrKeys.profileEdit: 'Modifier',
    TrKeys.profileSubscription: 'Abonnement',
    TrKeys.profileIAm: 'Je suis',
    TrKeys.profileLookingFor: 'Recherche',
    TrKeys.profileNotSet: 'Non spécifié',
    TrKeys.profileAdd: 'Ajouter',
    TrKeys.profileSafetyTitle: 'Restez en sécurité',
    TrKeys.profileSafetyBody:
        'Suivez nos conseils et donnez la priorité à votre sécurité avec de '
            'nouvelles personnes.',
    TrKeys.profileLike: "J'aime",
    TrKeys.profileBlock: 'Bloquer',
    TrKeys.profileReport: 'Signaler',
    TrKeys.profileBlockTitle: 'Bloquer @name ?',
    TrKeys.profileBlockBody:
        "Vous ne vous verrez plus nulle part dans l'application.",
    TrKeys.profileBlocked: 'Utilisateur bloqué',
    TrKeys.profileReportTitle: 'Signaler @name',
    TrKeys.profileReportHint: 'Quel est le problème ?',
    TrKeys.profileReportSend: 'Envoyer le signalement',
    TrKeys.profileReported:
        'Signalement envoyé. Les administrateurs vont examiner votre demande.',
    TrKeys.profileHobbies: 'Loisirs',
    TrKeys.profileActivities: 'Activités',
    TrKeys.profileZodiac: 'Zodiaque',
    TrKeys.profileReligion: 'Religion',
    TrKeys.profileChildren: 'Enfants',
    TrKeys.profileHeight: 'Taille',
    TrKeys.profileHeightCm: '@value cm',
    TrKeys.profileEyes: 'Yeux',
    TrKeys.profileHair: 'Cheveux',
    TrKeys.profileSmoke: 'Fumeur',
    TrKeys.profileAlcohol: 'Alcool',
    TrKeys.profileGender: 'Genre',

    // Matches
    TrKeys.matchesTitle: 'Mes connexions',
    TrKeys.matchesSubtitle:
        'Découvrez qui vous a aimé et vos coups de cœur réciproques.',
    TrKeys.matchesTabMutual: 'Matchs',
    TrKeys.matchesTabReceived: 'Reçus',
    TrKeys.matchesTabSent: 'Envoyés',
    TrKeys.matchesNoneTitle: 'Aucun match pour le moment',
    TrKeys.matchesNoneBody:
        'Élargissez vos critères dans Découvrir et de nouveaux profils '
            'apparaîtront ici.',
    TrKeys.matchesStartDiscovering: 'Commencer à découvrir',
    TrKeys.matchesNoLikesTitle: "Personne n'a encore liké votre profil",
    TrKeys.matchesNoLikesBody:
        'Ajoutez de belles photos et une description pour attirer plus de likes.',
    TrKeys.matchesNoSentTitle: "Vous n'avez encore liké personne",
    TrKeys.matchesNoSentBody: "N'hésitez pas à faire le premier pas.",
    TrKeys.matchesLockedTitle: 'Découvrez qui vous aime',
    TrKeys.matchesLockedOne:
        'Une personne a déjà craqué pour vous. Passez à un forfait supérieur '
            'pour voir son profil.',
    TrKeys.matchesLockedMany:
        '@count personnes ont déjà craqué pour vous. Passez à un forfait '
            'supérieur pour voir leurs profils.',
    TrKeys.matchesSeePlans: 'Voir les forfaits',

    // Settings
    TrKeys.setTitle: 'Modifier le profil',
    TrKeys.setSave: 'Enregistrer',
    TrKeys.setSaving: 'Sauvegarde...',
    TrKeys.setSaved: 'Profil enregistré',
    TrKeys.setPhotos: 'Photos de profil',
    TrKeys.setPhotosHint:
        'Ajoutez-en plusieurs — la première est affichée partout.',
    TrKeys.setPhotoMain: 'Principal',
    TrKeys.setPhotoMakeMain: 'Définir comme photo principale',
    TrKeys.setAdd: 'Ajouter',
    TrKeys.setDisplayName: "Nom d'affichage",
    TrKeys.setBio: 'Bio',
    TrKeys.setBioHint: 'Parlez-nous de vous, de vos passions...',
    TrKeys.setMyGender: 'Mon genre',
    TrKeys.setLookingFor: 'Je recherche',
    TrKeys.setTargetAgeRange: "Tranche d'âge cible",
    TrKeys.setSectionLocation: 'Ma localisation',
    TrKeys.setGetPosition: 'Obtenir ma position actuelle',
    TrKeys.setUpdatePosition: 'Mettre à jour ma position',
    TrKeys.setCoordinates: 'Coordonnées : @lat, @lng',
    TrKeys.setLocationDenied:
        "L'accès à la position a été refusé. Autorisez-le dans les réglages "
            'pour rechercher par distance.',
    TrKeys.setLocationOff:
        'Activez les services de localisation pour utiliser cette fonction.',
    TrKeys.setCountry: 'Pays',
    TrKeys.setCountryHint: 'ex : France, Belgique...',
    TrKeys.setRegion: 'Département / Région',
    TrKeys.setRegionHint: 'ex : Île-de-France, PACA...',
    TrKeys.setCity: 'Ville',
    TrKeys.setCityHint: 'ex : Paris, Lyon...',
    TrKeys.setPublicAddress: 'Adresse affichée (public)',
    TrKeys.setPublicAddressHint: 'ex : Paris, France',
    TrKeys.setSectionInterests: 'Centres d\'intérêt',
    TrKeys.setActivities: 'Activités préférées',
    TrKeys.setActivitiesHint: 'ex : randonnée, lecture, cinéma',
    TrKeys.setReligionHint: 'ex : Chrétien, Musulman...',
    TrKeys.setSectionAppearance: 'Apparence',
    TrKeys.setWeight: 'Poids (kg)',
    TrKeys.setWeightHint: 'ex : 70',
    TrKeys.setEyeColourHint: 'ex : Marron, Bleu',
    TrKeys.setHairColourHint: 'ex : Noir, Blond',
    TrKeys.setSectionLifestyle: 'Mode de vie',
    TrKeys.setSectionSecurity: 'Sécurité',
    TrKeys.setUnsavedTitle: 'Quitter sans enregistrer ?',
    TrKeys.setUnsavedBody: 'Vos modifications seront perdues.',
    TrKeys.setDiscard: 'Abandonner',
    TrKeys.setChildrenNone: 'Aucun',
    TrKeys.setChildrenWant: 'En veut',
    TrKeys.setChildrenHave: 'En a déjà',
    TrKeys.setChildrenDontWant: "N'en veut pas",
    TrKeys.setSmokeNo: 'Non',
    TrKeys.setSmokeSometimes: 'Occasionnellement',
    TrKeys.setSmokeYes: 'Oui',

    // Placeholders
    TrKeys.comingSoon: 'Cet écran sera construit prochainement.',
    TrKeys.registerPlaceholderNote:
        "Le formulaire d'inscription arrive avec les autres écrans.",
    TrKeys.yourProfile: 'Votre profil',
    TrKeys.profileSetupNote:
        'Les neuf étapes de configuration du profil arrivent ensuite.',
  };

  /// Every key that is missing from one of the two maps. Asserted in the tests
  /// so a string added in one language cannot quietly ship without the other.
  static Set<String> get missingKeys {
    final all = {..._en.keys, ..._fr.keys};
    return all.where((k) => !_en.containsKey(k) || !_fr.containsKey(k)).toSet();
  }
}
