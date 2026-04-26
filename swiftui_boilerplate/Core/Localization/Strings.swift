import Foundation

enum LocalizationKey: String {
    // Onboarding
    case onboardingSkip = "onboarding_skip"
    case onboardingNext = "onboarding_next"
    case onboardingGetStarted = "onboarding_get_started"
    case onboardingWelcomeTitle = "onboarding_welcome_title"
    case onboardingWelcomeSubtitle = "onboarding_welcome_subtitle"
    case onboardingFeaturesTitle = "onboarding_features_title"
    case onboardingFeaturesSubtitle = "onboarding_features_subtitle"
    case onboardingReadyTitle = "onboarding_ready_title"
    case onboardingReadySubtitle = "onboarding_ready_subtitle"
    case featureSecureTitle = "feature_secure_title"
    case featureSecureDesc = "feature_secure_desc"
    case featureFastTitle = "feature_fast_title"
    case featureFastDesc = "feature_fast_desc"
    case featureGlobalTitle = "feature_global_title"
    case featureGlobalDesc = "feature_global_desc"

    // Change Password
    case currentPassword = "current_password"
    case newPassword = "new_password"
    case confirmNewPassword = "confirm_new_password"
    case changePasswordTitle = "change_password_title"
    case passwordChanged = "password_changed"
    case passwordMismatch = "password_mismatch"

    // Notifications
    case notificationsTitle = "notifications_title"
    case notificationsSubtitle = "notifications_subtitle"
    case enableNotifications = "enable_notifications"
    case notificationsLater = "notifications_later"

    // Welcome
    case welcomeTitle = "welcome_title"
    case welcomeSubtitle = "welcome_subtitle"
    case signIn = "sign_in"
    case signUp = "sign_up"

    // Sign In
    case email = "email"
    case password = "password"
    case forgotPassword = "forgot_password"
    case noAccount = "no_account"

    // Sign Up
    case fullName = "full_name"
    case confirmPassword = "confirm_password"
    case alreadyHaveAccount = "already_have_account"
    case passwordsDoNotMatch = "passwords_do_not_match"
    case createAccount = "create_account"

    // Forgot Password
    case forgotPasswordTitle = "forgot_password_title"
    case forgotPasswordSubtitle = "forgot_password_subtitle"
    case sendResetLink = "send_reset_link"
    case resetLinkSent = "reset_link_sent"
    case resetLinkSentSubtitle = "reset_link_sent_subtitle"
    case backToSignIn = "back_to_sign_in"

    // Home
    case homeTitle = "home_title"
    case users = "users"
    case followers = "followers"
    case following = "following"
    case goodMorning = "good_morning"
    case goodAfternoon = "good_afternoon"
    case goodEvening = "good_evening"
    case people = "people"
    case noUsersYet = "no_users_yet"
    case myProfile = "my_profile"

    // Profile / Settings (merged)
    case profileTitle = "profile_title"
    case editProfile = "edit_profile"
    case bio = "bio"
    case location = "location"
    case jobTitle = "job_title"

    // Settings
    case changePhoto = "change_photo"
    case settingsTitle = "settings_title"
    case appearance = "appearance"
    case language = "language"
    case account = "account"
    case signOut = "sign_out"
    case signOutConfirm = "sign_out_confirm"
    case profileUpdated = "profile_updated"
    case appVersion = "app_version"
    case changePassword = "change_password"
    case darkMode = "dark_mode"
    case about = "about"
    case privacyPolicy = "privacy_policy"
    case termsOfService = "terms_of_service"

    // Theme options
    case themeLight = "theme_light"
    case themeDark = "theme_dark"
    case themeSystem = "theme_system"

    // General
    case loading = "loading"
    case errorGeneric = "error_generic"
    case save = "save"
    case cancel = "cancel"
    case done = "done"
    case ok = "ok"
    case error = "error"
    case success = "success"

    // Validation
    case invalidEmail = "invalid_email"
    case weakPassword = "weak_password"
    case invalidCredentials = "invalid_credentials"
    case emptyName = "empty_name"
}
