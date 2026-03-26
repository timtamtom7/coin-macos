import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var mainWindow: NSWindow?
    private var eventMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        _ = CoinCollaborationService.shared
        _ = CoinEnterpriseService.shared
        _ = CoiniOSService.shared
        CoinAPIService.shared.start()

        setupStatusItem()
        setupPopover()
        setupMainWindow()
        monitorEvents()

        // Initialize CoinState for shortcuts
        CoinState.shared.configure()

        // Start scheduled scans
        ScheduledScanService.shared.requestNotificationPermission()
        ScheduledScanService.shared.startScheduled()
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "shield.checkmark", accessibilityDescription: "Coin Security")
            button.action = #selector(togglePopover)
            button.target = self
        }
    }

    private func setupPopover() {
        popover = NSPopover()
        popover.contentSize = NSSize(width: 380, height: 320)
        popover.behavior = .transient
        popover.animates = true
        popover.contentViewController = NSHostingController(rootView: PopoverView())
    }

    private func setupMainWindow() {
        let contentView = ContentView()

        mainWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 500),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        mainWindow?.title = "Coin — Security Audit"
        mainWindow?.center()
        mainWindow?.setFrameAutosaveName("CoinMainWindow")
        mainWindow?.contentView = NSHostingView(rootView: contentView)
        mainWindow?.isReleasedWhenClosed = false
    }

    private func monitorEvents() {
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            if let popover = self?.popover, popover.isShown {
                popover.performClose(nil)
            }
        }
    }

    @objc private func togglePopover() {
        guard let button = statusItem.button else { return }

        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }

    @objc func openMainWindow() {
        popover.performClose(nil)
        mainWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }

    func applicationWillTerminate(_ notification: Notification) {
        CoinAPIService.shared.stop()
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}

// MARK: - CoinState

@MainActor
final class CoinState {
    static let shared = CoinState()

    var lastAuditDate: Date?
    var lastScore: Double = 0
    var failedCheckCount: Int = 0

    private var securityChecker: SecurityCheckerService?

    private init() {}

    func configure() {
        // Use SecurityCheckerService.shared
    }

    func runAudit() -> Double {
        // Run the security audit
        // For now, return a placeholder score
        lastAuditDate = Date()
        lastScore = 75.0  // Would be calculated from actual checks
        failedCheckCount = 3  // Would be calculated from actual checks
        return lastScore
    }

    func getLastScore() -> Double {
        return lastScore
    }
}
