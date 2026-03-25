import Foundation

actor SecurityCheckerService {
    static let shared = SecurityCheckerService()

    private init() {}

    func runFullAudit() async -> AuditResult {
        async let gatekeeper = checkGatekeeper()
        async let firewall = checkFirewall()
        async let fileVault = checkFileVault()
        async let screenLock = checkScreenLock()
        async let sip = checkSIP()

        let results = await [gatekeeper, firewall, fileVault, screenLock, sip]
        let score = computeScore(checks: results)

        return AuditResult(overallScore: score, checks: results)
    }

    // MARK: - Gatekeeper

    func checkGatekeeper() async -> SecurityCheck {
        var check = SecurityCheck(
            id: "gatekeeper",
            name: "Gatekeeper",
            description: "Gatekeeper ensures only trusted software runs on your Mac.",
            recommendedValue: "Enabled",
            weight: 0.20,
            whyItMatters: "Gatekeeper prevents malware by only allowing apps from the App Store or identified developers."
        )

        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/sbin/spctl")
        task.arguments = ["--status"]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe

        do {
            try task.run()
            task.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""

            if output.contains("Assessment system is enabled") {
                check.status = .pass
                check.currentValue = "Enabled"
            } else if output.contains("disabled") {
                check.status = .fail
                check.currentValue = "Disabled"
            } else {
                check.status = .warn
                check.currentValue = "Unknown"
            }
        } catch {
            check.status = .fail
            check.currentValue = "Error: \(error.localizedDescription)"
        }

        return check
    }

    // MARK: - Firewall

    func checkFirewall() async -> SecurityCheck {
        var check = SecurityCheck(
            id: "firewall",
            name: "Firewall",
            description: "The macOS firewall blocks unauthorized network connections.",
            recommendedValue: "Enabled",
            weight: 0.20,
            whyItMatters: "A firewall prevents remote attacks by blocking unsolicited incoming connections."
        )

        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/libexec/ApplicationFirewall/socketfilterfw")
        task.arguments = ["--getglobalstate"]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe

        do {
            try task.run()
            task.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""

            if output.contains("Enabled") || output.contains("ON") {
                check.status = .pass
                check.currentValue = "On"
            } else if output.contains("Off") || output.contains("Disabled") {
                check.status = .fail
                check.currentValue = "Off"
            } else {
                check.status = .warn
                check.currentValue = "Unknown"
            }
        } catch {
            check.status = .warn
            check.currentValue = "Check unavailable: \(error.localizedDescription)"
        }

        return check
    }

    // MARK: - FileVault

    func checkFileVault() async -> SecurityCheck {
        var check = SecurityCheck(
            id: "filevault",
            name: "FileVault",
            description: "FileVault encrypts your entire disk to protect data if your Mac is lost or stolen.",
            recommendedValue: "On",
            weight: 0.25,
            whyItMatters: "Encryption ensures your data is unreadable to anyone without your credentials."
        )

        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/fdesetup")
        task.arguments = ["status"]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe

        do {
            try task.run()
            task.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""

            if output.contains("FileVault is On") || output.contains("Encryption Complete") {
                check.status = .pass
                check.currentValue = "On"
            } else if output.contains("FileVault is Off") {
                check.status = .fail
                check.currentValue = "Off"
            } else if output.contains("Encryption in progress") || output.contains("Decryption in progress") {
                check.status = .warn
                check.currentValue = output.trimmingCharacters(in: .whitespacesAndNewlines)
            } else {
                check.status = .warn
                check.currentValue = output.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        } catch {
            check.status = .fail
            check.currentValue = "Error: \(error.localizedDescription)"
        }

        return check
    }

    // MARK: - Screen Lock

    func checkScreenLock() async -> SecurityCheck {
        var check = SecurityCheck(
            id: "screenlock",
            name: "Screen Lock",
            description: "Screen lock requires a password after your Mac goes to sleep or the screen saver starts.",
            recommendedValue: "Immediate (0 seconds)",
            weight: 0.20,
            whyItMatters: "Prevents unauthorized access when your Mac is left unattended."
        )

        let lockTimeout = UserDefaults.standard.object(forKey: "com.apple.screensaver.askForPasswordDelay") as? Int ?? -1
        let askForPassword = UserDefaults.standard.bool(forKey: "com.apple.screensaver.askForPassword")

        if askForPassword && lockTimeout <= 0 {
            check.status = .pass
            check.currentValue = "Immediate (\(lockTimeout)s delay)"
        } else if askForPassword && lockTimeout > 0 {
            check.status = .warn
            check.currentValue = "\(lockTimeout)s delay"
        } else {
            check.status = .fail
            check.currentValue = "Disabled"
        }

        return check
    }

    // MARK: - SIP

    func checkSIP() async -> SecurityCheck {
        var check = SecurityCheck(
            id: "sip",
            name: "System Integrity Protection",
            description: "SIP protects critical system files from modification by malicious software.",
            recommendedValue: "Enabled",
            weight: 0.15,
            whyItMatters: "SIP prevents malware from injecting code into system processes."
        )

        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/csrutil")
        task.arguments = ["status"]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe

        do {
            try task.run()
            task.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""

            if output.contains("enabled") || output.contains("Enabled") {
                check.status = .pass
                check.currentValue = "Enabled"
            } else if output.contains("disabled") || output.contains("Disabled") {
                check.status = .fail
                check.currentValue = "Disabled"
            } else {
                check.status = .warn
                check.currentValue = "Unknown"
            }
        } catch {
            check.status = .warn
            check.currentValue = "Check unavailable: \(error.localizedDescription)"
        }

        return check
    }

    // MARK: - Score Calculation

    private func computeScore(checks: [SecurityCheck]) -> Int {
        var weightedSum = 0.0

        for check in checks {
            let score: Double
            switch check.status {
            case .pass: score = 100
            case .warn: score = 60
            case .fail: score = 0
            case .unknown, .running: score = 50
            }
            weightedSum += score * check.weight
        }

        return min(100, max(0, Int(round(weightedSum))))
    }
}
