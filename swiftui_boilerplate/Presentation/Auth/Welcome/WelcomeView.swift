import SwiftUI
import AuthenticationServices

struct WelcomeView: View {
    let container: AppContainer
    var showsCloseButton: Bool = false
    var onClose: (() -> Void)? = nil

    private var loc: LocalizationManager { container.localizationManager }

    var body: some View {
        ZStack {
            background

            VStack(spacing: 0) {
                if showsCloseButton {
                    closeBar
                }

                Spacer()
                heroSection
                Spacer()
                authButtons
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
            }
        }
        .navigationBarHidden(true)
        .colorScheme(.dark)
    }

    // MARK: - Background

    private var background: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            RadialGradient(
                colors: [Color.appPrimary.opacity(0.25), Color.clear],
                center: .top,
                startRadius: 0,
                endRadius: 420
            )
            .ignoresSafeArea()

            // Decorative rings
            Circle()
                .stroke(Color.appPrimary.opacity(0.08), lineWidth: 1)
                .frame(width: 340, height: 340)
                .offset(y: -120)

            Circle()
                .stroke(Color.appPrimary.opacity(0.05), lineWidth: 1)
                .frame(width: 500, height: 500)
                .offset(y: -100)
        }
    }

    // MARK: - Close bar

    private var closeBar: some View {
        HStack {
            Spacer()
            Button { onClose?() } label: {
                Label(loc.localizedString(for: .close), systemImage: "xmark")
                    .labelStyle(.iconOnly)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.appSubtext)
                    .frame(width: 36, height: 36)
                    .background(Color.appSubtext.opacity(0.12))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(loc.localizedString(for: .close))
            .padding(.trailing, 20)
        }
        .padding(.top, 12)
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.appPrimary.opacity(0.12))
                    .frame(width: 180, height: 180)
                Circle()
                    .fill(Color.appPrimary.opacity(0.18))
                    .frame(width: 130, height: 130)
                Circle()
                    .fill(Color.appPrimary.gradient)
                    .frame(width: 88, height: 88)
                Image(systemName: "swift")
                    .font(.system(size: 38, weight: .bold))
                    .foregroundStyle(.white)
            }

            VStack(spacing: 10) {
                Text(loc.localizedString(for: .welcomeTitle))
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.appText)
                    .multilineTextAlignment(.center)

                Text(loc.localizedString(for: .welcomeTagline))
                    .font(.subheadline)
                    .foregroundStyle(Color.appSubtext)
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: - Auth buttons

    private var authButtons: some View {
        VStack(spacing: 12) {
            SignInWithAppleButton(.continue) { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                handleAppleSignIn(result)
            }
            .signInWithAppleButtonStyle(.white)
            .frame(height: 52)
            .clipShape(RoundedRectangle(cornerRadius: 14))

            SocialAuthButton(
                title: loc.localizedString(for: .continueWithGoogle),
                symbol: "",
                badgeText: "G"
            ) {
                // Google sign-in: wire up via container.authRepository when configured
            }

            SocialAuthButton(
                title: loc.localizedString(for: .continueWithEmail),
                symbol: "envelope.fill",
                badgeText: nil
            ) {
                container.router.navigate(to: .emailAuth)
            }
        }
    }

    // MARK: - Apple sign-in handler

    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        // Wire up Apple sign-in to container.authRepository when configured.
        // On success call container.router.signIn()
    }
}
