import SwiftUI

struct SignInView: View {
    @State private var viewModel: SignInViewModel
    private let localization: LocalizationManager
    private let router: AppRouter

    init(container: AppContainer) {
        self.localization = container.localizationManager
        self.router = container.router
        _viewModel = State(initialValue: SignInViewModel(
            signInUseCase: SignInUseCase(repository: container.authRepository),
            router: container.router,
            localization: container.localizationManager,
            analytics: container.analytics
        ))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                headerSection
                formSection
                signUpLink
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)
            .padding(.bottom, 48)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle(localization.localizedString(for: .signIn))
        .navigationBarTitleDisplayMode(.large)
        .hideKeyboardOnTap()
        .errorAlert(message: $viewModel.errorMessage, localization: localization)
    }

    // MARK: - Subviews

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(localization.localizedString(for: .signIn))
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(Color.appText)

            Text(localization.localizedString(for: .welcomeSubtitle))
                .font(.subheadline)
                .foregroundStyle(Color.appSubtext)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var formSection: some View {
        VStack(spacing: 16) {
            AppTextField(
                title: localization.localizedString(for: .email),
                text: $viewModel.email,
                keyboardType: .emailAddress,
                textContentType: .emailAddress
            )

            AppTextField(
                title: localization.localizedString(for: .password),
                text: $viewModel.password,
                textContentType: .password,
                isSecure: true
            )

            HStack {
                Spacer()
                Button(localization.localizedString(for: .forgotPassword)) {
                    router.navigate(to: .forgotPassword)
                }
                .font(.subheadline)
                .foregroundStyle(Color.appPrimary)
            }

            PrimaryButton(
                title: localization.localizedString(for: .signIn),
                isLoading: viewModel.isLoading,
                isDisabled: !viewModel.isFormValid
            ) {
                Task { await viewModel.signIn() }
            }
        }
    }

    private var signUpLink: some View {
        HStack(spacing: 4) {
            Text(localization.localizedString(for: .noAccount))
                .font(.subheadline)
                .foregroundStyle(Color.appSubtext)

            Button(localization.localizedString(for: .signUp)) {
                router.navigate(to: .signUp)
            }
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(Color.appPrimary)
        }
    }
}
