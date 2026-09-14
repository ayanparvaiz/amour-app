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

  // --- Navigation ---------------------------------------------------------
  static const navDiscover = 'nav_discover';
  static const navMatches = 'nav_matches';
  static const navMessages = 'nav_messages';
  static const navProfile = 'nav_profile';
  static const navPlans = 'nav_plans';
  static const navSettings = 'nav_settings';
  static const navTerms = 'nav_terms';
  static const navAdmin = 'nav_admin';
  static const navMenu = 'nav_menu';

  // --- Home ---------------------------------------------------------------
  static const homePerfectMatches = 'home_perfect_matches';
  static const homeSeeAll = 'home_see_all';
  static const homeNoMatches = 'home_no_matches';
  static const homeNoMatchesHint = 'home_no_matches_hint';
  static const homeRetry = 'home_retry';
  static const homeUpgrade = 'home_upgrade';
  static const homeFreeLimit = 'home_free_limit';
  static const homeMatchPercent = 'home_match_percent';
  static const homeLikedYouOne = 'home_liked_you_one';
  static const homeLikedYouMany = 'home_liked_you_many';
  static const homeLikedYouAction = 'home_liked_you_action';
  static const homeDiscoverBody = 'home_discover_body';
  static const homeComingSoonTitle = 'home_coming_soon_title';
  static const homeComingSoonBody = 'home_coming_soon_body';
  static const signOutConfirmTitle = 'sign_out_confirm_title';
  static const signOutConfirmBody = 'sign_out_confirm_body';
  static const cancel = 'cancel';

  // --- Discover -----------------------------------------------------------
  static const discoverFilters = 'discover_filters';
  static const discoverCriteria = 'discover_criteria';
  static const discoverApply = 'discover_apply';
  static const discoverReset = 'discover_reset';
  static const discoverFound = 'discover_found';
  static const discoverLocked = 'discover_locked';
  static const discoverLockedBody = 'discover_locked_body';
  static const discoverUnlock = 'discover_unlock';
  static const discoverLike = 'discover_like';
  static const discoverPass = 'discover_pass';
  static const discoverMessage = 'discover_message';
  static const discoverItsAMatch = 'discover_its_a_match';
  static const discoverLiked = 'discover_liked';
  static const discoverPassed = 'discover_passed';

  // Filter sections
  static const fSectionLocation = 'f_section_location';
  static const fSectionLifestyle = 'f_section_lifestyle';
  static const fSectionAdvanced = 'f_section_advanced';
  static const fDistance = 'f_distance';
  static const fAgeMin = 'f_age_min';
  static const fAgeMax = 'f_age_max';
  static const fKeyword = 'f_keyword';
  static const fKeywordHint = 'f_keyword_hint';
  static const fEyes = 'f_eyes';
  static const fHair = 'f_hair';
  static const fSmoke = 'f_smoke';
  static const fAlcohol = 'f_alcohol';
  static const fChildren = 'f_children';

  // Search level
  static const fLevelWorldwide = 'f_level_worldwide';
  static const fLevelCountry = 'f_level_country';
  static const fLevelDepartment = 'f_level_department';
  static const fLevelRadius = 'f_level_radius';

  /// Filter values are stored strings compared between members, so only the
  /// labels below are translated — never the values themselves.
  static const fSmokeAny = 'f_smoke_any';
  static const fSmokeNo = 'f_smoke_no';
  static const fSmokeOccasional = 'f_smoke_occasional';
  static const fSmokeRegular = 'f_smoke_regular';
  static const fAlcoholAny = 'f_alcohol_any';
  static const fAlcoholNever = 'f_alcohol_never';
  static const fAlcoholOccasionally = 'f_alcohol_occasionally';
  static const fAlcoholRegularly = 'f_alcohol_regularly';
  static const fChildrenAny = 'f_children_any';
  static const fChildrenNone = 'f_children_none';
  static const fChildrenHas = 'f_children_has';
  static const fChildrenWants = 'f_children_wants';
  static const fEyesAny = 'f_eyes_any';
  static const fHairAny = 'f_hair_any';
  static const cBlue = 'c_blue';
  static const cGreen = 'c_green';
  static const cBrown = 'c_brown';
  static const cGrey = 'c_grey';
  static const cHazel = 'c_hazel';
  static const cBlack = 'c_black';
  static const cDarkBrown = 'c_dark_brown';
  static const cBlond = 'c_blond';
  static const cRed = 'c_red';
  static const cWhite = 'c_white';

  // --- Profile ------------------------------------------------------------
  static const profileNotFound = 'profile_not_found';
  static const profileNotFoundBody = 'profile_not_found_body';
  static const profileBackToDiscover = 'profile_back_to_discover';
  static const profileAboutMe = 'profile_about_me';
  static const profileAboutOther = 'profile_about_other';
  static const profileNoBio = 'profile_no_bio';
  static const profileQuickInfo = 'profile_quick_info';
  static const profileMyPreferences = 'profile_my_preferences';
  static const profileDetails = 'profile_details';
  static const profileEdit = 'profile_edit';
  static const profileSubscription = 'profile_subscription';
  static const profileIAm = 'profile_i_am';
  static const profileLookingFor = 'profile_looking_for';
  static const profileNotSet = 'profile_not_set';
  static const profileAdd = 'profile_add';
  static const profileSafetyTitle = 'profile_safety_title';
  static const profileSafetyBody = 'profile_safety_body';
  static const profileLike = 'profile_like';
  static const profileBlock = 'profile_block';
  static const profileReport = 'profile_report';
  static const profileBlockTitle = 'profile_block_title';
  static const profileBlockBody = 'profile_block_body';
  static const profileBlocked = 'profile_blocked';
  static const profileReportTitle = 'profile_report_title';
  static const profileReportHint = 'profile_report_hint';
  static const profileReportSend = 'profile_report_send';
  static const profileReported = 'profile_reported';
  static const profileHobbies = 'profile_hobbies';
  static const profileActivities = 'profile_activities';
  static const profileZodiac = 'profile_zodiac';
  static const profileReligion = 'profile_religion';
  static const profileChildren = 'profile_children';
  static const profileHeight = 'profile_height';
  static const profileHeightCm = 'profile_height_cm';
  static const profileEyes = 'profile_eyes';
  static const profileHair = 'profile_hair';
  static const profileSmoke = 'profile_smoke';
  static const profileAlcohol = 'profile_alcohol';
  static const profileGender = 'profile_gender';

  // --- Matches ------------------------------------------------------------
  static const matchesTitle = 'matches_title';
  static const matchesSubtitle = 'matches_subtitle';
  static const matchesTabMutual = 'matches_tab_mutual';
  static const matchesTabReceived = 'matches_tab_received';
  static const matchesTabSent = 'matches_tab_sent';
  static const matchesNoneTitle = 'matches_none_title';
  static const matchesNoneBody = 'matches_none_body';
  static const matchesStartDiscovering = 'matches_start_discovering';
  static const matchesNoLikesTitle = 'matches_no_likes_title';
  static const matchesNoLikesBody = 'matches_no_likes_body';
  static const matchesNoSentTitle = 'matches_no_sent_title';
  static const matchesNoSentBody = 'matches_no_sent_body';
  static const matchesLockedTitle = 'matches_locked_title';
  static const matchesLockedOne = 'matches_locked_one';
  static const matchesLockedMany = 'matches_locked_many';
  static const matchesSeePlans = 'matches_see_plans';

  // --- Settings -----------------------------------------------------------
  static const setTitle = 'set_title';
  static const setSave = 'set_save';
  static const setSaving = 'set_saving';
  static const setSaved = 'set_saved';
  static const setPhotos = 'set_photos';
  static const setPhotosHint = 'set_photos_hint';
  static const setPhotoMain = 'set_photo_main';
  static const setPhotoMakeMain = 'set_photo_make_main';
  static const setAdd = 'set_add';
  static const setDisplayName = 'set_display_name';
  static const setBio = 'set_bio';
  static const setBioHint = 'set_bio_hint';
  static const setMyGender = 'set_my_gender';
  static const setLookingFor = 'set_looking_for';
  static const setTargetAgeRange = 'set_target_age_range';
  static const setSectionLocation = 'set_section_location';
  static const setGetPosition = 'set_get_position';
  static const setUpdatePosition = 'set_update_position';
  static const setCoordinates = 'set_coordinates';
  static const setLocationDenied = 'set_location_denied';
  static const setLocationOff = 'set_location_off';
  static const setCountry = 'set_country';
  static const setCountryHint = 'set_country_hint';
  static const setRegion = 'set_region';
  static const setRegionHint = 'set_region_hint';
  static const setCity = 'set_city';
  static const setCityHint = 'set_city_hint';
  static const setPublicAddress = 'set_public_address';
  static const setPublicAddressHint = 'set_public_address_hint';
  static const setSectionInterests = 'set_section_interests';
  static const setActivities = 'set_activities';
  static const setActivitiesHint = 'set_activities_hint';
  static const setReligionHint = 'set_religion_hint';
  static const setSectionAppearance = 'set_section_appearance';
  static const setWeight = 'set_weight';
  static const setWeightHint = 'set_weight_hint';
  static const setEyeColourHint = 'set_eye_colour_hint';
  static const setHairColourHint = 'set_hair_colour_hint';
  static const setSectionLifestyle = 'set_section_lifestyle';
  static const setSectionSecurity = 'set_section_security';
  static const setUnsavedTitle = 'set_unsaved_title';
  static const setUnsavedBody = 'set_unsaved_body';
  static const setDiscard = 'set_discard';

  /// Children and smoking are stored with the vocabulary the website's own
  /// settings form writes. See SettingsOptions for why.
  static const setChildrenNone = 'set_children_none';
  static const setChildrenWant = 'set_children_want';
  static const setChildrenHave = 'set_children_have';
  static const setChildrenDontWant = 'set_children_dont_want';
  static const setSmokeNo = 'set_smoke_no';
  static const setSmokeSometimes = 'set_smoke_sometimes';
  static const setSmokeYes = 'set_smoke_yes';

  // --- Settings menu ------------------------------------------------------
  static const setMenuAccount = 'set_menu_account';
  static const setMenuLegal = 'set_menu_legal';
  static const setMenuDanger = 'set_menu_danger';
  static const setEditProfile = 'set_edit_profile';
  static const setEditProfileBody = 'set_edit_profile_body';
  static const setPrivacy = 'set_privacy';
  static const setDeleteAccount = 'set_delete_account';
  static const setDeleteBody = 'set_delete_body';
  static const setDeleteConfirmTitle = 'set_delete_confirm_title';
  static const setDeleteConfirmBody = 'set_delete_confirm_body';
  static const setDeleteTypeToConfirm = 'set_delete_type_to_confirm';
  static const setDeleteWord = 'set_delete_word';
  static const setDeleted = 'set_deleted';

  // --- Messages -----------------------------------------------------------
  static const msgNoChatsTitle = 'msg_no_chats_title';
  static const msgNoChatsBody = 'msg_no_chats_body';
  static const msgStartConversation = 'msg_start_conversation';
  static const msgWriteSomething = 'msg_write_something';
  static const msgInputHint = 'msg_input_hint';
  static const msgOnline = 'msg_online';
  static const msgSend = 'msg_send';
  static const msgFreeBlockedTitle = 'msg_free_blocked_title';
  static const msgFreeBlockedBody = 'msg_free_blocked_body';
  static const msgToday = 'msg_today';
  static const msgYesterday = 'msg_yesterday';
  static const msgSending = 'msg_sending';

  // --- Plans --------------------------------------------------------------
  static const planTitle = 'plan_title';
  static const planSubtitle = 'plan_subtitle';
  static const planCurrent = 'plan_current';
  static const planPerMonth = 'plan_per_month';
  static const planPerWeek = 'plan_per_week';
  static const planSave = 'plan_save';
  static const planBest = 'plan_best';
  static const planRecommended = 'plan_recommended';
  static const planChoose = 'plan_choose';
  static const planWhatYouGet = 'plan_what_you_get';
  static const planUnavailableTitle = 'plan_unavailable_title';
  static const planUnavailableBody = 'plan_unavailable_body';
  static const planAdminTitle = 'plan_admin_title';
  static const planAdminBody = 'plan_admin_body';
  static const planEmpty = 'plan_empty';

  /// Features are listed from what the server actually enforces, not from the
  /// website's marketing copy — four of those claims have nothing behind them.
  static const featUnlimitedBrowsing = 'feat_unlimited_browsing';
  static const featFreeBrowsingLimit = 'feat_free_browsing_limit';
  static const featPriority = 'feat_priority';

  // --- Swipe deck ---------------------------------------------------------
  static const swipeLike = 'swipe_like';
  static const swipeNope = 'swipe_nope';
  static const swipeSuper = 'swipe_super';
  static const swipeSuperLocked = 'swipe_super_locked';
  static const swipeDeckEmpty = 'swipe_deck_empty';
  static const swipeDeckEmptyBody = 'swipe_deck_empty_body';
  static const swipeUndoNone = 'swipe_undo_none';

  // --- Placeholders ------------------------------------------------------
  static const comingSoon = 'coming_soon';
  static const registerPlaceholderNote = 'register_placeholder_note';
  static const yourProfile = 'your_profile';
  static const profileSetupNote = 'profile_setup_note';
}
