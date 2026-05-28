import SwiftUI
import PhotosUI

struct SettingsView: View {
    @State private var viewModel: SettingsViewModel
    @State private var showLanguagePicker = false
    @State private var showChangePassword = false
    @State private var changePasswordViewModel: ChangePasswordViewModel?

    private let themeManager: ThemeManager
    private let localizationManager: LocalizationManager
    private let purchaseManager: PurchaseManager

    init(container: AppContainer) {
        self.themeManager = container.themeManager
        self.localizationManager = container.localizationManager
        self.purchaseManager = container.purchaseManager
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
        @Bindable var bindablePurchase = purchaseManager

        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    profileHeader
                    accountSection
                    subscriptionSection
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
                .presentationDetents([.height(CGFloat(72 + AppLanguage.allCases.count * 57))])
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $bindablePurchase.isPresentingPaywall) {
                AppPaywallView()
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
                    localization: localizationManager,
                    authRepository: viewModel.authRepository
                )
                showChangePassword = true
            }
        }
    }

    // MARK: - Subscription Section

    private var subscriptionSection: some View {
        VStack(spacing: 16) {
            if !purchaseManager.isProUser {
                ProPromoCard(
                    title: localizationManager.localizedString(for: .upgradeToPro),
                    subtitle: localizationManager.localizedString(for: .subscription),
                    actionTitle: localizationManager.localizedString(for: .upgradeToPro)
                ) {
                    purchaseManager.isPresentingPaywall = true
                }
            }

            SettingsSectionCard(title: localizationManager.localizedString(for: .subscription)) {
                if purchaseManager.isProUser {
                    SettingsRow(
                        icon: "star.fill",
                        iconColor: .yellow,
                        label: localizationManager.localizedString(for: .proActive),
                        showChevron: false
                    )
                } else {
                    SettingsRow(
                        icon: "star.fill",
                        iconColor: Color.appPrimary,
                        label: localizationManager.localizedString(for: .upgradeToPro)
                    ) {
                        purchaseManager.isPresentingPaywall = true
                    }
                }

                Divider().padding(.leading, 56)

                SettingsRow(
                    icon: "arrow.clockwise",
                    iconColor: .gray,
                    label: purchaseManager.isLoadingRestore
                        ? localizationManager.localizedString(for: .restoring)
                        : localizationManager.localizedString(for: .restorePurchases),
                    showChevron: false
                ) {
                    Task { await purchaseManager.restorePurchases() }
                }
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
