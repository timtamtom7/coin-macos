import Foundation
import SQLite

class SettingsStore {
    static let shared = SettingsStore()

    private var db: Connection?
    private let historyTable = Table("scan_history")
    private let idCol = SQLite.Expression<String>("id")
    private let timestampCol = SQLite.Expression<Date>("timestamp")
    private let overallScoreCol = SQLite.Expression<Int>("overall_score")
    private let checksJsonCol = SQLite.Expression<String>("checks_json")

    private init() {
        setupDatabase()
    }

    private func setupDatabase() {
        do {
            let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            let dbDir = appSupport.appendingPathComponent("Coin", isDirectory: true)
            try FileManager.default.createDirectory(at: dbDir, withIntermediateDirectories: true)
            let dbPath = dbDir.appendingPathComponent("coin.sqlite3").path

            db = try Connection(dbPath)
            try createTable()
        } catch {
            print("Database setup error: \(error)")
        }
    }

    private func createTable() throws {
        try db?.run(historyTable.create(ifNotExists: true) { t in
            t.column(idCol, primaryKey: true)
            t.column(timestampCol)
            t.column(overallScoreCol)
            t.column(checksJsonCol)
        })
    }

    func saveResult(_ result: AuditResult) {
        guard let db = db else { return }

        do {
            let encoder = JSONEncoder()
            let checksData = try encoder.encode(result.checks)
            let checksJson = String(data: checksData, encoding: .utf8) ?? "[]"

            let insert = historyTable.insert(
                idCol <- result.id.uuidString,
                timestampCol <- result.timestamp,
                overallScoreCol <- result.overallScore,
                checksJsonCol <- checksJson
            )
            try db.run(insert)
        } catch {
            print("Save error: \(error)")
        }
    }

    func loadHistory(limit: Int = 30) -> [AuditResult] {
        guard let db = db else { return [] }

        var results: [AuditResult] = []
        let decoder = JSONDecoder()

        do {
            let query = historyTable
                .order(timestampCol.desc)
                .limit(limit)

            for row in try db.prepare(query) {
                let checksData = row[checksJsonCol].data(using: .utf8) ?? Data()
                let checks = (try? decoder.decode([SecurityCheck].self, from: checksData)) ?? []

                let result = AuditResult(
                    timestamp: row[timestampCol],
                    overallScore: row[overallScoreCol],
                    checks: checks
                )
                results.append(result)
            }
        } catch {
            print("Load error: \(error)")
        }

        return results
    }

    func clearHistory() {
        guard let db = db else { return }
        do {
            try db.run(historyTable.delete())
        } catch {
            print("Clear error: \(error)")
        }
    }
}
