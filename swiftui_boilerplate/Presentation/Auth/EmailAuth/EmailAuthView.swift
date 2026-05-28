import SwiftUI

struct EmailAuthView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: EmailAuthViewModel
    private let localization: LocalizationManager
    private let onClose: (() -> Void)?

    init(container: AppContainer, onClose: (() -> Void)? = nil) {
        self.localization = container.localizationManager
        self.onClose = onClose
        _viewModel = State(initialValue: EmailAuthViewModel(
            sendCodeUseCase: SendEmailCodeUseCase(repository: container.authRepository),
            verifyCodeUseCase: VerifyEmailCodeUseCase(repository: container.authRepository),
            router: container.router,
            localization: container.localizationManager,
            analytics: container.analytics
        ))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                if viewModel.step == .email {
                    emailStep
                        .transition(.asymmetric(
                            insertion: .move(edge: .leading).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                } else {
                    codeStep
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .trailing).combined(with: .opacity)
                        ))
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)
            .padding(.bottom, 48)
            .animation(.easeInOut(duration: 0.3), value: viewModel.step)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle(localization.localizedString(for: .continueWithEmail))
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { closeAction() } label: {
                    Label(localization.localizedString(for: .close), systemImage: "xmark")
                        .labelStyle(.iconOnly)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.appSubtext)
                        .frame(width: 36, height: 36)
                        .background(Color.appSubtext.opacity(0.12))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(localization.localizedString(for: .close))
            }
        }
        .colorScheme(.dark)
        .hideKeyboardOnTap()
        .errorAlert(message: $viewModel.errorMessage, localization: localization)
    }

    // MARK: - Email Step

    private var emailStep: some View {
        VStack(spacing: 32) {
            VStack(alignment: .leading, spacing: 8) {
                Text(localization.localizedString(for: .emailAuthEmailSubtitle))
                    .font(.subheadline)
                    .foregroundStyle(Color.appSubtext)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 16) {
                AppTextField(
                    title: localization.localizedString(for: .email),
                    text: $viewModel.email,
                    keyboardType: .emailAddress,
                    textContentType: .emailAddress
                )

                PrimaryButton(
                    title: localization.localizedString(for: .sendCode),
                    isLoading: viewModel.isLoading,
                    isDisabled: !viewModel.isEmailValid
                ) {
                    Task { await viewModel.sendCode() }
                }
            }
        }
    }

    // MARK: - Code Step

    private var codeStep: some View {
        VStack(spacing: 32) {
            VStack(alignment: .leading, spacing: 8) {
                Text(localization.localizedString(for: .checkYourEmail))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appText)

                Text(localization.localizedString(for: .emailAuthCodeSubtitle))
                    .font(.subheadline)
                    .foregroundStyle(Color.appSubtext)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 16) {
                AppTextField(
                    title: localization.localizedString(for: .verificationCode),
                    text: $viewModel.code,
                    keyboardType: .numberPad,
                    textContentType: .oneTimeCode
                )

                PrimaryButton(
                    title: localization.localizedString(for: .verify),
                    isLoading: viewModel.isLoading,
                    isDisabled: !viewModel.isCodeValid
                ) {
                    Task { await viewModel.verifyCode() }
                }

                HStack(spacing: 4) {
                    Button(localization.localizedString(for: .resendCode)) {
                        Task { await viewModel.resendCode() }
                    }
                    .font(.subheadline)
                    .foregroundStyle(Color.appPrimary)

                    Spacer()

                    Button(localization.localizedString(for: .backToSignIn)) {
                        viewModel.backToEmail()
                    }
                    .font(.subheadline)
                    .foregroundStyle(Color.appSubtext)
                }
            }
        }
    }

    private func closeAction() {
        if let onClose { onClose() } else { dismiss() }
    }
}
