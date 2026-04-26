import SwiftUI

enum AppTab: String, Hashable {
    case home
    case settings
}

struct MainTabView: View {
    @State private var selectedTab: AppTab = .home
    let container: AppContainer

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(
                container.localizationManager.localizedString(for: .homeTitle),
                systemImage: "house.fill",
                value: AppTab.home
            ) {
                HomeNavigationView(container: container)
            }

            Tab(
                container.localizationManager.localizedString(for: .settingsTitle),
                systemImage: "gearshape.fill",
                value: AppTab.settings
            ) {
                SettingsView(container: container)
            }
        }
    }
}

// MARK: - Home Navigation Wrapper

private struct HomeNavigationView: View {
    @Bindable var router: AppRouter
    let container: AppContainer

    init(container: AppContainer) {
        self.container = container
        self.router = container.router
    }

    var body: some View {
        NavigationStack(path: $router.homePath) {
            HomeView(container: container)
                .navigationDestination(for: HomeRoute.self) { route in
                    switch route {
                    case .userDetail(let user):
                        UserDetailView(user: user, localization: container.localizationManager)
                    }
                }
        }
    }
}
