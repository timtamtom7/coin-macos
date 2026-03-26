import Foundation
import StoreKit

@available(macOS 13.0, *)
public final class CoinSubscriptionManager: ObservableObject {
    public static let shared = CoinSubscriptionManager()
    @Published public private(set) var subscription: CoinSubscription?
    @Published public private(set) var products: [Product] = []
    private init() {}
    public func loadProducts() async {
        do { products = try await Product.products(for: ["com.coin.macos.pro.monthly","com.coin.macos.pro.yearly","com.coin.macos.household.monthly","com.coin.macos.household.yearly"]) }
        catch { print("Failed to load products") }
    }
    public func canAccess(_ feature: CoinFeature) -> Bool {
        guard let sub = subscription else { return false }
        switch feature {
        case .widgets: return sub.tier != .free
        case .shortcuts: return sub.tier != .free
        case .household: return sub.tier == .household
        }
    }
    public func updateStatus() async {
        var found: CoinSubscription = CoinSubscription(tier: .free)
        for await result in Transaction.currentEntitlements {
            do {
                let t = try checkVerified(result)
                if t.productID.contains("household") { found = CoinSubscription(tier: .household, status: t.revocationDate == nil ? "active" : "expired") }
                else if t.productID.contains("pro") { found = CoinSubscription(tier: .pro, status: t.revocationDate == nil ? "active" : "expired") }
            } catch { continue }
        }
        await MainActor.run { self.subscription = found }
    }
    public func restore() async throws { try await AppStore.sync(); await updateStatus() }
    private func checkVerified<T>(_ r: VerificationResult<T>) throws -> T { switch r { case .unverified: throw NSError(domain: "Coin", code: -1); case .verified(let s): return s } }
}
public enum CoinFeature { case widgets, shortcuts, household }
