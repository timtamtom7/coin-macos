import Foundation

// MARK: - Coin R12-R15 Models

struct CoinPortfolio: Identifiable, Codable {
    let id: UUID
    var name: String
    var holdings: [CoinHolding]
    var totalValue: Double
    var totalCost: Double
    var totalProfitLoss: Double
    var profitLossPercent: Double
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        holdings: [CoinHolding] = [],
        totalValue: Double = 0,
        totalCost: Double = 0,
        totalProfitLoss: Double = 0,
        profitLossPercent: Double = 0,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.holdings = holdings
        self.totalValue = totalValue
        self.totalCost = totalCost
        self.totalProfitLoss = totalProfitLoss
        self.profitLossPercent = profitLossPercent
        self.createdAt = createdAt
    }
}

struct CoinHolding: Identifiable, Codable {
    let id: UUID
    var coinId: String
    var symbol: String
    var name: String
    var amount: Double
    var averageCost: Double
    var currentPrice: Double
    var priceAtPurchase: Double

    var value: Double { amount * currentPrice }
    var cost: Double { amount * averageCost }
    var profitLoss: Double { value - cost }
    var profitLossPercent: Double { cost > 0 ? (profitLoss / cost) * 100 : 0 }

    init(
        id: UUID = UUID(),
        coinId: String,
        symbol: String,
        name: String,
        amount: Double,
        averageCost: Double = 0,
        currentPrice: Double = 0,
        priceAtPurchase: Double = 0
    ) {
        self.id = id
        self.coinId = coinId
        self.symbol = symbol
        self.name = name
        self.amount = amount
        self.averageCost = averageCost
        self.currentPrice = currentPrice
        self.priceAtPurchase = priceAtPurchase
    }
}

struct CoinAlert: Identifiable, Codable {
    let id: UUID
    var coinId: String
    var symbol: String
    var alertType: AlertType
    var targetPrice: Double
    var isEnabled: Bool
    var triggeredAt: Date?
    var createdAt: Date

    enum AlertType: String, Codable {
        case abovePrice
        case belowPrice
        case percentChange
        case volume
    }

    init(
        id: UUID = UUID(),
        coinId: String,
        symbol: String,
        alertType: AlertType,
        targetPrice: Double,
        isEnabled: Bool = true,
        triggeredAt: Date? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.coinId = coinId
        self.symbol = symbol
        self.alertType = alertType
        self.targetPrice = targetPrice
        self.isEnabled = isEnabled
        self.triggeredAt = triggeredAt
        self.createdAt = createdAt
    }
}

struct PortfolioSnapshot: Identifiable, Codable {
    let id: UUID
    var date: Date
    var totalValue: Double
    var holdings: [CoinHolding]

    init(id: UUID = UUID(), date: Date = Date(), totalValue: Double = 0, holdings: [CoinHolding] = []) {
        self.id = id
        self.date = date
        self.totalValue = totalValue
        self.holdings = holdings
    }
}

struct TaxReport: Identifiable, Codable {
    let id: UUID
    var year: Int
    var transactions: [TaxTransaction]
    var capitalGains: Double
    var capitalLosses: Double
    var netGains: Double
    var generatedAt: Date

    init(
        id: UUID = UUID(),
        year: Int,
        transactions: [TaxTransaction] = [],
        capitalGains: Double = 0,
        capitalLosses: Double = 0,
        netGains: Double = 0,
        generatedAt: Date = Date()
    ) {
        self.id = id
        self.year = year
        self.transactions = transactions
        self.capitalGains = capitalGains
        self.capitalLosses = capitalLosses
        self.netGains = netGains
        self.generatedAt = generatedAt
    }
}

struct TaxTransaction: Identifiable, Codable {
    let id: UUID
    var coinId: String
    var symbol: String
    var transactionType: TransactionType
    var amount: Double
    var price: Double
    var date: Date
    var proceeds: Double
    var costBasis: Double
    var gainLoss: Double

    enum TransactionType: String, Codable {
        case buy
        case sell
        case transfer
        case reward
    }

    init(
        id: UUID = UUID(),
        coinId: String,
        symbol: String,
        transactionType: TransactionType,
        amount: Double,
        price: Double,
        date: Date,
        proceeds: Double = 0,
        costBasis: Double = 0,
        gainLoss: Double = 0
    ) {
        self.id = id
        self.coinId = coinId
        self.symbol = symbol
        self.transactionType = transactionType
        self.amount = amount
        self.price = price
        self.date = date
        self.proceeds = proceeds
        self.costBasis = costBasis
        self.gainLoss = gainLoss
    }
}

struct CoinWatchlist: Identifiable, Codable {
    let id: UUID
    var name: String
    var coinIds: [String]
    var createdAt: Date

    init(id: UUID = UUID(), name: String, coinIds: [String] = [], createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.coinIds = coinIds
        self.createdAt = createdAt
    }
}
