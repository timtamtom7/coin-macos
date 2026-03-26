import Foundation

class SettingsStore {
    static let shared = SettingsStore()

    private var history: [AuditResult] = []

    private init() {
        loadPersistedHistory()
    }

    private var fileURL: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dbDir = appSupport.appendingPathComponent("Coin", isDirectory: true)
        try? FileManager.default.createDirectory(at: dbDir, withIntermediateDirectories: true)
        return dbDir.appendingPathComponent("scan-history.json")
    }

    func saveResult(_ result: AuditResult) {
        history.removeAll { $0.id == result.id }
        history.insert(result, at: 0)
        persist()
    }

    func loadHistory(limit: Int = 30) -> [AuditResult] {
        Array(history.sorted { $0.timestamp > $1.timestamp }.prefix(limit))
    }

    func clearHistory() {
        history.removeAll()
        persist()
    }

    private func loadPersistedHistory() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([AuditResult].self, from: data) else {
            history = []
            return
        }
        history = decoded
    }

    private func persist() {
        do {
            let data = try JSONEncoder().encode(history)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Failed to persist scan history: \(error)")
        }
    }
}
