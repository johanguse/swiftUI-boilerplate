import SwiftUI

struct WelcomeView: View {
    let container: AppContainer

    var body: some View {
        ZStack {
            backgroundGradient

            VStack(spacing: 0) {
                Spacer()
                logoSection
                Spacer()
                buttonSection
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
        .navigationBarHidden(true)
    }

    // MARK: - Subviews

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [Color.appBackground, Color.appPrimary.opacity(0.06)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private var logoSection: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.appPrimary.gradient)
                    .frame(width: 100, height: 100)
                Image(systemName: "swift")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundStyle(.white)
            }

            VStack(spacing: 10) {
                Text(container.localizationManager.localizedString(for: .welcomeTitle))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appText)
                    .multilineTextAlignment(.center)

                Text(container.localizationManager.localizedString(for: .welcomeSubtitle))
                    .font(.subheadline)
                    .foregroundStyle(Color.appSubtext)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var buttonSection: some View {
        VStack(spacing: 14) {
            PrimaryButton(
                title: container.localizationManager.localizedString(for: .signIn)
            ) {
                container.router.navigate(to: .signIn)
            }

            SecondaryButton(
                title: container.localizationManager.localizedString(for: .signUp)
            ) {
                container.router.navigate(to: .signUp)
            }
        }
    }
}
