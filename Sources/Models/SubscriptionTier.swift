import Foundation

/// R16: Subscription tiers for Coin
public enum CoinSubscriptionTier: String, Codable, CaseIterable {
    case free = "free"
    case pro = "pro"
    case household = "household"
    
    public var displayName: String {
        switch self { case .free: return "Free"; case .pro: return "Coin Pro"; case .household: return "Coin Household" }
    }
    public var monthlyPrice: Decimal? {
        switch self { case .free: return nil; case .pro: return 4.99; case .household: return 7.99 }
    }
    public var maxPortfolios: Int? {
        switch self { case .free: return 2; case .pro: return nil; case .household: return nil }
    }
    public var supportsWidgets: Bool { self != .free }
    public var supportsShortcuts: Bool { self != .free }
    public var supportsHousehold: Bool { self == .household }
    public var trialDays: Int { self == .free ? 0 : 14 }
}

public struct CoinSubscription: Codable {
    public let tier: CoinSubscriptionTier
    public let status: String
    public let expiresAt: Date?
    public init(tier: CoinSubscriptionTier, status: String = "active", expiresAt: Date? = nil) {
        self.tier = tier; self.status = status; self.expiresAt = expiresAt
    }
}
