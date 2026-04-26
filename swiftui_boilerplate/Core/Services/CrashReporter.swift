import Foundation

// MARK: - Protocol

protocol CrashReporter: Sendable {
    func log(_ message: String)
    func record(_ error: Error)
    func setUser(id: String)
    func clearUser()
}

// MARK: - No-op default (used when Firebase is not linked)

struct NullCrashReporter: CrashReporter {
    func log(_ message: String) {}
    func record(_ error: Error) {}
    func setUser(id: String) {}
    func clearUser() {}
}
