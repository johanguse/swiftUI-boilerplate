import Foundation

// MARK: - Protocol

protocol AnalyticsService: Sendable {
    func trackScreen(_ name: String)
    func trackEvent(_ name: String, parameters: [String: Any])
    func trackSignIn(method: String)
    func trackSignUp(method: String)
    func identify(userId: String)
    func reset()
}

extension AnalyticsService {
    func trackEvent(_ name: String) { trackEvent(name, parameters: [:]) }
}

// MARK: - No-op default (used when Firebase is not linked)

struct NullAnalyticsService: AnalyticsService {
    func trackScreen(_ name: String) {}
    func trackEvent(_ name: String, parameters: [String: Any]) {}
    func trackSignIn(method: String) {}
    func trackSignUp(method: String) {}
    func identify(userId: String) {}
    func reset() {}
}
