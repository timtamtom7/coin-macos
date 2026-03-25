import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = AuditViewModel()

    var body: some View {
        VStack(spacing: 0) {
            headerView
            Divider().background(Theme.cardBackground)

            if viewModel.isLoading {
                loadingView
            } else if let result = viewModel.latestResult {
                ScrollView {
                    VStack(spacing: 16) {
                        scoreSection(result)
                        checksSection(result)
                    }
                    .padding(20)
                }
            } else {
                emptyStateView
            }

            Divider().background(Theme.cardBackground)
            footerView
        }
        .frame(minWidth: 580, minHeight: 460)
        .background(Theme.background)
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            Image(systemName: "shield.checkmark.fill")
                .foregroundColor(Theme.accent)
                .font(.title2)

            Text("Coin")
                .font(.title2.bold())
                .foregroundColor(Theme.textPrimary)

            Text("Security Audit")
                .font(.subheadline)
                .foregroundColor(Theme.textSecondary)

            Spacer()

            if let result = viewModel.latestResult {
                Text("Last scan: \(result.timestamp.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
            }

            Button(action: { viewModel.runAudit() }) {
                Image(systemName: "arrow.clockwise")
                    .foregroundColor(Theme.accent)
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isLoading)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }

    // MARK: - Score Section

    private func scoreSection(_ result: AuditResult) -> some View {
        HStack(spacing: 24) {
            ScoreView(score: result.overallScore, size: 140)

            VStack(alignment: .leading, spacing: 8) {
                Text("Security Score")
                    .font(.headline)
                    .foregroundColor(Theme.textPrimary)

                Text(scoreDescription(for: result.overallScore))
                    .font(.subheadline)
                    .foregroundColor(Theme.textSecondary)

                Spacer()

                Text("Based on \(result.checks.count) security checks")
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
            }

            Spacer()

            recommendationsSummary(result.checks)
        }
        .padding(20)
        .background(Theme.cardBackground)
        .cornerRadius(12)
    }

    private func scoreDescription(for score: Int) -> String {
        switch score {
        case 90...100:
            return "Your Mac is well secured. Keep up the good practices!"
        case 70..<90:
            return "Good security posture with some areas to improve."
        case 50..<70:
            return "Moderate risk. Several security settings need attention."
        default:
            return "High risk. Immediate action recommended on marked issues."
        }
    }

    private func recommendationsSummary(_ checks: [SecurityCheck]) -> some View {
        VStack(alignment: .trailing, spacing: 6) {
            let fails = checks.filter { $0.status == .fail }.count
            let warns = checks.filter { $0.status == .warn }.count

            if fails > 0 {
                HStack(spacing: 4) {
                    Text("\(fails)")
                        .foregroundColor(Theme.scoreRed)
                        .font(.subheadline.bold())
                    Text("Critical")
                        .foregroundColor(Theme.textSecondary)
                        .font(.caption)
                }
            }

            if warns > 0 {
                HStack(spacing: 4) {
                    Text("\(warns)")
                        .foregroundColor(Theme.scoreOrange)
                        .font(.subheadline.bold())
                    Text("Warnings")
                        .foregroundColor(Theme.textSecondary)
                        .font(.caption)
                }
            }

            if fails == 0 && warns == 0 {
                HStack(spacing: 4) {
                    Text("All clear")
                        .foregroundColor(Theme.scoreGreen)
                        .font(.caption.bold())
                }
            }
        }
    }

    // MARK: - Checks Section

    private func checksSection(_ result: AuditResult) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Security Checks")
                .font(.headline)
                .foregroundColor(Theme.textPrimary)

            ForEach(result.checks) { check in
                CheckCardView(check: check, onRefresh: viewModel.runAudit)
            }
        }
    }

    // MARK: - Loading

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(Theme.accent)

            Text("Running security audit...")
                .font(.subheadline)
                .foregroundColor(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "shield.slash")
                .font(.system(size: 48))
                .foregroundColor(Theme.textSecondary)

            Text("No Scan Results")
                .font(.headline)
                .foregroundColor(Theme.textPrimary)

            Text("Run your first security audit to see your Mac's security status.")
                .font(.subheadline)
                .foregroundColor(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 300)

            Button(action: { viewModel.runAudit() }) {
                Text("Run Full Audit")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(Theme.accent)
                    .cornerRadius(8)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Footer

    private var footerView: some View {
        HStack {
            Button(action: { viewModel.showHistory.toggle() }) {
                HStack(spacing: 4) {
                    Image(systemName: "clock.arrow.circlepath")
                    Text("History")
                }
                .font(.caption)
                .foregroundColor(Theme.textSecondary)
            }
            .buttonStyle(.plain)

            Spacer()

            Text("Coin v1.0")
                .font(.caption)
                .foregroundColor(Theme.textSecondary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .sheet(isPresented: $viewModel.showHistory) {
            HistoryView()
        }
    }
}

// MARK: - Check Card View

struct CheckCardView: View {
    let check: SecurityCheck
    let onRefresh: () -> Void
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: check.status.iconName)
                    .font(.title2)
                    .foregroundColor(Theme.statusColor(for: check.status))

                VStack(alignment: .leading, spacing: 2) {
                    Text(check.name)
                        .font(.subheadline.bold())
                        .foregroundColor(Theme.textPrimary)

                    Text(check.currentValue)
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                }

                Spacer()

                Text(check.status.rawValue)
                    .font(.caption.bold())
                    .foregroundColor(Theme.statusColor(for: check.status))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Theme.statusColor(for: check.status).opacity(0.15))
                    .cornerRadius(4)

                Button(action: { withAnimation { isExpanded.toggle() } }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(Theme.textSecondary)
                        .font(.caption)
                }
                .buttonStyle(.plain)
            }
            .padding(14)

            if isExpanded {
                Divider().background(Theme.background)
                VStack(alignment: .leading, spacing: 10) {
                    detailRow("What was checked", check.description)
                    detailRow("Current value", check.currentValue)
                    detailRow("Recommended", check.recommendedValue)
                    detailRow("Why it matters", check.whyItMatters)
                }
                .padding(14)
            }
        }
        .background(Theme.cardBackground)
        .cornerRadius(10)
    }

    private func detailRow(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundColor(Theme.textSecondary)
            Text(value)
                .font(.caption)
                .foregroundColor(Theme.textPrimary)
        }
    }
}

// MARK: - History View

struct HistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var history: [AuditResult] = []

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Scan History")
                    .font(.headline)
                    .foregroundColor(Theme.textPrimary)
                Spacer()
                Button("Done") { dismiss() }
                    .foregroundColor(Theme.accent)
            }
            .padding()

            Divider()

            if history.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "clock")
                        .font(.largeTitle)
                        .foregroundColor(Theme.textSecondary)
                    Text("No scan history yet")
                        .foregroundColor(Theme.textSecondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(history) { result in
                    HStack {
                        ScoreView(score: result.overallScore, size: 50)
                        VStack(alignment: .leading) {
                            Text(result.timestamp.formatted(date: .abbreviated, time: .shortened))
                                .font(.subheadline)
                                .foregroundColor(Theme.textPrimary)
                            Text("\(result.checks.filter { $0.status == .pass }.count) passed, \(result.checks.filter { $0.status == .fail }.count) failed")
                                .font(.caption)
                                .foregroundColor(Theme.textSecondary)
                        }
                        Spacer()
                    }
                    .listRowBackground(Theme.cardBackground)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .frame(width: 400, height: 300)
        .background(Theme.background)
        .onAppear {
            history = SettingsStore.shared.loadHistory()
        }
    }
}

#Preview {
    ContentView()
}
