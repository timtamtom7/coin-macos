import Foundation

struct WatchlistItem: Identifiable, Codable {
    let id: UUID
    let coinId: String
    var symbol: String
    var addedAt: Date
}

final class WatchlistManager {
    static let shared = WatchlistManager()

    private let watchlistKey = "coinWatchlist"

    private init() {}

    func addToWatchlist(coinId: String, symbol: String) {
        var items = fetchWatchlist()
        if !items.contains(where: { $0.coinId == coinId }) {
            let item = WatchlistItem(
                id: UUID(),
                coinId: coinId,
                symbol: symbol,
                addedAt: Date()
            )
            items.append(item)
            saveWatchlist(items)
        }
    }

    func removeFromWatchlist(_ coinId: String) {
        var items = fetchWatchlist()
        items.removeAll { $0.coinId == coinId }
        saveWatchlist(items)
    }

    func fetchWatchlist() -> [WatchlistItem] {
        guard let data = UserDefaults.standard.data(forKey: watchlistKey) else { return [] }
        do {
            return try JSONDecoder().decode([WatchlistItem].self, from: data)
        } catch {
            return []
        }
    }

    func isInWatchlist(_ coinId: String) -> Bool {
        fetchWatchlist().contains { $0.coinId == coinId }
    }

    private func saveWatchlist(_ items: [WatchlistItem]) {
        do {
            let data = try JSONEncoder().encode(items)
            UserDefaults.standard.set(data, forKey: watchlistKey)
        } catch {
            print("Failed to save watchlist: \(error)")
        }
    }
}
