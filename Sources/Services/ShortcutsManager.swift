import AppIntents
import Foundation

// MARK: - App Shortcuts Provider

struct CoinShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: RunSecurityAuditIntent(),
            phrases: [
                "Run \(.applicationName) security audit",
                "Scan security with \(.applicationName)"
            ],
            shortTitle: "Security Audit",
            systemImageName: "shield"
        )

        AppShortcut(
            intent: GetSecurityScoreIntent(),
            phrases: [
                "Get \(.applicationName) security score",
                "Security score in \(.applicationName)"
            ],
            shortTitle: "Security Score",
            systemImageName: "shield.checkered"
        )
    }
}

// MARK: - Run Security Audit Intent

struct RunSecurityAuditIntent: AppIntent {
    static var title: LocalizedStringResource = "Run Security Audit"
    static var description = IntentDescription("Runs a full security audit with Coin")

    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let score = await CoinState.shared.runAudit()

        let level: String
        if score >= 80 {
            level = "Excellent"
        } else if score >= 60 {
            level = "Good"
        } else if score >= 40 {
            level = "Fair"
        } else {
            level = "Poor"
        }

        return .result(dialog: "Security audit complete. Score: \(Int(score))/100 (\(level))")
    }
}

// MARK: - Get Security Score Intent

struct GetSecurityScoreIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Security Score"
    static var description = IntentDescription("Returns the current security score from Coin")

    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let score = await CoinState.shared.getLastScore()
        let failedChecks = await CoinState.shared.failedCheckCount

        if score == 0 && failedChecks == 0 {
            return .result(dialog: "No security score available. Run an audit first.")
        }

        let level: String
        if score >= 80 {
            level = "Excellent"
        } else if score >= 60 {
            level = "Good"
        } else if score >= 40 {
            level = "Fair"
        } else {
            level = "Poor"
        }

        return .result(dialog: "Security score: \(Int(score))/100 (\(level)). \(failedChecks) failed checks.")
    }
}
