import Foundation
import AppKit

// MARK: - Security Recommendation

struct SecurityRecommendation: Identifiable {
    let id: UUID
    let checkName: String
    let severity: Severity
    let title: String
    let description: String
    let fixSteps: [String]

    enum Severity {
        case critical, high, medium, low, info
    }
}

// MARK: - Trend Data Point

struct TrendDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let score: Int
    let passedChecks: Int
    let failedChecks: Int
}

// MARK: - Scheduled Scan

struct ScheduledScan: Identifiable, Codable {
    let id: UUID
    var name: String
    var interval: ScanInterval
    var isEnabled: Bool

    enum ScanInterval: String, Codable, CaseIterable {
        case daily = "Daily"
        case weekly = "Weekly"
        case monthly = "Monthly"
    }
}

// MARK: - Report Generator

struct SecurityReportGenerator {
    static func generateTextReport(_ result: AuditResult) -> String {
        var report = """
        ========================================
        COIN SECURITY AUDIT REPORT
        Generated: \(result.timestamp.formatted())
        ========================================

        OVERALL SCORE: \(result.overallScore)/100

        SUMMARY
        -------
        Total Checks: \(result.checks.count)
        Passed: \(result.checks.filter { $0.status == .pass }.count)
        Failed: \(result.checks.filter { $0.status == .fail }.count)
        Warnings: \(result.checks.filter { $0.status == .warn }.count)

        DETAILED RESULTS
        -----------------
        """

        for check in result.checks {
            let status = check.status == .pass ? "✓ PASS" : (check.status == .fail ? "✗ FAIL" : "⚠ WARN")
            report += """

            [\(status)] \(check.name)
            Description: \(check.description)
            """
        }

        return report
    }

    static func generateHTMLReport(_ result: AuditResult) -> String {
        let scoreColor = scoreColorHex(result.overallScore)
        let scoreLabel = scoreLabel(result.overallScore)

        var checksHTML = ""
        for check in result.checks {
            let statusIcon: String
            let statusColor: String
            switch check.status {
            case .pass:
                statusIcon = "✓"
                statusColor = "#34C759"
            case .fail:
                statusIcon = "✗"
                statusColor = "#FF3B30"
            case .warn:
                statusIcon = "⚠"
                statusColor = "#FF9500"
            case .unknown:
                statusIcon = "?"
                statusColor = "#8E8E93"
            case .running:
                statusIcon = "..."
                statusColor = "#007AFF"
            }

            checksHTML += """
            <tr>
                <td>\(statusIcon)</td>
                <td>\(check.name)</td>
                <td style="color:\(statusColor)">\(check.status.rawValue.capitalized)</td>
            </tr>
            """
        }

        return """
        <!DOCTYPE html>
        <html>
        <head>
            <title>Coin Security Report</title>
            <style>
                body { font-family: -apple-system, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; }
                .score { font-size: 48px; font-weight: bold; color: \(scoreColor); }
                .label { font-size: 14px; color: #666; }
                table { width: 100%; border-collapse: collapse; }
                th, td { padding: 10px; text-align: left; border-bottom: 1px solid #eee; }
                th { background: #f5f5f5; }
            </style>
        </head>
        <body>
            <h1>Coin Security Report</h1>
            <p class="label">Generated: \(result.timestamp.formatted())</p>

            <div style="text-align:center; margin: 30px 0;">
                <div class="score">\(result.overallScore)</div>
                <div class="label">SECURITY SCORE (\(scoreLabel))</div>
            </div>

            <h2>Summary</h2>
            <ul>
                <li>Total Checks: \(result.checks.count)</li>
                <li>Passed: \(result.checks.filter { $0.status == .pass }.count)</li>
                <li>Failed: \(result.checks.filter { $0.status == .fail }.count)</li>
                <li>Warnings: \(result.checks.filter { $0.status == .warn }.count)</li>
            </ul>

            <h2>Detailed Results</h2>
            <table>
                <tr>
                    <th>Status</th>
                    <th>Check</th>
                    <th>Result</th>
                </tr>
                \(checksHTML)
            </table>
        </body>
        </html>
        """
    }

    private static func scoreColorHex(_ score: Int) -> String {
        if score >= 80 { return "#34C759" }
        if score >= 60 { return "#FF9500" }
        return "#FF3B30"
    }

    private static func scoreLabel(_ score: Int) -> String {
        if score >= 80 { return "Good" }
        if score >= 60 { return "Fair" }
        return "Poor"
    }
}

// MARK: - Trend Store

@MainActor
final class TrendStore: ObservableObject {
    static let shared = TrendStore()

    @Published var trendData: [TrendDataPoint] = []

    private let key = "coin_trend_data"

    private init() {
        loadTrend()
    }

    func addDataPoint(score: Int, checks: [SecurityCheck]) {
        let passed = checks.filter { $0.status == .pass }.count
        let failed = checks.filter { $0.status == .fail }.count
        let point = TrendDataPoint(date: Date(), score: score, passedChecks: passed, failedChecks: failed)
        trendData.insert(point, at: 0)
        if trendData.count > 30 {
            trendData = Array(trendData.prefix(30))
        }
        saveTrend()
    }

    private func saveTrend() {
        // Simplified - just use in-memory for now
    }

    private func loadTrend() {
        // Load from UserDefaults if available
    }
}
