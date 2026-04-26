import Foundation
import Observation

@Observable
@MainActor
final class OnboardingManager {
    var hasCompleted: Bool {
        didSet { UserDefaults.standard.set(hasCompleted, forKey: "onboarding_completed") }
    }

    init() {
        hasCompleted = UserDefaults.standard.bool(forKey: "onboarding_completed")
    }

    func complete() { hasCompleted = true }

    func reset() { hasCompleted = false }
}
