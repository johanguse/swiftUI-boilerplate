import Foundation
import Observation

#if canImport(RevenueCat)
import RevenueCat
#endif

/// Manages in-app purchase state and RevenueCat integration.
///
/// Enable by adding the RevenueCat Swift Package and copying
/// RevenueCatConfig.swift.sample → RevenueCatConfig.swift.
/// #if canImport(RevenueCat) activates the real implementation automatically.
@Observable
@MainActor
final class PurchaseManager {

    // MARK: - State

    private(set) var isProUser: Bool = false
    private(set) var isLoadingRestore: Bool = false
    var isPresentingPaywall: Bool = false

    // MARK: - Configure (call after sign-in)

    func configure(userId: String?) {
        #if canImport(RevenueCat)
        Task {
            if let userId {
                _ = try? await Purchases.shared.logIn(userId)
            }
            await refreshProStatus()
        }
        #endif
    }

    // MARK: - Restore

    func restorePurchases() async {
        #if canImport(RevenueCat)
        isLoadingRestore = true
        defer { isLoadingRestore = false }
        if let info = try? await Purchases.shared.restorePurchases() {
            isProUser = info.entitlements[RevenueCatConfig.proEntitlementId]?.isActive == true
        }
        #endif
    }

    // MARK: - Sign out

    func logOut() {
        #if canImport(RevenueCat)
        Task { try? await Purchases.shared.logOut() }
        #endif
        isProUser = false
    }

    // MARK: - Internal

    private func refreshProStatus() async {
        #if canImport(RevenueCat)
        if let info = try? await Purchases.shared.customerInfo() {
            isProUser = info.entitlements[RevenueCatConfig.proEntitlementId]?.isActive == true
        }
        #endif
    }
}
