import Foundation

@MainActor
struct ForgotPasswordUseCase {
    private let repository: any AuthRepositoryProtocol

    init(repository: any AuthRepositoryProtocol) {
        self.repository = repository
    }

    func execute(email: String) async throws {
        guard email.isValidEmail else { throw AppError.invalidEmail }
        try await repository.resetPassword(email: email)
    }
}
