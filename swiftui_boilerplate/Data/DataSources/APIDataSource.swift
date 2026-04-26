import Foundation

// MARK: - APIClient

/// URLSession-based HTTP client. Injects the Bearer token on every request.
final class APIClient {

    static let shared = APIClient()
    private init() {}

    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        return URLSession(configuration: config)
    }()

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        let fmt = ISO8601DateFormatter()
        d.dateDecodingStrategy = .custom { decoder in
            let c = try decoder.singleValueContainer()
            let s = try c.decode(String.self)
            for opts: ISO8601DateFormatter.Options in [
                [.withInternetDateTime, .withFractionalSeconds],
                [.withInternetDateTime]
            ] {
                fmt.formatOptions = opts
                if let date = fmt.date(from: s) { return date }
            }
            throw DecodingError.dataCorruptedError(in: c, debugDescription: "Bad date: \(s)")
        }
        return d
    }()

    func get<T: Decodable>(_ path: String) async throws -> T {
        try await perform("GET", path: path, body: nil)
    }

    func post<B: Encodable, T: Decodable>(_ path: String, body: B) async throws -> T {
        try await perform("POST", path: path, body: try encode(body))
    }

    func patch<B: Encodable, T: Decodable>(_ path: String, body: B) async throws -> T {
        try await perform("PATCH", path: path, body: try encode(body))
    }

    func postVoid<B: Encodable>(_ path: String, body: B) async throws {
        let _: APIEmptyResponse = try await perform("POST", path: path, body: try encode(body))
    }

    func postVoid(_ path: String) async throws {
        let _: APIEmptyResponse = try await perform("POST", path: path, body: nil)
    }

    func uploadAvatar(_ path: String, imageData: Data) async throws -> String {
        let url = try makeURL(path)
        let boundary = UUID().uuidString
        var body = Data()
        body.append("--\(boundary)\r\n".utf8Data)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"avatar.jpg\"\r\n".utf8Data)
        body.append("Content-Type: image/jpeg\r\n\r\n".utf8Data)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".utf8Data)

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.httpBody = body
        req.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        inject(&req)

        let (data, response) = try await session.data(for: req)
        try validate(response, data: data)
        return try decoder.decode(AvatarUploadResponse.self, from: data).url
    }

    // MARK: - Private

    private func perform<T: Decodable>(_ method: String, path: String, body: Data?) async throws -> T {
        let url = try makeURL(path)
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = body
        inject(&req)
        let (data, response) = try await session.data(for: req)
        try validate(response, data: data)
        return try decoder.decode(T.self, from: data)
    }

    private func encode<B: Encodable>(_ value: B) throws -> Data {
        let enc = JSONEncoder()
        enc.keyEncodingStrategy = .convertToSnakeCase
        return try enc.encode(value)
    }

    private func makeURL(_ path: String) throws -> URL {
        guard let url = URL(string: APIConfig.baseURL + path) else { throw AppError.networkError }
        return url
    }

    private func inject(_ req: inout URLRequest) {
        if let token = TokenManager.shared.token {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
    }

    private func validate(_ response: URLResponse, data: Data) throws {
        guard let http = response as? HTTPURLResponse else { throw AppError.networkError }
        switch http.statusCode {
        case 200...299: return
        case 401: throw AppError.invalidCredentials
        case 404: throw AppError.userNotFound
        default:
            if let err = try? decoder.decode(APIErrorBody.self, from: data),
               let msg = err.errorMessage {
                throw AppError.unknown(msg)
            }
            throw AppError.networkError
        }
    }
}

private extension String {
    var utf8Data: Data { Data(utf8) }
}

private struct APIEmptyResponse: Decodable {}
private struct AvatarUploadResponse: Decodable { let url: String }
// Handles three shapes the backend can return:
//   { "detail": "string" }
//   { "detail": { "error": "CODE", "message": "string" } }
//   { "detail": [ { "msg": "string", ... } ] }  (FastAPI validation errors)
private struct APIErrorBody: Decodable {
    let errorMessage: String?

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: Keys.self)
        if let s = try? c.decode(String.self, forKey: .detail) {
            errorMessage = s
        } else if let obj = try? c.decode(DetailObject.self, forKey: .detail) {
            errorMessage = obj.message ?? obj.error
        } else if let arr = try? c.decode([DetailItem].self, forKey: .detail) {
            errorMessage = arr.first?.msg
        } else if let msg = try? c.decode(String.self, forKey: .message) {
            errorMessage = msg
        } else {
            errorMessage = nil
        }
    }

    enum Keys: String, CodingKey { case detail, message }
    private struct DetailObject: Decodable { let message: String?; let error: String? }
    private struct DetailItem: Decodable { let msg: String? }
}

// MARK: - APIDataSource

/// Single data source for all backend API operations.
/// Shared between `APIAuthRepository` and `APIUserRepository`.
@MainActor
final class APIDataSource {

    private let client: APIClient
    private(set) var currentUserDTO: APIUserDTO?

    init(client: APIClient = .shared) {
        self.client = client
    }

    func setCurrentUser(_ dto: APIUserDTO) {
        currentUserDTO = dto
    }

    // MARK: - Session

    /// Validates the stored token against the server. Returns nil if expired or invalid.
    func restoreSession() async throws -> APIUserDTO? {
        guard !TokenManager.shared.isExpired else { return nil }
        do {
            let response: APISessionResponse = try await client.get(APIConfig.authPath("/session"))
            applySession(response.session, user: response.user)
            return response.user
        } catch {
            return nil
        }
    }

    // MARK: - Auth

    func signIn(email: String, password: String) async throws -> APIUserDTO {
        do {
            let response: APIAuthResponse = try await client.post(
                APIConfig.authPath("/sign-in/email"),
                body: EmailPasswordRequest(email: email, password: password)
            )
            applyAuthResponse(response)
            return response.user
        } catch {
            throw mapAuthError(error)
        }
    }

    func signUp(name: String, email: String, password: String) async throws -> APIUserDTO {
        do {
            let response: APIAuthResponse = try await client.post(
                APIConfig.authPath("/sign-up/email"),
                body: SignUpRequest(email: email, password: password, name: name)
            )
            applyAuthResponse(response)
            return response.user
        } catch let e as AppError {
            throw e
        } catch {
            throw mapAuthError(error)
        }
    }

    func resetPassword(email: String) async throws {
        try await client.postVoid(
            APIConfig.authPath("/forgot-password"),
            body: EmailRequest(email: email)
        )
    }

    func changePassword(currentPassword: String, newPassword: String) async throws {
        try await client.postVoid(
            APIConfig.apiPath("/users/me/change-password"),
            body: ChangePasswordRequest(currentPassword: currentPassword, newPassword: newPassword)
        )
    }

    func signOut() async throws {
        defer {
            currentUserDTO = nil
            TokenManager.shared.clear()
        }
        try await client.postVoid(APIConfig.authPath("/sign-out"))
    }

    // MARK: - Users

    func fetchUsers(limit: Int = 20, offset: Int = 0) async throws -> [APIUserDTO] {
        do {
            let path = APIConfig.apiPath("/users?limit=\(limit)&offset=\(offset)")
            let response: APIUsersListResponse = try await client.get(path)
            return response.users
        } catch {
            throw AppError.networkError
        }
    }

    func updateProfile(_ user: User) async throws -> APIUserDTO {
        do {
            let updated: APIUserDTO = try await client.patch(
                APIConfig.apiPath("/users/me"),
                body: ProfileUpdateRequest(user: user)
            )
            currentUserDTO = updated
            return updated
        } catch {
            throw AppError.unknown(error.localizedDescription)
        }
    }

    func registerPushToken(_ token: String) async throws {
        try await client.postVoid(
            APIConfig.apiPath("/users/me/push-token"),
            body: PushTokenRequest(token: token, platform: "apns")
        )
    }

    /// Uploads image data as multipart/form-data. Backend must expose POST /users/me/avatar.
    func uploadAvatar(userId: String, imageData: Data) async throws -> String {
        try await client.uploadAvatar(APIConfig.apiPath("/users/me/avatar"), imageData: imageData)
    }

    // MARK: - Private

    private func applyAuthResponse(_ response: APIAuthResponse) {
        let token = response.session?.token ?? response.accessToken ?? ""
        let expiry = response.session?.expiresAt ?? Date().addingTimeInterval(3600)
        TokenManager.shared.save(token: token, expiresAt: expiry)
        currentUserDTO = response.user
    }

    private func applySession(_ session: APISessionDTO, user: APIUserDTO) {
        TokenManager.shared.save(token: session.token, expiresAt: session.expiresAt)
        currentUserDTO = user
    }

    private func mapAuthError(_ error: Error) -> AppError {
        if let appError = error as? AppError { return appError }
        let msg = error.localizedDescription.lowercased()
        if msg.contains("invalid") || msg.contains("credential") || msg.contains("unauthorized") {
            return .invalidCredentials
        }
        return .unknown(error.localizedDescription)
    }
}

// MARK: - Request bodies (private to this file)

private struct EmailPasswordRequest: Encodable {
    let email: String
    let password: String
}

private struct SignUpRequest: Encodable {
    let email: String
    let password: String
    let name: String?
}

private struct EmailRequest: Encodable {
    let email: String
}

private struct ChangePasswordRequest: Encodable {
    let currentPassword: String
    let newPassword: String
}

private struct PushTokenRequest: Encodable {
    let token: String
    let platform: String
}

private struct ProfileUpdateRequest: Encodable {
    let name: String
    let email: String
    let avatarUrl: String?
    let jobTitle: String?
    let bio: String?
    let country: String?

    init(user: User) {
        name = user.fullName.trimmed
        email = user.email.trimmed
        avatarUrl = user.avatarUrl?.nilIfTrimmedEmpty
        jobTitle = user.jobTitle.nilIfTrimmedEmpty
        bio = user.bio.nilIfTrimmedEmpty
        country = user.location.nilIfTrimmedEmpty
    }
}

// MARK: - Shared response types (internal — used by repositories)

struct APIUsersListResponse: Decodable {
    let users: [APIUserDTO]
}

struct APISessionResponse: Decodable {
    let user: APIUserDTO
    let session: APISessionDTO
}

struct APIAuthResponse: Decodable {
    let user: APIUserDTO
    let session: APISessionDTO?
    let accessToken: String?
}

struct APISessionDTO: Decodable {
    let token: String
    let expiresAt: Date
}
