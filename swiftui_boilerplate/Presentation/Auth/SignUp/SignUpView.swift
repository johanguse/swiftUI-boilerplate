import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: SignUpViewModel
    private let localization: LocalizationManager
    private let router: AppRouter

    init(container: AppContainer) {
        self.localization = container.localizationManager
        self.router = container.router
        _viewModel = State(initialValue: SignUpViewModel(
            signUpUseCase: SignUpUseCase(repository: container.authRepository),
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
                signInLink
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)
            .padding(.bottom, 48)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle(localization.localizedString(for: .signUp))
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .colorScheme(.dark)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.appText)
                }
                .buttonStyle(.plain)
            }
        }
        .hideKeyboardOnTap()
        .errorAlert(message: $viewModel.errorMessage, localization: localization)
    }

    // MARK: - Subviews

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(localization.localizedString(for: .createAccount))
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
                title: localization.localizedString(for: .fullName),
                text: $viewModel.name,
                textContentType: .name
            )

            AppTextField(
                title: localization.localizedString(for: .email),
                text: $viewModel.email,
                keyboardType: .emailAddress,
                textContentType: .emailAddress
            )

            AppTextField(
                title: localization.localizedString(for: .password),
                text: $viewModel.password,
                textContentType: .newPassword,
                isSecure: true
            )

            AppTextField(
                title: localization.localizedString(for: .confirmPassword),
                text: $viewModel.confirmPassword,
                textContentType: .newPassword,
                isSecure: true
            )

            PrimaryButton(
                title: localization.localizedString(for: .createAccount),
                isLoading: viewModel.isLoading,
                isDisabled: !viewModel.isFormValid
            ) {
                Task { await viewModel.signUp() }
            }
        }
    }

    private var signInLink: some View {
        HStack(spacing: 4) {
            Text(localization.localizedString(for: .alreadyHaveAccount))
                .font(.subheadline)
                .foregroundStyle(Color.appSubtext)

            Button(localization.localizedString(for: .signIn)) {
                router.authPath = [.signIn]
            }
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(Color.appPrimary)
        }
    }
}
