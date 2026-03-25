import Foundation

struct PriceAlert: Identifiable, Codable {
    let id: UUID
    let coinId: String
    let symbol: String
    var targetPrice: Double
    var condition: AlertCondition
    var isEnabled: Bool
    var triggeredAt: Date?
}

enum AlertCondition: String, Codable {
    case above
    case below
}

final class AlertManager {
    static let shared = AlertManager()

    private let alertsKey = "priceAlerts"

    private init() {}

    func fetchAlerts() -> [PriceAlert] {
        guard let data = UserDefaults.standard.data(forKey: alertsKey) else { return [] }
        do {
            return try JSONDecoder().decode([PriceAlert].self, from: data)
        } catch {
            return []
        }
    }

    func saveAlert(_ alert: PriceAlert) {
        var alerts = fetchAlerts()
        if let index = alerts.firstIndex(where: { $0.id == alert.id }) {
            alerts[index] = alert
        } else {
            alerts.append(alert)
        }
        saveAlerts(alerts)
    }

    func deleteAlert(_ id: UUID) {
        var alerts = fetchAlerts()
        alerts.removeAll { $0.id == id }
        saveAlerts(alerts)
    }

    func checkAlerts(currentPrice: Double, coinId: String) -> [PriceAlert] {
        var alerts = fetchAlerts()
        var triggered: [PriceAlert] = []

        for (index, alert) in alerts.enumerated() where alert.coinId == coinId && alert.isEnabled && alert.triggeredAt == nil {
            let shouldTrigger: Bool
            switch alert.condition {
            case .above:
                shouldTrigger = currentPrice >= alert.targetPrice
            case .below:
                shouldTrigger = currentPrice <= alert.targetPrice
            }

            if shouldTrigger {
                var updated = alert
                updated.triggeredAt = Date()
                alerts[index] = updated
                triggered.append(updated)
            }
        }

        saveAlerts(alerts)
        return triggered
    }

    private func saveAlerts(_ alerts: [PriceAlert]) {
        do {
            let data = try JSONEncoder().encode(alerts)
            UserDefaults.standard.set(data, forKey: alertsKey)
        } catch {
            print("Failed to save alerts: \(error)")
        }
    }
}
