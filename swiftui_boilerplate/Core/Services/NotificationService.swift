import Foundation
import UserNotifications
import UIKit

@Observable
@MainActor
final class NotificationService: NSObject {

    private(set) var permissionStatus: UNAuthorizationStatus = .notDetermined
    private(set) var deviceToken: String?

    // Assigned by AppContainer. Called with the token that should be sent to the backend
    // (APNs hex when Firebase is absent; FCM token when Firebase is linked).
    var onTokenRegistered: ((String) async -> Void)?

    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    // MARK: - Permission

    @discardableResult
    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
            await refreshStatus()
            if granted {
                // Already on @MainActor — call directly, no extra hop needed.
                UIApplication.shared.registerForRemoteNotifications()
            }
            return granted
        } catch {
            return false
        }
    }

    func refreshStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        permissionStatus = settings.authorizationStatus
    }

    // MARK: - Token (called from AppDelegate on the APNs path, no-Firebase only)

    nonisolated func registerDeviceToken(_ tokenData: Data) {
        let hex = tokenData.map { String(format: "%02x", $0) }.joined()
        Task { @MainActor in
            self.deviceToken = hex
            await self.onTokenRegistered?(hex)
        }
    }

    nonisolated func registrationFailed(_ error: Error) {
        print("[Notifications] APNs registration failed: \(error)")
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationService: UNUserNotificationCenterDelegate {

    // Show banner + sound when notification arrives while app is foregrounded.
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }

    // Handle tap on a notification (app in background or killed).
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        print("[Notifications] Tapped: \(userInfo)")
        // Wire deep-link routing here when needed.
        completionHandler()
    }
}
