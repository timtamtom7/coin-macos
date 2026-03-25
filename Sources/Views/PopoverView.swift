import SwiftUI

struct PopoverView: View {
    @StateObject private var viewModel = AuditViewModel()

    var body: some View {
        VStack(spacing: 0) {
            header

            Divider()

            if viewModel.isLoading {
                loadingView
            } else if let result = viewModel.latestResult {
                ScrollView {
                    VStack(spacing: 12) {
                        scoreRow(result)
                        Divider()
                        checksSummary(result.checks)
                    }
                    .padding(16)
                }
            } else {
                emptyView
            }

            Divider()

            footer
        }
        .frame(width: 380, height: 320)
        .background(Theme.background)
    }

    private var header: some View {
        HStack {
            Image(systemName: "shield.checkmark.fill")
                .foregroundColor(Theme.accent)
            Text("Coin")
                .font(.headline)
                .foregroundColor(Theme.textPrimary)
            Spacer()
            Text("Security")
                .font(.caption)
                .foregroundColor(Theme.textSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private func scoreRow(_ result: AuditResult) -> some View {
        HStack(spacing: 16) {
            ScoreView(score: result.overallScore, size: 80)

            VStack(alignment: .leading, spacing: 4) {
                Text("Security Score")
                    .font(.subheadline)
                    .foregroundColor(Theme.textSecondary)

                Text(Theme.scoreLabel(for: result.overallScore))
                    .font(.title2.bold())
                    .foregroundColor(Theme.scoreColor(for: result.overallScore))

                Text(result.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .foregroundColor(Theme.textSecondary)
            }

            Spacer()
        }
    }

    private func checksSummary(_ checks: [SecurityCheck]) -> some View {
        VStack(spacing: 8) {
            ForEach(checks) { check in
                HStack(spacing: 8) {
                    Image(systemName: check.status.iconName)
                        .font(.caption)
                        .foregroundColor(Theme.statusColor(for: check.status))
                        .frame(width: 16)

                    Text(check.name)
                        .font(.caption)
                        .foregroundColor(Theme.textPrimary)

                    Spacer()

                    Text(check.status.rawValue)
                        .font(.caption2)
                        .foregroundColor(Theme.statusColor(for: check.status))
                }
            }
        }
    }

    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
                .tint(Theme.accent)
            Text("Scanning...")
                .font(.caption)
                .foregroundColor(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Text("Run your first scan")
                .font(.subheadline)
                .foregroundColor(Theme.textSecondary)

            Button("Run Audit") {
                viewModel.runAudit()
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.accent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var footer: some View {
        HStack {
            Button("Open Coin") {
                if let appDelegate = NSApp.delegate as? AppDelegate {
                    appDelegate.openMainWindow()
                }
            }
            .font(.caption)
            .foregroundColor(Theme.accent)

            Spacer()

            Button(action: { viewModel.runAudit() }) {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.clockwise")
                    Text("Refresh")
                }
                .font(.caption)
                .foregroundColor(Theme.accent)
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isLoading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}
