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

    func testSupabaseProfileUpdateDTOEncodesOnlyEditableFields() throws {
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

        let data = try JSONEncoder().encode(user.toSupabaseProfileUpdateDTO())
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])

        XCTAssertEqual(Set(json.keys), ["full_name", "email", "avatar_url", "job_title", "location", "bio"])
        XCTAssertEqual(json["full_name"] as? String, "Jane Doe")
        XCTAssertEqual(json["email"] as? String, "jane@example.com")
        XCTAssertTrue(json["avatar_url"] is NSNull)
        XCTAssertTrue(json["job_title"] is NSNull)
        XCTAssertTrue(json["location"] is NSNull)
        XCTAssertTrue(json["bio"] is NSNull)
        XCTAssertNil(json["followers_count"])
        XCTAssertNil(json["following_count"])
        XCTAssertNil(json["id"])
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

    func fetchUsers(limit: Int, offset: Int) async throws -> [User] {
        return []
    }

    func updateProfile(_ user: User) async throws -> User {
        updatedUsers.append(user)
        return user
    }

    func uploadAvatar(userId: String, imageData: Data) async throws -> String {
        "https://example.com/avatar.jpg"
    }
}
