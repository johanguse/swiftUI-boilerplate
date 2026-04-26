import SwiftUI
import PhotosUI
import Observation

@Observable
@MainActor
final class SettingsViewModel {

    // MARK: - Profile State
    private(set) var currentUser: User?
    var showEditProfileSheet: Bool = false

    // MARK: - Avatar Upload
    var selectedPhotoItem: PhotosPickerItem? = nil
    var isUploadingAvatar: Bool = false

    // MARK: - Edit Profile Fields
    var editableName: String = ""
    var editableEmail: String = ""
    var editableJobTitle: String = ""
    var editableBio: String = ""
    var isSaving: Bool = false
    var errorMessage: String? = nil
    var successMessage: String? = nil

    // MARK: - Account State
    var showSignOutAlert: Bool = false

    // MARK: - Dependencies
    let themeManager: ThemeManager
    let localizationManager: LocalizationManager
    private let updateProfileUseCase: UpdateProfileUseCase
    private let userRepository: any UserRepositoryProtocol
    private let authRepository: any AuthRepositoryProtocol
    private let router: AppRouter

    // MARK: - Init

    init(
        themeManager: ThemeManager,
        localizationManager: LocalizationManager,
        updateProfileUseCase: UpdateProfileUseCase,
        userRepository: any UserRepositoryProtocol,
        authRepository: any AuthRepositoryProtocol,
        router: AppRouter,
        signOutAction: @escaping () async -> Void
    ) {
        self.themeManager = themeManager
        self.localizationManager = localizationManager
        self.updateProfileUseCase = updateProfileUseCase
        self.userRepository = userRepository
        self.authRepository = authRepository
        self.router = router
        self.signOutAction = signOutAction
        self.currentUser = authRepository.currentUser
    }

    private let signOutAction: () async -> Void

    // MARK: - Computed

    var isProfileFormValid: Bool {
        editableName.trimmed.isNotEmpty && editableEmail.trimmed.isValidEmail
    }

    // MARK: - Avatar

    func handleAvatarSelection(_ item: PhotosPickerItem) async {
        guard let user = currentUser else { return }
        isUploadingAvatar = true
        errorMessage = nil
        defer { isUploadingAvatar = false }

        do {
            guard let rawData = try await item.loadTransferable(type: Data.self) else { return }

            // Compress image off the main thread to avoid UI blocking
            let compressed = await Task.detached(priority: .userInitiated) {
                Self.compressImage(rawData)
            }.value

            let url = try await userRepository.uploadAvatar(userId: user.id, imageData: compressed)
            let updated = user.updated(avatarUrl: .some(url))
            let saved = try await updateProfileUseCase.execute(updated)
            currentUser = saved
            selectedPhotoItem = nil
        } catch {
            errorMessage = localizationManager.localizedError(error)
        }
    }

    // MARK: - Edit Profile

    func openEditProfile() {
        guard let user = currentUser else { return }
        editableName = user.fullName
        editableEmail = user.email
        editableJobTitle = user.jobTitle
        editableBio = user.bio
        showEditProfileSheet = true
    }

    func saveProfile() async {
        guard isProfileFormValid, let current = currentUser else { return }
        isSaving = true
        errorMessage = nil

        let normalizedName = editableName.trimmed
        let normalizedEmail = editableEmail.trimmed
        let normalizedJobTitle = editableJobTitle.trimmed
        let normalizedBio = editableBio.trimmed

        let updated = current.updated(
            fullName: normalizedName,
            email: normalizedEmail,
            jobTitle: normalizedJobTitle,
            bio: normalizedBio
        )
        do {
            let saved = try await updateProfileUseCase.execute(updated)
            currentUser = saved
            successMessage = localizationManager.localizedString(for: .profileUpdated)
            showEditProfileSheet = false
        } catch {
            errorMessage = localizationManager.localizedError(error)
        }
        isSaving = false
    }

    func signOut() async {
        showSignOutAlert = false
        await signOutAction()
    }

    // MARK: - Private

    /// Compresses an image to a maximum of 512×512px at 0.8 JPEG quality.
    /// Marked `nonisolated` + `Sendable`-safe so it can run on a background thread.
    private nonisolated static func compressImage(_ data: Data) -> Data {
        guard let image = UIImage(data: data) else { return data }
        let maxDimension: CGFloat = 512
        let scale = min(maxDimension / image.size.width, maxDimension / image.size.height, 1.0)
        let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resized = renderer.image { _ in image.draw(in: CGRect(origin: .zero, size: newSize)) }
        return resized.jpegData(compressionQuality: 0.8) ?? data
    }
}
