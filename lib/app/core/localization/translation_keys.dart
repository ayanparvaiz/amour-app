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

  // --- Profile setup wizard ----------------------------------------------
  static const psStepOf = 'ps_step_of';
  static const psNext = 'ps_next';
  static const psFindProfiles = 'ps_find_profiles';
  static const psSaving = 'ps_saving';
  static const psSavingTitle = 'ps_saving_title';
  static const psSavingBlurb = 'ps_saving_blurb';

  static const psGenderTitle = 'ps_gender_title';
  static const psAMan = 'ps_a_man';
  static const psAWoman = 'ps_a_woman';

  static const psAgeTitle = 'ps_age_title';
  static const psAgeBlurb = 'ps_age_blurb';
  static const psAgeFieldHint = 'ps_age_field_hint';
  static const psAgeNotice = 'ps_age_notice';

  static const psLookingForTitle = 'ps_looking_for_title';
  static const psMan = 'ps_man';
  static const psWoman = 'ps_woman';
  static const psEveryone = 'ps_everyone';

  static const psAgeRangeTitle = 'ps_age_range_title';

  static const psLocationTitle = 'ps_location_title';
  static const psLocationHint = 'ps_location_hint';

  static const psPhotoTitle = 'ps_photo_title';
  static const psChoosePhoto = 'ps_choose_photo';
  static const psChangePhoto = 'ps_change_photo';
  static const psRemovePhoto = 'ps_remove_photo';
  static const psTakePhoto = 'ps_take_photo';
  static const psFromGallery = 'ps_from_gallery';
  static const psPhotoError = 'ps_photo_error';

  static const psAboutTitle = 'ps_about_title';
  static const psBioLabel = 'ps_bio_label';
  static const psBioHint = 'ps_bio_hint';
  static const psHobbiesLabel = 'ps_hobbies_label';
  static const psHobbiesHint = 'ps_hobbies_hint';

  static const psDetailsTitle = 'ps_details_title';
  static const psZodiacLabel = 'ps_zodiac_label';
  static const psSelect = 'ps_select';
  static const psReligionLabel = 'ps_religion_label';
  static const psHeightLabel = 'ps_height_label';
  static const psHeightHint = 'ps_height_hint';

  static const psReadyTitle = 'ps_ready_title';
  static const psReadyBlurb = 'ps_ready_blurb';
  static const psSummaryAge = 'ps_summary_age';
  static const psSummaryGender = 'ps_summary_gender';
  static const psSummaryLocation = 'ps_summary_location';
  static const psYearsOld = 'ps_years_old';

  /// Star signs are stored in French whatever the interface language, because
  /// matching compares the stored strings between members. These keys label the
  /// options; the value sent to the server stays French.
  static const zAries = 'z_aries';
  static const zTaurus = 'z_taurus';
  static const zGemini = 'z_gemini';
  static const zCancer = 'z_cancer';
  static const zLeo = 'z_leo';
  static const zVirgo = 'z_virgo';
  static const zLibra = 'z_libra';
  static const zScorpio = 'z_scorpio';
  static const zSagittarius = 'z_sagittarius';
  static const zCapricorn = 'z_capricorn';
  static const zAquarius = 'z_aquarius';
  static const zPisces = 'z_pisces';

  // --- Placeholders ------------------------------------------------------
  static const comingSoon = 'coming_soon';
  static const registerPlaceholderNote = 'register_placeholder_note';
  static const yourProfile = 'your_profile';
  static const profileSetupNote = 'profile_setup_note';
}
