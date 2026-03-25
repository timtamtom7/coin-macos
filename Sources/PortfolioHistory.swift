import Foundation

struct PortfolioSnapshot: Identifiable, Codable {
    let id: UUID
    let totalValue: Double
    let currency: String
    let timestamp: Date
}

final class PortfolioHistoryManager {
    static let shared = PortfolioHistoryManager()

    private let historyKey = "portfolioHistory"
    private let maxEntries = 365

    private init() {}

    func recordSnapshot(totalValue: Double, currency: String = "USD") {
        let snapshot = PortfolioSnapshot(
            id: UUID(),
            totalValue: totalValue,
            currency: currency,
            timestamp: Date()
        )

        var history = fetchHistory()
        history.append(snapshot)

        if history.count > maxEntries {
            history = Array(history.suffix(maxEntries))
        }

        saveHistory(history)
    }

    func fetchHistory() -> [PortfolioSnapshot] {
        guard let data = UserDefaults.standard.data(forKey: historyKey) else { return [] }
        do {
            return try JSONDecoder().decode([PortfolioSnapshot].self, from: data)
        } catch {
            return []
        }
    }

    func getHistory(days: Int = 30) -> [PortfolioSnapshot] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: Date())!
        return fetchHistory().filter { $0.timestamp >= cutoff }
    }

    func getPerformance() -> (change: Double, percentChange: Double) {
        let history = getHistory(days: 30)
        guard history.count >= 2 else { return (0, 0) }

        let first = history.first!.totalValue
        let last = history.last!.totalValue
        let change = last - first
        let percentChange = first > 0 ? (change / first) * 100 : 0

        return (change, percentChange)
    }

    private func saveHistory(_ history: [PortfolioSnapshot]) {
        do {
            let data = try JSONEncoder().encode(history)
            UserDefaults.standard.set(data, forKey: historyKey)
        } catch {
            print("Failed to save portfolio history: \(error)")
        }
    }
}
