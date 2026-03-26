import Foundation

// MARK: - Coin R12: Collaboration & Household Finance

/// Household profiles, joint expense tracking, family budget, allowance
final class CoinCollaborationService: ObservableObject {
    static let shared = CoinCollaborationService()

    @Published var households: [Household] = []
    @Published var jointExpenses: [JointExpense] = []
    @Published var allowances: [Allowance] = []
    @Published var guestAccounts: [GuestAccount] = []

    private init() { loadState() }

    // MARK: - Households

    func createHousehold(name: String, ownerId: UUID) -> Household {
        let hh = Household(id: UUID(), name: name, members: [], ownerId: ownerId, sharedBudgets: [], createdAt: Date())
        households.append(hh); saveState(); return hh
    }

    func addMember(to household: UUID, name: String, email: String) {
        guard let idx = households.firstIndex(where: { $0.id == household }) else { return }
        let member = HouseholdMember(id: UUID(), name: name, email: email)
        households[idx].members.append(member); saveState()
    }

    // MARK: - Joint Expenses

    func addJointExpense(amount: Double, paidBy: UUID, splitBetween: [UUID], note: String?) -> JointExpense {
        let expense = JointExpense(id: UUID(), amount: amount, paidBy: paidBy, splitBetween: splitBetween, note: note, date: Date())
        jointExpenses.append(expense); saveState(); return expense
    }

    func settleUp(between member1: UUID, member2: UUID) -> Settlement {
        let settlement = Settlement(id: UUID(), from: member1, to: member2, amount: calculateBalance(from: member1, to: member2), settled: false)
        return settlement
    }

    private func calculateBalance(from: UUID, to: UUID) -> Double {
        // Simplified: compute net balance
        return jointExpenses.filter { $0.paidBy == from && $0.splitBetween.contains(to) }
            .reduce(0) { $0 + $1.amount / Double($1.splitBetween.count) }
    }

    // MARK: - Allowances

    func setAllowance(memberId: UUID, weeklyAmount: Double) -> Allowance {
        let allowance = Allowance(id: UUID(), memberId: memberId, weeklyAmount: weeklyAmount, currentBalance: weeklyAmount, lastReset: Date())
        allowances.append(allowance); saveState(); return allowance
    }

    // MARK: - Guest Access

    func inviteGuest(householdId: UUID, email: String, role: GuestRole) -> GuestAccount {
        let guest = GuestAccount(id: UUID(), householdId: householdId, email: email, role: role, expiresAt: Calendar.current.date(byAdding: .day, value: 30, to: Date()), createdAt: Date())
        guestAccounts.append(guest); saveState(); return guest
    }

    // MARK: - Persistence

    private var stateURL: URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Coin/collaboration.json")
    }

    func saveState() {
        try? FileManager.default.createDirectory(at: stateURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        let state = CoinCollabState(households: households, jointExpenses: jointExpenses, allowances: allowances, guestAccounts: guestAccounts)
        try? JSONEncoder().encode(state).write(to: stateURL)
    }

    func loadState() {
        guard let data = try? Data(contentsOf: stateURL),
              let state = try? JSONDecoder().decode(CoinCollabState.self, from: data) else { return }
        households = state.households; jointExpenses = state.jointExpenses
        allowances = state.allowances; guestAccounts = state.guestAccounts
    }
}

// MARK: - Models

struct Household: Identifiable, Codable {
    let id: UUID; var name: String; var members: [HouseholdMember]; let ownerId: UUID
    var sharedBudgets: [SharedBudget]; let createdAt: Date
}

struct HouseholdMember: Identifiable, Codable {
    let id: UUID; var name: String; var email: String
}

struct SharedBudget: Identifiable, Codable {
    let id: UUID; var name: String; var limit: Double; var spent: Double
}

struct JointExpense: Identifiable, Codable {
    let id: UUID; let amount: Double; let paidBy: UUID; let splitBetween: [UUID]
    var note: String?; let date: Date
}

struct Settlement: Identifiable, Codable {
    let id: UUID; let from: UUID; let to: UUID; let amount: Double; var settled: Bool
}

struct Allowance: Identifiable, Codable {
    let id: UUID; let memberId: UUID; let weeklyAmount: Double
    var currentBalance: Double; var lastReset: Date
}

struct GuestAccount: Identifiable, Codable {
    let id: UUID; let householdId: UUID; var email: String
    var role: GuestRole; var expiresAt: Date?; let createdAt: Date
}

enum GuestRole: String, Codable { case readOnly, contributor }

struct CoinCollabState: Codable {
    var households: [Household]; var jointExpenses: [JointExpense]
    var allowances: [Allowance]; var guestAccounts: [GuestAccount]
}
