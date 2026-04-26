import Foundation

@MainActor
struct SignUpUseCase {
    private let repository: any AuthRepositoryProtocol

    init(repository: any AuthRepositoryProtocol) {
        self.repository = repository
    }

    func execute(name: String, email: String, password: String, confirmPassword: String) async throws -> User {
        guard name.isNotEmpty else { throw AppError.emptyName }
        guard email.isValidEmail else { throw AppError.invalidEmail }
        guard password.isValidPassword else { throw AppError.weakPassword }
        guard password == confirmPassword else { throw AppError.passwordMismatch }
        return try await repository.signUp(name: name, email: email, password: password)
    }
}
