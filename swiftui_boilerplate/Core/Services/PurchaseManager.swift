import Foundation
import Observation

#if canImport(RevenueCat)
import RevenueCat
#else
import StoreKit
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
    var errorMessage: String?

    // MARK: - Configure (call after sign-in)

    func configure(userId: String?) {
        #if canImport(RevenueCat)
        Task {
            if let userId {
                _ = try? await Purchases.shared.logIn(userId)
            }
            await refreshProStatus()
        }
        #else
        Task { await loadProducts() }
        #endif
    }

    // MARK: - Restore

    func restorePurchases() async {
        isLoadingRestore = true
        defer { isLoadingRestore = false }
        #if canImport(RevenueCat)
        do {
            let info = try await Purchases.shared.restorePurchases()
            isProUser = info.entitlements[RevenueCatConfig.proEntitlementId]?.isActive == true
        } catch {
            errorMessage = error.localizedDescription
        }
        #else
        do {
            try await AppStore.sync()
            await refreshProStatus()
        } catch {
            errorMessage = error.localizedDescription
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
        #else
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result, transaction.revocationDate == nil {
                isProUser = true
                return
            }
        }
        isProUser = false
        #endif
    }

    // MARK: - StoreKit 2 (non-RevenueCat path)

    #if !canImport(RevenueCat)
    private(set) var products: [Product] = []

    func loadProducts() async {
        // Replace these product IDs with your App Store Connect identifiers.
        let ids: Set<String> = ["pro_yearly", "pro_monthly", "pro_weekly"]
        products = (try? await Product.products(for: ids)) ?? []
        await refreshProStatus()
    }

    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            if case .verified(let transaction) = verification {
                await transaction.finish()
                isProUser = true
            }
        case .userCancelled, .pending:
            break
        @unknown default:
            break
        }
    }
    #endif
}
