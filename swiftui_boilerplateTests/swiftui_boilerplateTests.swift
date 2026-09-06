//
//  swiftui_boilerplateTests.swift
//  swiftui_boilerplateTests
//
//  Created by Nebi Berke İçöz on 1.04.2026.
//

import XCTest
@testable import swiftui_boilerplate

@MainActor
final class swiftui_boilerplateTests: XCTestCase {

    func testToAPIUserDTOEncodesCloudflareBackendShape() throws {
        let user = User(
            id: "user-1",
            fullName: "Jane Doe",
            email: "jane@example.com",
            avatarSystemName: "person.fill",
            avatarUrl: nil,
            jobTitle: "",
            location: "",
            bio: "",
            followersCount: 42,
            followingCount: 11
        )

        let data = try JSONEncoder().encode(user.toAPIUserDTO())
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])

        XCTAssertEqual(json["id"] as? String, "user-1")
        XCTAssertEqual(json["email"] as? String, "jane@example.com")
        XCTAssertEqual(json["name"] as? String, "Jane Doe")
        XCTAssertTrue(json["image"] is NSNull)
        XCTAssertNil(json["job_title"])
        XCTAssertNil(json["location"])
        XCTAssertNil(json["bio"])
    }

    func testSettingsViewModelSaveProfileAllowsClearingOptionalFields() async {
        let userRepository = MockUserRepository()
        let authRepository = MockAuthRepository(currentUser: User(
            id: "user-1",
            fullName: "Jane Doe",
            email: "jane@example.com",
            avatarSystemName: "person.fill",
            avatarUrl: nil,
            jobTitle: "iOS Engineer",
            location: "Istanbul",
            bio: "Hello",
            followersCount: 42,
            followingCount: 11
        ))
        let router = AppRouter()
        let viewModel = SettingsViewModel(
            themeManager: ThemeManager(),
            localizationManager: LocalizationManager(),
            updateProfileUseCase: UpdateProfileUseCase(repository: userRepository),
            userRepository: userRepository,
            authRepository: authRepository,
            router: router
        )

        viewModel.openEditProfile()
        viewModel.editableJobTitle = ""
        viewModel.editableBio = ""

        await viewModel.saveProfile()

        XCTAssertEqual(userRepository.updatedUsers.last?.jobTitle, "")
        XCTAssertEqual(userRepository.updatedUsers.last?.bio, "")
        XCTAssertEqual(viewModel.currentUser?.jobTitle, "")
        XCTAssertEqual(viewModel.currentUser?.bio, "")
    }

    func testSettingsViewModelSignOutRoutesAwayEvenWhenRepositoryThrows() async {
        let userRepository = MockUserRepository()
        let authRepository = MockAuthRepository(
            currentUser: nil,
            signOutError: AppError.unknown("Network issue")
        )
        let router = AppRouter()
        router.signIn()

        let viewModel = SettingsViewModel(
            themeManager: ThemeManager(),
            localizationManager: LocalizationManager(),
            updateProfileUseCase: UpdateProfileUseCase(repository: userRepository),
            userRepository: userRepository,
            authRepository: authRepository,
            router: router
        )

        await viewModel.signOut()

        XCTAssertFalse(router.isAuthenticated)
        XCTAssertEqual(authRepository.signOutCallCount, 1)
        XCTAssertEqual(viewModel.errorMessage, "Network issue")
    }
}

// MARK: - ChangePasswordViewModel Tests

@MainActor
final class ChangePasswordViewModelTests: XCTestCase {

    func testChangePasswordCallsRepositoryWithCorrectPasswords() async {
        let authRepository = MockAuthRepository(currentUser: nil)
        let viewModel = ChangePasswordViewModel(
            localization: LocalizationManager(),
            authRepository: authRepository
        )

        viewModel.currentPassword = "oldpass123"
        viewModel.newPassword = "newpass456"
        viewModel.confirmPassword = "newpass456"

        let success = await viewModel.changePassword()

        XCTAssertTrue(success)
        XCTAssertEqual(authRepository.changePasswordCallCount, 1)
        XCTAssertEqual(authRepository.lastCurrentPassword, "oldpass123")
        XCTAssertEqual(authRepository.lastNewPassword, "newpass456")
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertNotNil(viewModel.successMessage)
    }

    func testChangePasswordSetsErrorMessageOnFailure() async {
        let authRepository = MockAuthRepository(currentUser: nil)
        authRepository.changePasswordError = AppError.unknown("Current password is incorrect.")
        let viewModel = ChangePasswordViewModel(
            localization: LocalizationManager(),
            authRepository: authRepository
        )

        viewModel.currentPassword = "wrongpass"
        viewModel.newPassword = "newpass456"
        viewModel.confirmPassword = "newpass456"

        let success = await viewModel.changePassword()

        XCTAssertFalse(success)
        XCTAssertEqual(authRepository.changePasswordCallCount, 1)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertNil(viewModel.successMessage)
    }

    func testChangePasswordReturnsFalseWhenFormInvalid() async {
        let authRepository = MockAuthRepository(currentUser: nil)
        let viewModel = ChangePasswordViewModel(
            localization: LocalizationManager(),
            authRepository: authRepository
        )

        // confirmPassword doesn't match
        viewModel.currentPassword = "oldpass123"
        viewModel.newPassword = "newpass456"
        viewModel.confirmPassword = "different"

        let success = await viewModel.changePassword()

        XCTAssertFalse(success)
        XCTAssertEqual(authRepository.changePasswordCallCount, 0)
    }

    func testChangePasswordReturnsFalseWhenNewPasswordTooShort() async {
        let authRepository = MockAuthRepository(currentUser: nil)
        let viewModel = ChangePasswordViewModel(
            localization: LocalizationManager(),
            authRepository: authRepository
        )

        viewModel.currentPassword = "oldpass123"
        viewModel.newPassword = "short"
        viewModel.confirmPassword = "short"

        let success = await viewModel.changePassword()

        XCTAssertFalse(success)
        XCTAssertEqual(authRepository.changePasswordCallCount, 0)
    }
}

@MainActor
private final class MockAuthRepository: AuthRepositoryProtocol {
    var currentUser: User?
    var signOutError: Error?
    private(set) var signOutCallCount = 0

    init(currentUser: User?, signOutError: Error? = nil) {
        self.currentUser = currentUser
        self.signOutError = signOutError
    }

    func restoreSession() async throws -> User? {
        return currentUser
    }

    func seedCachedUser(_ user: User) {
        currentUser = user
    }

    func signIn(email: String, password: String) async throws -> User {
        fatalError("Unused in this test")
    }

    func signUp(name: String, email: String, password: String) async throws -> User {
        fatalError("Unused in this test")
    }

    func resetPassword(email: String) async throws {}

    var changePasswordError: Error?
    private(set) var changePasswordCallCount = 0
    private(set) var lastCurrentPassword: String?
    private(set) var lastNewPassword: String?

    func changePassword(currentPassword: String, newPassword: String) async throws {
        changePasswordCallCount += 1
        lastCurrentPassword = currentPassword
        lastNewPassword = newPassword
        if let changePasswordError {
            throw changePasswordError
        }
    }

    func signOut() async throws {
        signOutCallCount += 1
        if let signOutError {
            throw signOutError
        }
    }
}

@MainActor
private final class MockUserRepository: UserRepositoryProtocol {
    private(set) var updatedUsers: [User] = []

    func updateProfile(_ user: User) async throws -> User {
        updatedUsers.append(user)
        return user
    }

    func uploadAvatar(userId: String, imageData: Data) async throws -> String {
        "https://example.com/avatar.jpg"
    }

    func registerPushToken(_ token: String) async throws {}
}
