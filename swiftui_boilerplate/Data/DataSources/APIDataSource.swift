import Foundation

// MARK: - Generic response wrapper

private struct APIDataWrapper<T: Decodable>: Decodable {
    let data: T
}

// MARK: - Auth payload

private struct APIAuthData: Decodable {
    let user: APIUserDTO
    let accessToken: String?
    let refreshToken: String?
}

// MARK: - Upload payload

private struct APIUploadData: Decodable {
    let key: String
    let url: String?
}

// MARK: - Error body

private struct APIErrorBody: Decodable {
    struct ErrorDetail: Decodable {
        let code: String?
        let message: String?
    }
    let error: ErrorDetail?
}

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
        // Hono returns camelCase; convertFromSnakeCase is a no-op for camelCase keys.
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
        let _: EmptyResponse = try await perform("POST", path: path, body: try encode(body))
    }

    func postVoid(_ path: String) async throws {
        let _: EmptyResponse = try await perform("POST", path: path, body: nil)
    }

    /// Upload image data as multipart/form-data to /api/v1/uploads.
    /// Returns the public URL of the uploaded file.
    func uploadFile(_ path: String, imageData: Data, mimeType: String = "image/jpeg") async throws -> String {
        let url = try makeURL(path)
        let boundary = UUID().uuidString
        var body = Data()
        body.append("--\(boundary)\r\n".utf8Data)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"upload.jpg\"\r\n".utf8Data)
        body.append("Content-Type: \(mimeType)\r\n\r\n".utf8Data)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".utf8Data)

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.httpBody = body
        req.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        injectAuth(&req)

        let (data, response) = try await session.data(for: req)
        try validate(response, data: data)
        let wrapper = try decoder.decode(APIDataWrapper<APIUploadData>.self, from: data)
        guard let fileUrl = wrapper.data.url else {
            throw AppError.unknown("Upload succeeded but no public URL returned. Check R2 public base URL configuration.")
        }
        return fileUrl
    }

    // MARK: - Private

    private func perform<T: Decodable>(_ method: String, path: String, body: Data?) async throws -> T {
        let url = try makeURL(path)
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = body
        injectAuth(&req)
        let (data, response) = try await session.data(for: req)
        try validate(response, data: data)
        return try decoder.decode(T.self, from: data)
    }

    private func encode<B: Encodable>(_ value: B) throws -> Data {
        // Hono expects camelCase — do NOT use convertToSnakeCase.
        return try JSONEncoder().encode(value)
    }

    private func makeURL(_ path: String) throws -> URL {
        guard let url = URL(string: APIConfig.baseURL + path) else { throw AppError.networkError }
        return url
    }

    private func injectAuth(_ req: inout URLRequest) {
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
            // Hono error shape: { "error": { "code": "...", "message": "..." } }
            if let err = try? decoder.decode(APIErrorBody.self, from: data),
               let msg = err.error?.message {
                throw AppError.unknown(msg)
            }
            throw AppError.networkError
        }
    }
}

private extension String {
    var utf8Data: Data { Data(utf8) }
}

private struct EmptyResponse: Decodable {}

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

    /// Validates the stored token by fetching the current user. Returns nil if expired or invalid.
    func restoreSession() async throws -> APIUserDTO? {
        guard !TokenManager.shared.isExpired else { return nil }
        do {
            let wrapper: APIDataWrapper<APIUserDTO> = try await client.get(APIConfig.apiPath("/users/me"))
            currentUserDTO = wrapper.data
            return wrapper.data
        } catch {
            return nil
        }
    }

    // MARK: - Auth

    func signIn(email: String, password: String) async throws -> APIUserDTO {
        do {
            let wrapper: APIDataWrapper<APIAuthData> = try await client.post(
                APIConfig.authPath("/login"),
                body: EmailPasswordRequest(email: email, password: password)
            )
            applyAuthData(wrapper.data)
            return wrapper.data.user
        } catch {
            throw mapAuthError(error)
        }
    }

    func signUp(name: String, email: String, password: String) async throws -> APIUserDTO {
        do {
            let wrapper: APIDataWrapper<APIAuthData> = try await client.post(
                APIConfig.authPath("/register"),
                body: SignUpRequest(email: email, password: password, name: name)
            )
            applyAuthData(wrapper.data)
            return wrapper.data.user
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
        do {
            try await client.postVoid(
                APIConfig.authPath("/change-password"),
                body: ChangePasswordRequest(currentPassword: currentPassword, newPassword: newPassword)
            )
        } catch {
            throw mapAuthError(error)
        }
    }

    func signOut() async throws {
        defer {
            currentUserDTO = nil
            TokenManager.shared.clear()
        }
        try await client.postVoid(APIConfig.authPath("/logout"))
    }

    // MARK: - Users

    func updateProfile(_ user: User) async throws -> APIUserDTO {
        do {
            let wrapper: APIDataWrapper<APIUserDTO> = try await client.patch(
                APIConfig.apiPath("/users/me"),
                body: ProfileUpdateRequest(user: user)
            )
            currentUserDTO = wrapper.data
            return wrapper.data
        } catch {
            throw AppError.unknown(error.localizedDescription)
        }
    }

    func registerPushToken(_ token: String) async throws {
        try await client.postVoid(
            APIConfig.apiPath("/users/me/devices"),
            body: PushDeviceRequest(token: token, platform: "ios")
        )
    }

    /// Uploads image data as multipart/form-data, then patches the user's avatar URL.
    func uploadAvatar(userId: String, imageData: Data) async throws -> String {
        let fileUrl = try await client.uploadFile(APIConfig.apiPath("/uploads"), imageData: imageData)
        // Update the user record with the new avatar URL
        let _: APIDataWrapper<APIUserDTO> = try await client.patch(
            APIConfig.apiPath("/users/me"),
            body: AvatarUpdateRequest(avatar: fileUrl)
        )
        return fileUrl
    }

    // MARK: - Private

    private func applyAuthData(_ auth: APIAuthData) {
        let token = auth.accessToken ?? ""
        let expiry = Date().addingTimeInterval(86400 * 7) // 7-day default; JWT embeds real expiry
        TokenManager.shared.save(token: token, refreshToken: auth.refreshToken, expiresAt: expiry)
        currentUserDTO = auth.user
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

// MARK: - Request bodies

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

private struct PushDeviceRequest: Encodable {
    let token: String
    let platform: String
}

private struct ProfileUpdateRequest: Encodable {
    let name: String?
    let avatar: String?

    init(user: User) {
        name = user.fullName.nilIfTrimmedEmpty
        avatar = user.avatarUrl?.nilIfTrimmedEmpty
    }
}

private struct AvatarUpdateRequest: Encodable {
    let avatar: String?
}

private struct ChangePasswordRequest: Encodable {
    let currentPassword: String
    let newPassword: String
}
