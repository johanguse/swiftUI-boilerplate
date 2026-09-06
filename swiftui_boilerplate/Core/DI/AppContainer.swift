import Foundation
import SwiftUI
import Observation

@Observable
@MainActor
final class AppContainer {

    // MARK: - Repositories
    let authRepository: any AuthRepositoryProtocol
    let userRepository: any UserRepositoryProtocol

    // MARK: - Core Services
    let router: AppRouter
    let themeManager: ThemeManager
    let localizationManager: LocalizationManager
    let onboardingManager: OnboardingManager
    let analytics: any AnalyticsService
    let crashReporter: any CrashReporter
    let notificationService: NotificationService
    let purchaseManager: PurchaseManager

    // MARK: - Init
    init() {
        let dataSource = APIDataSource()
        authRepository = APIAuthRepository(dataSource: dataSource)
        userRepository = APIUserRepository(dataSource: dataSource)
        router = AppRouter()
        themeManager = ThemeManager()
        localizationManager = LocalizationManager()
        onboardingManager = OnboardingManager()
        analytics = AppAnalyticsService()
        crashReporter = AppCrashReporter()
        notificationService = NotificationService()
        purchaseManager = PurchaseManager()
        wireNotificationService()
    }

    // MARK: - Session Restore

    private func wireNotificationService() {
        notificationService.onTokenRegistered = { [weak self] token in
            guard let self else { return }
            do {
                try await self.userRepository.registerPushToken(token)
            } catch {
                self.crashReporter.record(error)
            }
        }
    }

    func restoreSession() async {
        defer { router.isCheckingSession = false }

        async let minimumDisplay: Void = Task.sleep(for: .seconds(1))

        if !onboardingManager.hasCompleted {
            try? await minimumDisplay
            router.showOnboarding()
            return
        }

        if let cached = UserCache.load() {
            authRepository.seedCachedUser(cached)
            router.signIn()

            Task {
                if let fresh = try? await authRepository.restoreSession() {
                    UserCache.save(fresh)
                    identify(user: fresh)
                } else {
                    UserCache.clear()
                    router.signOut()
                }
            }
        } else {
            if let user = try? await authRepository.restoreSession() {
                UserCache.save(user)
                identify(user: user)
                router.signIn()
            }
        }

        try? await minimumDisplay
    }

    // MARK: - Auth helpers

    /// Call after every successful sign-in or session restore.
    func identify(user: User) {
        analytics.identify(userId: user.id)
        crashReporter.setUser(id: user.id)
        purchaseManager.configure(userId: user.id)
    }

    /// Clears analytics + crash-reporter identity then signs the user out.
    func signOut() async {
        analytics.reset()
        crashReporter.clearUser()
        purchaseManager.logOut()
        // Sign out locally regardless of network failure; record it so silent
        // server-side session leaks are still visible in crash reporting.
        do { try await authRepository.signOut() } catch { crashReporter.record(error) }
        router.signOut()
    }

    // MARK: - Onboarding

    func finishOnboarding() {
        onboardingManager.complete()
        router.completeOnboarding()
    }
}

// MARK: - Environment Support

extension EnvironmentValues {
    @Entry var appContainer: AppContainer = AppContainer()
}
