import Foundation

/// Maps the backend `/auth/session` and auth endpoint `user` object.
/// Handles `id` as either an integer or string (both backends use integers, but serialization may vary).
struct APIUserDTO: Decodable, Sendable {
    let id: String
    let email: String
    let name: String?
    let avatarUrl: String?
    let jobTitle: String?
    let country: String?
    let bio: String?
    let role: String?
    let isVerified: Bool?
    let onboardingCompleted: Bool?

    // `id` can arrive as Int or String depending on backend serialization.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)

        if let intId = try? c.decode(Int.self, forKey: .id) {
            id = String(intId)
        } else {
            id = try c.decode(String.self, forKey: .id)
        }

        email = try c.decode(String.self, forKey: .email)
        name = try c.decodeIfPresent(String.self, forKey: .name)
        avatarUrl = try c.decodeIfPresent(String.self, forKey: .avatarUrl)
        jobTitle = try c.decodeIfPresent(String.self, forKey: .jobTitle)
        country = try c.decodeIfPresent(String.self, forKey: .country)
        bio = try c.decodeIfPresent(String.self, forKey: .bio)
        role = try c.decodeIfPresent(String.self, forKey: .role)
        isVerified = try c.decodeIfPresent(Bool.self, forKey: .isVerified)
        onboardingCompleted = try c.decodeIfPresent(Bool.self, forKey: .onboardingCompleted)
    }

    // Memberwise init for building from a domain User (used by seedCachedUser).
    init(id: String, email: String, name: String?, avatarUrl: String?,
         jobTitle: String?, country: String?, bio: String?) {
        self.id = id
        self.email = email
        self.name = name
        self.avatarUrl = avatarUrl
        self.jobTitle = jobTitle
        self.country = country
        self.bio = bio
        self.role = nil
        self.isVerified = nil
        self.onboardingCompleted = nil
    }

    enum CodingKeys: String, CodingKey {
        case id, email, name, country, bio, role
        case avatarUrl
        case jobTitle
        case isVerified
        case onboardingCompleted
    }

    func toDomain() -> User {
        User(
            id: id,
            fullName: name ?? email,
            email: email,
            avatarSystemName: "person.fill",
            avatarUrl: avatarUrl,
            jobTitle: jobTitle ?? "",
            location: country ?? "",
            bio: bio ?? "",
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
            avatarUrl: avatarUrl,
            jobTitle: jobTitle.nilIfTrimmedEmpty,
            country: location.nilIfTrimmedEmpty,
            bio: bio.nilIfTrimmedEmpty
        )
    }
}
