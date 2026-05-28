import Foundation

@MainActor
struct VerifyEmailCodeUseCase {
    private let repository: any AuthRepositoryProtocol

    init(repository: any AuthRepositoryProtocol) {
        self.repository = repository
    }

    func execute(email: String, code: String) async throws -> User {
        try await repository.verifyEmailCode(email: email, code: code)
    }
}
