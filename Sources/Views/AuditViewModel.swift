import Foundation
import Combine

@MainActor
class AuditViewModel: ObservableObject {
    @Published var latestResult: AuditResult?
    @Published var isLoading = false
    @Published var showHistory = false

    private let checker = SecurityCheckerService.shared
    private let store = SettingsStore.shared

    init() {
        loadLastResult()
    }

    private func loadLastResult() {
        let history = store.loadHistory(limit: 1)
        latestResult = history.first
    }

    func runAudit() {
        guard !isLoading else { return }

        isLoading = true

        Task {
            let result = await checker.runFullAudit()
            store.saveResult(result)
            latestResult = result
            isLoading = false
        }
    }
}
