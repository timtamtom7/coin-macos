import Foundation
import UserNotifications

/// Scheduled scan service for Coin
/// Runs periodic security audits based on user-configured schedule
final class ScheduledScanService {
    static let shared = ScheduledScanService()

    private var timer: Timer?
    private var isScheduled = false

    enum ScheduleInterval: String, CaseIterable, Identifiable {
        case daily = "Daily"
        case weekly = "Weekly"
        case biweekly = "Biweekly"
        case monthly = "Monthly"
        case manual = "Manual"

        var id: String { rawValue }

        var timeInterval: TimeInterval? {
            switch self {
            case .daily: return 86400
            case .weekly: return 86400 * 7
            case .biweekly: return 86400 * 14
            case .monthly: return 86400 * 30
            case .manual: return nil
            }
        }
    }

    private init() {}

    // MARK: - Schedule

    var currentSchedule: ScheduleInterval {
        get {
            let raw = UserDefaults.standard.string(forKey: "coin_scanSchedule") ?? "manual"
            return ScheduleInterval(rawValue: raw) ?? .manual
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "coin_scanSchedule")
            if newValue != .manual {
                startScheduled()
            } else {
                stopScheduled()
            }
        }
    }

    func startScheduled() {
        guard !isScheduled else { return }

        let interval = currentSchedule.timeInterval
        guard let interval = interval else { return }

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.runScheduledScan()
        }

        isScheduled = true
    }

    func stopScheduled() {
        timer?.invalidate()
        timer = nil
        isScheduled = false
    }

    private func runScheduledScan() {
        Task { @MainActor in
            CoinState.shared.runAudit()
        }
        sendScanCompleteNotification()
    }

    // MARK: - Notifications

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }

    private func sendScanCompleteNotification() {
        guard UserDefaults.standard.bool(forKey: "coin_showNotifications") else { return }

        let content = UNMutableNotificationContent()
        content.title = "Coin Security Scan Complete"
        content.body = "Your scheduled security scan has finished."
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "scheduled-scan",
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }
}
