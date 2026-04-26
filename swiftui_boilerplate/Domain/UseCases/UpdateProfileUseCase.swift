import Foundation

@MainActor
struct UpdateProfileUseCase {
    private let repository: any UserRepositoryProtocol

    init(repository: any UserRepositoryProtocol) {
        self.repository = repository
    }

    func execute(_ user: User) async throws -> User {
        guard user.fullName.isNotEmpty else { throw AppError.emptyName }
        guard user.email.isValidEmail else { throw AppError.invalidEmail }
        return try await repository.updateProfile(user)
    }
}
