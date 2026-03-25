import SwiftUI

struct PopoverView: View {
    @StateObject private var viewModel = AuditViewModel()
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            OverviewTab(viewModel: viewModel)
                .tabItem {
                    Label("Overview", systemImage: "shield")
                }
                .tag(0)

            HistoryTab(viewModel: viewModel)
                .tabItem {
                    Label("History", systemImage: "clock")
                }
                .tag(1)

            RecommendationsTab(viewModel: viewModel)
                .tabItem {
                    Label("Tips", systemImage: "lightbulb")
                }
                .tag(2)

            SettingsTab(viewModel: viewModel)
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(3)
        }
        .frame(width: 380, height: 420)
        .background(Theme.background)
    }
}

// MARK: - Overview Tab

struct OverviewTab: View {
    @ObservedObject var viewModel: AuditViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "shield.checkmark.fill")
                    .foregroundColor(Theme.accent)
                Text("Coin")
                    .font(.headline)
                Spacer()
                Button(action: { viewModel.runAudit() }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 12))
                        .foregroundColor(Theme.accent)
                }
                .buttonStyle(.plain)
                .disabled(viewModel.isLoading)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

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
        }
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
}

// MARK: - History Tab

struct HistoryTab: View {
    @ObservedObject var viewModel: AuditViewModel

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Scan History")
                    .font(.headline)
                Spacer()
            }
            .padding(12)

            Divider()

            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.allHistory) { result in
                        historyRow(result)
                    }
                }
                .padding(12)
            }
        }
    }

    private func historyRow(_ result: AuditResult) -> some View {
        HStack(spacing: 12) {
            ScoreView(score: result.overallScore, size: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(Theme.scoreLabel(for: result.overallScore))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Theme.scoreColor(for: result.overallScore))

                Text(result.timestamp.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: 10))
                    .foregroundColor(Theme.textSecondary)
            }

            Spacer()

            Text("\(result.checks.filter { $0.status == .pass }.count)/\(result.checks.count)")
                .font(.system(size: 11))
                .foregroundColor(Theme.textSecondary)
        }
        .padding(12)
        .background(Color(nsColor: NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

// MARK: - Recommendations Tab

struct RecommendationsTab: View {
    @ObservedObject var viewModel: AuditViewModel

    var recommendations: [SecurityRecommendation] {
        guard let result = viewModel.latestResult else { return [] }
        return result.checks.compactMap { check -> SecurityRecommendation? in
            guard check.status == .fail || check.status == .warn else { return nil }
            return SecurityRecommendation(
                id: UUID(),
                checkName: check.name,
                severity: check.status == .fail ? .high : .medium,
                title: check.name,
                description: check.description,
                fixSteps: defaultFixSteps(for: check)
            )
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Security Tips")
                    .font(.headline)
                Spacer()
            }
            .padding(12)

            Divider()

            if recommendations.isEmpty {
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 32))
                        .foregroundColor(Theme.scoreColor(for: 100))
                    Text("All checks passed!")
                        .font(.subheadline)
                        .foregroundColor(Theme.textSecondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(recommendations) { rec in
                            recommendationRow(rec)
                        }
                    }
                    .padding(12)
                }
            }
        }
    }

    private func recommendationRow(_ rec: SecurityRecommendation) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 12))
                    .foregroundColor(rec.severity == .critical ? .red : .yellow)

                Text(rec.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Theme.textPrimary)
            }

            Text(rec.description)
                .font(.system(size: 11))
                .foregroundColor(Theme.textSecondary)

            ForEach(rec.fixSteps, id: \.self) { step in
                HStack(alignment: .top, spacing: 6) {
                    Text("→")
                        .font(.system(size: 10))
                        .foregroundColor(Theme.accent)
                    Text(step)
                        .font(.system(size: 11))
                        .foregroundColor(Theme.textPrimary)
                }
            }
        }
        .padding(12)
        .background(Color(nsColor: NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }

    private func defaultFixSteps(for check: SecurityCheck) -> [String] {
        ["Review the issue in System Settings", "Make necessary changes to improve security"]
    }
}

// MARK: - Settings Tab

struct SettingsTab: View {
    @ObservedObject var viewModel: AuditViewModel
    @State private var showExportSheet = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Export
                VStack(alignment: .leading, spacing: 8) {
                    Text("REPORTS")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(Theme.textSecondary)
                        .tracking(0.05)

                    VStack(spacing: 8) {
                        Button(action: exportReport) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Export Latest Report")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(12)
                    .background(Color(nsColor: NSColor.controlBackgroundColor))
                    .cornerRadius(8)
                }

                // About
                VStack(alignment: .leading, spacing: 8) {
                    Text("ABOUT")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(Theme.textSecondary)
                        .tracking(0.05)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Coin")
                            .font(.system(size: 13, weight: .medium))
                        Text("Security audit tool for macOS")
                            .font(.system(size: 11))
                            .foregroundColor(Theme.textSecondary)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(nsColor: NSColor.controlBackgroundColor))
                    .cornerRadius(8)
                }
            }
            .padding(12)
        }
    }

    private func exportReport() {
        guard let result = viewModel.latestResult else { return }
        let html = SecurityReportGenerator.generateHTMLReport(result)
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("coin_report.html")
        do {
            try html.write(to: fileURL, atomically: true, encoding: .utf8)
            NSWorkspace.shared.selectFile(fileURL.path, inFileViewerRootedAtPath: tempDir.path)
        } catch {
            print("Failed to export report: \(error)")
        }
    }
}
