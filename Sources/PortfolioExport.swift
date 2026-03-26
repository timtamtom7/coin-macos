import Foundation

struct CoinExport: Codable {
    let version: String
    let exportDate: Date
    let holdings: [CoinHolding]
    let watchlist: [WatchlistItem]
    let alerts: [PriceAlert]
}

final class CoinExportManager {
    static let shared = CoinExportManager()

    private init() {}

    func exportToJSON() -> Data? {
        let export = CoinExport(
            version: "R10",
            exportDate: Date(),
            holdings: [],
            watchlist: WatchlistManager.shared.fetchWatchlist(),
            alerts: AlertManager.shared.fetchAlerts()
        )

        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            return try encoder.encode(export)
        } catch {
            print("Failed to encode export: \(error)")
            return nil
        }
    }

    func importFrom(_ data: Data) -> Bool {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let export = try decoder.decode(CoinExport.self, from: data)

            for item in export.watchlist {
                WatchlistManager.shared.addToWatchlist(coinId: item.coinId, symbol: item.symbol)
            }

            for alert in export.alerts {
                AlertManager.shared.saveAlert(alert)
            }

            return true
        } catch {
            print("Failed to import: \(error)")
            return false
        }
    }

    func saveExportToFile() -> URL? {
        guard let data = exportToJSON() else { return nil }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let fileName = "Coin-Backup-\(dateFormatter.string(from: Date())).json"

        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(fileName)

        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Failed to write export file: \(error)")
            return nil
        }
    }
}
