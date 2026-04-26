import UIKit
import UserNotifications

#if canImport(FirebaseCore)
import FirebaseCore
import FirebaseMessaging
#endif

#if canImport(RevenueCat)
import RevenueCat
#endif

// No @MainActor on the class: UIApplicationDelegate protocol requirements are
// nonisolated; adding @MainActor generates actor-isolation warnings for every method.
// All UIKit app-delegate callbacks arrive on the main thread anyway.
final class AppDelegate: NSObject, UIApplicationDelegate {

    // Assigned from the SwiftUI App struct on the main actor after launch.
    // Only ever read/written from UIKit callbacks (main thread) or
    // Task { @MainActor in … } blocks, so no data race occurs.
    var container: AppContainer?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        #if canImport(FirebaseCore)
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        #endif

        #if canImport(RevenueCat)
        Purchases.configure(withAPIKey: RevenueCatConfig.apiKey)
        #if DEBUG
        Purchases.logLevel = .debug
        #endif
        #endif

        return true
    }

    // MARK: - APNs token

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        #if canImport(FirebaseCore)
        // Hand the raw APNs token to Firebase so it can exchange it for an FCM token.
        // The FCM token arrives in MessagingDelegate below and is the one we sync to backend.
        Messaging.messaging().apnsToken = deviceToken
        #else
        // Without Firebase, sync the APNs hex token directly to the backend.
        Task { @MainActor in
            container?.notificationService.registerDeviceToken(deviceToken)
        }
        #endif
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        Task { @MainActor in
            container?.notificationService.registrationFailed(error)
            container?.crashReporter.log("APNs registration failed: \(error)")
        }
    }
}

// MARK: - FCM Delegate (Firebase only)

#if canImport(FirebaseCore)
extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        print("[FCM] New token: \(token)")
        Task { @MainActor in
            await container?.notificationService.onTokenRegistered?(token)
        }
    }
}
#endif
