import SwiftUI

struct ForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ForgotPasswordViewModel
    private let localization: LocalizationManager
    private let router: AppRouter

    init(container: AppContainer) {
        self.localization = container.localizationManager
        self.router = container.router
        _viewModel = State(initialValue: ForgotPasswordViewModel(
            forgotPasswordUseCase: ForgotPasswordUseCase(repository: container.authRepository),
            localization: container.localizationManager
        ))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                if viewModel.isSuccess {
                    successSection
                } else {
                    formSection
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)
            .padding(.bottom, 48)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle(localization.localizedString(for: .forgotPasswordTitle))
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
                .accessibilityLabel(localization.localizedString(for: .back))
            }
        }
        .hideKeyboardOnTap()
        .errorAlert(message: $viewModel.errorMessage, localization: localization)
        .animation(.easeInOut, value: viewModel.isSuccess)
    }

    // MARK: - Subviews

    private var formSection: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text(localization.localizedString(for: .forgotPasswordTitle))
                    .font(.title2)
                    .bold()
                    .foregroundStyle(Color.appText)

                Text(localization.localizedString(for: .forgotPasswordSubtitle))
                    .font(.subheadline)
                    .foregroundStyle(Color.appSubtext)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            AppTextField(
                title: localization.localizedString(for: .email),
                text: $viewModel.email,
                keyboardType: .emailAddress,
                textContentType: .emailAddress
            )

            PrimaryButton(
                title: localization.localizedString(for: .sendResetLink),
                isLoading: viewModel.isLoading,
                isDisabled: !viewModel.isFormValid
            ) {
                Task { await viewModel.sendResetLink() }
            }
        }
    }

    private var successSection: some View {
        VStack(spacing: 32) {
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color.appSuccess.opacity(0.15))
                        .frame(width: 80, height: 80)
                    Image(systemName: "envelope.badge.checkmark.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(Color.appSuccess)
                }

                VStack(spacing: 10) {
                    Text(localization.localizedString(for: .resetLinkSent))
                        .font(.title3)
                        .bold()
                        .foregroundStyle(Color.appText)
                        .multilineTextAlignment(.center)

                    Text(localization.localizedString(for: .resetLinkSentSubtitle))
                        .font(.subheadline)
                        .foregroundStyle(Color.appSubtext)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.top, 40)

            SecondaryButton(title: localization.localizedString(for: .backToSignIn)) {
                router.signOut()
            }
        }
    }
}
