import Foundation
import Observation

@Observable
@MainActor
final class AppRouter {
    var isCheckingSession: Bool = true
    var needsOnboarding: Bool = false
    var isAuthenticated: Bool = false
    var authPath: [AuthRoute] = []
    var homePath: [HomeRoute] = []
    var settingsPath: [SettingsRoute] = []

    func signIn() {
        isAuthenticated = true
        needsOnboarding = false
        authPath = []
    }

    func signOut() {
        isAuthenticated = false
        authPath = []
        homePath = []
        settingsPath = []
    }

    func showOnboarding() { needsOnboarding = true }
    func completeOnboarding() { needsOnboarding = false }

    func navigate(to route: AuthRoute) { authPath.append(route) }
    func navigate(to route: HomeRoute) { homePath.append(route) }
    func navigate(to route: SettingsRoute) { settingsPath.append(route) }

    func popAuth() {
        guard !authPath.isEmpty else { return }
        authPath.removeLast()
    }
}
