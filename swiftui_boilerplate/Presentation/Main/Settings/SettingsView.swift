import SwiftUI
import PhotosUI

struct SettingsView: View {
    @State private var viewModel: SettingsViewModel
    @State private var showLanguagePicker = false
    @State private var showChangePassword = false
    @State private var changePasswordViewModel: ChangePasswordViewModel?

    private let themeManager: ThemeManager
    private let localizationManager: LocalizationManager
    private let authRepository: any AuthRepositoryProtocol

    init(container: AppContainer) {
        self.themeManager = container.themeManager
        self.localizationManager = container.localizationManager
        self.authRepository = container.authRepository
        _viewModel = State(initialValue: SettingsViewModel(
            themeManager: container.themeManager,
            localizationManager: container.localizationManager,
            updateProfileUseCase: UpdateProfileUseCase(repository: container.userRepository),
            userRepository: container.userRepository,
            authRepository: container.authRepository,
            router: container.router,
            signOutAction: { await container.signOut() }
        ))
    }

    var body: some View {
        @Bindable var bindableTheme = themeManager
        @Bindable var bindableLang = localizationManager

        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    profileHeader
                    accountSection
                    preferencesSection(themeBinding: $bindableTheme.selectedTheme,
                                       languageBinding: $bindableLang.currentLanguage)
                    aboutSection
                    signOutSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle(localizationManager.localizedString(for: .settingsTitle))
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $viewModel.showEditProfileSheet) {
                EditProfileSheet(viewModel: viewModel, localization: localizationManager)
            }
            .sheet(isPresented: $showChangePassword) {
                if let cpvm = changePasswordViewModel {
                    ChangePasswordView(
                        viewModel: cpvm,
                        localization: localizationManager
                    ) {
                        showChangePassword = false
                        viewModel.successMessage = localizationManager.localizedString(for: .passwordChanged)
                    }
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                }
            }
            .sheet(isPresented: $showLanguagePicker) {
                LanguagePickerSheet(
                    localization: localizationManager,
                    languageBinding: $bindableLang.currentLanguage,
                    isPresented: $showLanguagePicker
                )
                .presentationDetents([.height(200)])
                .presentationDragIndicator(.visible)
            }
            .alert(
                localizationManager.localizedString(for: .signOut),
                isPresented: $viewModel.showSignOutAlert
            ) {
                Button(localizationManager.localizedString(for: .signOut), role: .destructive) {
                    Task { await viewModel.signOut() }
                }
                Button(localizationManager.localizedString(for: .cancel), role: .cancel) {}
            } message: {
                Text(localizationManager.localizedString(for: .signOutConfirm))
            }
            .successAlert(message: $viewModel.successMessage, localization: localizationManager)
            .errorAlert(message: $viewModel.errorMessage, localization: localizationManager)
            .task(id: viewModel.selectedPhotoItem) {
                guard let item = viewModel.selectedPhotoItem else { return }
                await viewModel.handleAvatarSelection(item)
            }
        }
    }

    // MARK: - Profile Header

    private var profileHeader: some View {
        VStack(spacing: 12) {
            if let user = viewModel.currentUser {
                PhotosPicker(
                    selection: $viewModel.selectedPhotoItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    ZStack(alignment: .bottomTrailing) {
                        UserAvatarView(systemName: user.avatarSystemName, avatarUrl: user.avatarUrl, size: .large)
                        Group {
                            if viewModel.isUploadingAvatar {
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

                VStack(spacing: 3) {
                    Text(user.fullName)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.appText)
                    Text(user.email)
                        .font(.subheadline)
                        .foregroundStyle(Color.appSubtext)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color.appSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    // MARK: - Account Section

    private var accountSection: some View {
        SettingsSectionCard(title: localizationManager.localizedString(for: .account)) {
            SettingsRow(
                icon: "person.fill",
                iconColor: .blue,
                label: localizationManager.localizedString(for: .editProfile)
            ) { viewModel.openEditProfile() }

            Divider().padding(.leading, 56)

            SettingsRow(
                icon: "lock.fill",
                iconColor: .orange,
                label: localizationManager.localizedString(for: .changePassword)
            ) {
                changePasswordViewModel = ChangePasswordViewModel(
                    authRepository: authRepository,
                    localization: localizationManager
                )
                showChangePassword = true
            }
        }
    }

    // MARK: - Preferences Section

    private func preferencesSection(
        themeBinding: Binding<AppTheme>,
        languageBinding: Binding<AppLanguage>
    ) -> some View {
        SettingsSectionCard(title: localizationManager.localizedString(for: .appearance)) {
            SettingsToggleRow(
                icon: "moon.fill",
                iconColor: .indigo,
                label: localizationManager.localizedString(for: .darkMode),
                isOn: Binding(
                    get: { themeBinding.wrappedValue == .dark },
                    set: { themeBinding.wrappedValue = $0 ? .dark : .system }
                )
            )

            Divider().padding(.leading, 56)

            SettingsRow(
                icon: "globe",
                iconColor: .green,
                label: localizationManager.localizedString(for: .language),
                value: "\(languageBinding.wrappedValue.flag) \(languageBinding.wrappedValue.shortCode)"
            ) { showLanguagePicker = true }
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        SettingsSectionCard(title: localizationManager.localizedString(for: .about)) {
            SettingsRow(
                icon: "info.circle.fill",
                iconColor: Color.appSubtext,
                label: localizationManager.localizedString(for: .appVersion),
                value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—",
                showChevron: false
            )

            Divider().padding(.leading, 56)

            SettingsRow(
                icon: "hand.raised.fill",
                iconColor: .teal,
                label: localizationManager.localizedString(for: .privacyPolicy)
            ) {}

            Divider().padding(.leading, 56)

            SettingsRow(
                icon: "doc.text.fill",
                iconColor: .cyan,
                label: localizationManager.localizedString(for: .termsOfService)
            ) {}
        }
    }

    // MARK: - Sign Out Section

    private var signOutSection: some View {
        SettingsSectionCard(title: "") {
            Button {
                viewModel.showSignOutAlert = true
            } label: {
                HStack(spacing: 14) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .background(Color.appError)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    Text(localizationManager.localizedString(for: .signOut))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.appError)
                    Spacer()
                }
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
        }
    }
}

// MARK: - Settings Row

private struct SettingsRow: View {
    let icon: String
    let iconColor: Color
    let label: String
    var value: String? = nil
    var showChevron: Bool = true
    var action: (() -> Void)? = nil

    var body: some View {
        Button {
            action?()
        } label: {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
                    .background(iconColor)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                Text(label)
                    .font(.subheadline)
                    .foregroundStyle(Color.appText)

                Spacer()

                if let value {
                    Text(value)
                        .font(.subheadline)
                        .foregroundStyle(Color.appSubtext)
                }

                if showChevron && action != nil {
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.appSubtext.opacity(0.5))
                }
            }
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(action == nil)
    }
}

// MARK: - Settings Toggle Row

private struct SettingsToggleRow: View {
    let icon: String
    let iconColor: Color
    let label: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(iconColor)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(label)
                .font(.subheadline)
                .foregroundStyle(Color.appText)

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding(.vertical, 12)
    }
}

// MARK: - Settings Section Card

private struct SettingsSectionCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if !title.isEmpty {
                Text(title.uppercased())
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.appSubtext)
                    .padding(.horizontal, 4)
                    .padding(.bottom, 8)
            }

            VStack(alignment: .leading, spacing: 0) {
                content
            }
            .padding(.horizontal, 16)
            .background(Color.appSurface)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }
}

// MARK: - Language Picker Sheet

private struct LanguagePickerSheet: View {
    let localization: LocalizationManager
    @Binding var languageBinding: AppLanguage
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 0) {
            Text(localization.localizedString(for: .language))
                .font(.headline)
                .padding(.top, 20)
                .padding(.bottom, 12)

            ForEach(AppLanguage.allCases) { language in
                Button {
                    languageBinding = language
                    isPresented = false
                } label: {
                    HStack {
                        Text(language.flag)
                        Text(language.displayName)
                            .font(.subheadline)
                            .foregroundStyle(Color.appText)
                        Spacer()
                        if languageBinding == language {
                            Image(systemName: "checkmark")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.appPrimary)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                }
                Divider().padding(.horizontal, 24)
            }
            Spacer()
        }
        .background(Color.appSurface.ignoresSafeArea())
    }
}

// MARK: - Edit Profile Sheet

private struct EditProfileSheet: View {
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
                                    UserAvatarView(systemName: user.avatarSystemName, avatarUrl: user.avatarUrl, size: .large)
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
