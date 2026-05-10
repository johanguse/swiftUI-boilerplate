import Foundation

/// Maps the Cloudflare Hono backend `/api/v1/users/me` response.
/// Shape: { id, name, email, emailVerified, image, createdAt, updatedAt }
struct APIUserDTO: Decodable, Sendable {
    let id: String
    let email: String
    let name: String?
    let image: String?
    let emailVerified: Bool?
    let createdAt: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, email, name, image, createdAt, updatedAt, emailVerified
    }

    func toDomain() -> User {
        User(
            id: id,
            fullName: name ?? email,
            email: email,
            avatarSystemName: "person.fill",
            avatarUrl: image,
            jobTitle: "",
            location: "",
            bio: "",
            followersCount: 0,
            followingCount: 0
        )
    }
}

extension User {
    func toAPIUserDTO() -> APIUserDTO {
        APIUserDTO(
            id: id,
            email: email,
            name: fullName.nilIfTrimmedEmpty,
            image: avatarUrl,
            emailVerified: nil,
            createdAt: nil,
            updatedAt: nil
        )
    }
}
