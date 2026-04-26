import SwiftUI

struct ChangePasswordView: View {
    @Bindable var viewModel: ChangePasswordViewModel
    let localization: LocalizationManager
    var onSuccess: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Icon header
                    ZStack {
                        Circle()
                            .fill(Color.appPrimary.opacity(0.12))
                            .frame(width: 80, height: 80)
                        Image(systemName: "lock.rotation")
                            .font(.system(size: 32, weight: .medium))
                            .foregroundStyle(Color.appPrimary)
                    }
                    .padding(.top, 8)

                    VStack(spacing: 16) {
                        AppTextField(
                            title: localization.localizedString(for: .currentPassword),
                            text: $viewModel.currentPassword,
                            textContentType: .password,
                            isSecure: true
                        )

                        AppTextField(
                            title: localization.localizedString(for: .newPassword),
                            text: $viewModel.newPassword,
                            textContentType: .newPassword,
                            isSecure: true
                        )

                        VStack(alignment: .leading, spacing: 4) {
                            AppTextField(
                                title: localization.localizedString(for: .confirmNewPassword),
                                text: $viewModel.confirmPassword,
                                textContentType: .newPassword,
                                isSecure: true
                            )
                            if viewModel.passwordMismatch {
                                Text(localization.localizedString(for: .passwordMismatch))
                                    .font(.caption)
                                    .foregroundStyle(Color.appError)
                                    .padding(.horizontal, 4)
                                    .transition(.opacity)
                            }
                        }
                        .animation(.easeInOut(duration: 0.2), value: viewModel.passwordMismatch)
                    }

                    PrimaryButton(
                        title: localization.localizedString(for: .changePasswordTitle),
                        isLoading: viewModel.isLoading,
                        isDisabled: !viewModel.isFormValid
                    ) {
                        Task {
                            let success = await viewModel.changePassword()
                            if success { onSuccess() }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle(localization.localizedString(for: .changePasswordTitle))
            .navigationBarTitleDisplayMode(.inline)
            .errorAlert(message: $viewModel.errorMessage, localization: localization)
        }
        .hideKeyboardOnTap()
    }
}
