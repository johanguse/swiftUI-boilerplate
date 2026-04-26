import Foundation

// MARK: - Type aliases
//
// AppContainer references AppAnalyticsService and AppCrashReporter.
// These aliases automatically switch between Firebase implementations and
// no-op stubs depending on whether the Firebase packages are linked.
//
// To enable Firebase:
//   1. Add packages in Xcode → File → Add Package Dependencies:
//      • https://github.com/firebase/firebase-ios-sdk  (FirebaseAnalytics, FirebaseCrashlytics)
//   2. Download GoogleService-Info.plist from the Firebase console and add it to the project.
//   3. Call FirebaseApp.configure() in AppDelegate.application(_:didFinishLaunchingWithOptions:).
//
// Once the package is linked, #if canImport(FirebaseCore) activates the real implementations below.

#if canImport(FirebaseCore)
import FirebaseCore
import FirebaseAnalytics
import FirebaseCrashlytics

typealias AppAnalyticsService = FirebaseAnalyticsService
typealias AppCrashReporter    = FirebaseCrashReporter

// MARK: - Firebase Analytics

struct FirebaseAnalyticsService: AnalyticsService {
    func trackScreen(_ name: String) {
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: name
        ])
    }

    func trackEvent(_ name: String, parameters: [String: Any]) {
        Analytics.logEvent(name, parameters: parameters.isEmpty ? nil : parameters)
    }

    func trackSignIn(method: String) {
        Analytics.logEvent(AnalyticsEventLogin, parameters: [AnalyticsParameterMethod: method])
    }

    func trackSignUp(method: String) {
        Analytics.logEvent(AnalyticsEventSignUp, parameters: [AnalyticsParameterMethod: method])
    }

    func identify(userId: String) {
        Analytics.setUserID(userId)
    }

    func reset() {
        Analytics.setUserID(nil)
    }
}

// MARK: - Firebase Crashlytics

struct FirebaseCrashReporter: CrashReporter {
    init() {
        // Disable collection in debug builds to avoid polluting crash reports
        #if DEBUG
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(false)
        #endif
    }

    func log(_ message: String) {
        Crashlytics.crashlytics().log(message)
    }

    func record(_ error: Error) {
        Crashlytics.crashlytics().record(error: error)
    }

    func setUser(id: String) {
        Crashlytics.crashlytics().setUserID(id)
    }

    func clearUser() {
        Crashlytics.crashlytics().setUserID("")
    }
}

#else

// Fallback when Firebase packages are not yet added
typealias AppAnalyticsService = NullAnalyticsService
typealias AppCrashReporter    = NullCrashReporter

#endif
