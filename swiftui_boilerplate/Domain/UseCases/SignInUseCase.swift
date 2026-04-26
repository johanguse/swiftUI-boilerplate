import Foundation

@MainActor
struct SignInUseCase {
    private let repository: any AuthRepositoryProtocol

    init(repository: any AuthRepositoryProtocol) {
        self.repository = repository
    }

    func execute(email: String, password: String) async throws -> User {
        guard email.isValidEmail else { throw AppError.invalidEmail }
        guard password.isNotEmpty else { throw AppError.weakPassword }
        return try await repository.signIn(email: email, password: password)
    }
}
