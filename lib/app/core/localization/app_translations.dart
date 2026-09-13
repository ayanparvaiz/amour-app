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
