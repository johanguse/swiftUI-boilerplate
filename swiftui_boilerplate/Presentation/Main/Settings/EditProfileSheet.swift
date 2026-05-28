import SwiftUI
import PhotosUI

struct EditProfileSheet: View {
    @Bindable var viewModel: SettingsViewModel
    let localization: LocalizationManager

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if let user = viewModel.currentUser {
                        let isUploadingAvatar = viewModel.isUploadingAvatar

                        VStack(spacing: 10) {
                            PhotosPicker(
                                selection: $viewModel.selectedPhotoItem,
                                matching: .images,
                                photoLibrary: .shared()
                            ) {
                                ZStack(alignment: .bottomTrailing) {
                                    UserAvatarView(
                                        systemName: user.avatarSystemName,
                                        avatarUrl: user.avatarUrl,
                                        size: .large
                                    )
                                    Group {
                                        if isUploadingAvatar {
                                            ProgressView().tint(.white)
                                        } else {
                                            Image(systemName: "camera.fill")
                                                .font(.caption.weight(.semibold))
                                                .foregroundStyle(.white)
                                        }
                                    }
                                    .padding(6)
                                    .background(Color.appPrimary)
                                    .clipShape(Circle())
                                    .offset(x: 4, y: 4)
                                }
                            }
                            .buttonStyle(.plain)
                            .disabled(viewModel.isUploadingAvatar)

                            Text(localization.localizedString(for: .changePhoto))
                                .font(.caption)
                                .foregroundStyle(Color.appPrimary)
                            Text(user.email)
                                .font(.caption)
                                .foregroundStyle(Color.appSubtext)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 8)
                    }

                    VStack(spacing: 16) {
                        AppTextField(
                            title: localization.localizedString(for: .fullName),
                            text: $viewModel.editableName,
                            textContentType: .name
                        )
                        AppTextField(
                            title: localization.localizedString(for: .email),
                            text: $viewModel.editableEmail,
                            keyboardType: .emailAddress,
                            textContentType: .emailAddress
                        )
                        AppTextField(
                            title: localization.localizedString(for: .jobTitle),
                            text: $viewModel.editableJobTitle
                        )
                        AppTextField(
                            title: localization.localizedString(for: .bio),
                            text: $viewModel.editableBio
                        )
                    }

                    PrimaryButton(
                        title: localization.localizedString(for: .save),
                        isLoading: viewModel.isSaving,
                        isDisabled: !viewModel.isProfileFormValid
                    ) {
                        Task { await viewModel.saveProfile() }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle(localization.localizedString(for: .editProfile))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(localization.localizedString(for: .cancel)) {
                        viewModel.showEditProfileSheet = false
                    }
                }
            }
            .errorAlert(message: $viewModel.errorMessage, localization: localization)
        }
        .hideKeyboardOnTap()
    }
}
