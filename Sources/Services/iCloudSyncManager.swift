import Foundation

@MainActor
final class CoinSyncManager: ObservableObject {
    static let shared = CoinSyncManager()

    @Published var syncStatus: SyncStatus = .idle
    @Published var lastSynced: Date?

    enum SyncStatus: Equatable {
        case idle
        case syncing
        case synced
        case offline
        case error(String)
    }

    private let store = NSUbiquitousKeyValueStore.default
    private var observers: [NSObjectProtocol] = []

    private init() {
        setupObservers()
    }

    private func setupObservers() {
        let notification = NSUbiquitousKeyValueStore.didChangeExternallyNotification
        let observer = NotificationCenter.default.addObserver(
            forName: notification,
            object: store,
            queue: .main
        ) { [weak self] _ in
            self?.handleExternalChange()
        }
        observers.append(observer)
    }

    // MARK: - Sync Data

    struct SyncPayload: Codable {
        var lastAuditDate: Date?
        var lastScore: Double
        var settings: CoinSettings

        struct CoinSettings: Codable {
            var autoFixEnabled: Bool
            var showNotifications: Bool
        }
    }

    func sync() {
        guard isICloudAvailable else {
            syncStatus = .offline
            return
        }

        syncStatus = .syncing

        do {
            let payload = buildPayload()
            let data = try JSONEncoder().encode(payload)
            store.set(data, forKey: "coin.sync.data")
            store.synchronize()

            syncStatus = .synced
            lastSynced = Date()
        } catch {
            syncStatus = .error(error.localizedDescription)
        }
    }

    func pullFromCloud() {
        guard isICloudAvailable else { return }

        guard let data = store.data(forKey: "coin.sync.data"),
              let payload = try? JSONDecoder().decode(SyncPayload.self, from: data) else {
            return
        }

        applyPayload(payload)
    }

    private func buildPayload() -> SyncPayload {
        let settings = SyncPayload.CoinSettings(
            autoFixEnabled: UserDefaults.standard.bool(forKey: "coin_autoFix"),
            showNotifications: UserDefaults.standard.bool(forKey: "coin_showNotifications")
        )

        return SyncPayload(
            lastAuditDate: CoinState.shared.lastAuditDate,
            lastScore: CoinState.shared.lastScore,
            settings: settings
        )
    }

    private func applyPayload(_ payload: SyncPayload) {
        CoinState.shared.lastAuditDate = payload.lastAuditDate
        CoinState.shared.lastScore = payload.lastScore

        UserDefaults.standard.set(payload.settings.autoFixEnabled, forKey: "coin_autoFix")
        UserDefaults.standard.set(payload.settings.showNotifications, forKey: "coin_showNotifications")
    }

    private func handleExternalChange() {
        pullFromCloud()
        syncStatus = .synced
        lastSynced = Date()
    }

    var isICloudAvailable: Bool {
        FileManager.default.ubiquityIdentityToken != nil
    }

    func syncNow() {
        sync()
    }

    deinit {
        observers.forEach { NotificationCenter.default.removeObserver($0) }
    }
}
