import Foundation

enum CheckStatus: String, Codable {
    case pass = "Pass"
    case warn = "Warn"
    case fail = "Fail"
    case unknown = "Unknown"
    case running = "Running"

    var iconName: String {
        switch self {
        case .pass: return "checkmark.shield.fill"
        case .warn: return "exclamationmark.shield.fill"
        case .fail: return "xmark.shield.fill"
        case .unknown: return "questionmark.circle"
        case .running: return "arrow.triangle.2.circlepath"
        }
    }
}

struct SecurityCheck: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    var status: CheckStatus
    var currentValue: String
    let recommendedValue: String
    let weight: Double
    let whyItMatters: String
    var canAutoFix: Bool

    init(
        id: String,
        name: String,
        description: String,
        status: CheckStatus = .unknown,
        currentValue: String = "—",
        recommendedValue: String,
        weight: Double,
        whyItMatters: String,
        canAutoFix: Bool = false
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.status = status
        self.currentValue = currentValue
        self.recommendedValue = recommendedValue
        self.weight = weight
        self.whyItMatters = whyItMatters
        self.canAutoFix = canAutoFix
    }
}

struct AuditResult: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let overallScore: Int
    let checks: [SecurityCheck]

    init(timestamp: Date = Date(), overallScore: Int, checks: [SecurityCheck]) {
        self.id = UUID()
        self.timestamp = timestamp
        self.overallScore = overallScore
        self.checks = checks
    }
}

struct ScanHistory: Codable {
    let results: [AuditResult]
}
