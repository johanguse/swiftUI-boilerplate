import SwiftUI

@main
struct swiftui_boilerplateApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var container = AppContainer()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.appContainer, container)
                .preferredColorScheme(container.themeManager.colorScheme)
                .task { await container.restoreSession() }
                .task {
                    // Pass container to AppDelegate after init
                    await MainActor.run { appDelegate.container = container }
                }
        }
    }
}

// MARK: - Root View

private struct RootView: View {
    @Environment(\.appContainer) private var container

    var body: some View {
        @Bindable var router = container.router

        Group {
            if router.isCheckingSession {
                LaunchView()
            } else if router.needsOnboarding {
                OnboardingView(localization: container.localizationManager) {
                    container.finishOnboarding()
                }
            } else if router.isAuthenticated {
                MainTabView(container: container)
            } else {
                AuthFlowView(router: router, container: container)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: router.isCheckingSession)
        .animation(.easeInOut(duration: 0.4), value: router.needsOnboarding)
        .animation(.easeInOut(duration: 0.4), value: router.isAuthenticated)
    }
}
