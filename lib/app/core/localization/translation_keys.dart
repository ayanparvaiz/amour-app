/// Keys for every piece of text the app shows.
///
/// Symbolic keys rather than the English sentence itself: a key can be renamed
/// or reworded in one place, and a missing translation shows up as the key
/// instead of silently falling back to English.
///
/// Anything the *server* sends — validation messages, plan names, payment
/// errors — arrives already in French and is displayed as-is. Only strings the
/// app itself writes belong here.
abstract class TrKeys {
  // --- Common ------------------------------------------------------------
  static const appName = 'app_name';
  static const back = 'back';
  static const error = 'error';
  static const update = 'update';
  static const showPassword = 'show_password';
  static const hidePassword = 'hide_password';
  static const showPasswords = 'show_passwords';
  static const hidePasswords = 'hide_passwords';

  // --- Sign in -----------------------------------------------------------
  static const loginTitle = 'login_title';
  static const loginSubtitle = 'login_subtitle';
  static const email = 'email';
  static const emailHint = 'email_hint';
  static const password = 'password';
  static const forgotPasswordLink = 'forgot_password_link';
  static const signIn = 'sign_in';
  static const noAccountYet = 'no_account_yet';
  static const signUp = 'sign_up';

  // --- Register ----------------------------------------------------------
  static const registerTitle = 'register_title';
  static const registerHeadline = 'register_headline';
  static const firstName = 'first_name';
  static const firstNameHint = 'first_name_hint';
  static const age = 'age';
  static const ageHint = 'age_hint';
  static const createAccount = 'create_account';
  static const minimumAgeNotice = 'minimum_age_notice';
  static const alreadyHaveAccount = 'already_have_account';
  static const accountCreated = 'account_created';
  static const welcomeAboard = 'welcome_aboard';

  // --- Forgot password ---------------------------------------------------
  static const forgotPasswordTitle = 'forgot_password_title';
  static const forgotPasswordHeadline = 'forgot_password_headline';
  static const forgotPasswordBlurb = 'forgot_password_blurb';
  static const sendLink = 'send_link';
  static const resetLinkOpensBrowser = 'reset_link_opens_browser';
  static const emailSent = 'email_sent';
  static const resetLinkSent = 'reset_link_sent';
  static const enterEmailFirst = 'enter_email_first';

  // --- Change password ---------------------------------------------------
  static const changePasswordTitle = 'change_password_title';
  static const currentPassword = 'current_password';
  static const newPassword = 'new_password';
  static const confirmNewPassword = 'confirm_new_password';
  static const passwordChanged = 'password_changed';
  static const passwordChangedBody = 'password_changed_body';

  // --- Validation --------------------------------------------------------
  static const enterEmail = 'enter_email';
  static const emailLooksWrong = 'email_looks_wrong';
  static const enterPassword = 'enter_password';
  static const passwordTooShort = 'password_too_short';
  static const enterFirstName = 'enter_first_name';
  static const enterAge = 'enter_age';
  static const mustBe18 = 'must_be_18';
  static const invalidAge = 'invalid_age';
  static const enterCurrentPassword = 'enter_current_password';
  static const enterNewPassword = 'enter_new_password';
  static const chooseDifferentPassword = 'choose_different_password';
  static const passwordsDoNotMatch = 'passwords_do_not_match';

  // --- Session and network ----------------------------------------------
  static const sessionEnded = 'session_ended';
  static const sessionExpired = 'session_expired';
  static const accountSuspended = 'account_suspended';
  static const accountDeleted = 'account_deleted';
  static const serverTooSlow = 'server_too_slow';
  static const cannotReachServer = 'cannot_reach_server';
  static const unexpectedResponse = 'unexpected_response';
  static const somethingWentWrong = 'something_went_wrong';
  static const noValidSession = 'no_valid_session';

  // --- Home --------------------------------------------------------------
  static const greeting = 'greeting';
  static const signOut = 'sign_out';
  static const screensComingNext = 'screens_coming_next';

  // --- Entitlements ------------------------------------------------------
  static const entSendMessages = 'ent_send_messages';
  static const entSeeWhoLikedYou = 'ent_see_who_liked_you';
  static const entAdvancedFilters = 'ent_advanced_filters';
  static const entProfileVisitors = 'ent_profile_visitors';
  static const entSuperLikes = 'ent_super_likes';
  static const entSuperLikesWithQuota = 'ent_super_likes_with_quota';

  // --- Plan tiers --------------------------------------------------------
  /// Only the free tier is translated. Essential, Premium and Prestige are
  /// product names and stay as they are in both languages.
  static const tierFree = 'tier_free';

  // --- Placeholders ------------------------------------------------------
  static const comingSoon = 'coming_soon';
  static const registerPlaceholderNote = 'register_placeholder_note';
  static const yourProfile = 'your_profile';
  static const profileSetupNote = 'profile_setup_note';
}
