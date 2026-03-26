import Foundation

// MARK: - Coin R13: Enterprise & Business Features

/// Business expense categories, tax export, freelancer tools, multi-currency
final class CoinEnterpriseService: ObservableObject {
    static let shared = CoinEnterpriseService()

    @Published var expenseCategories: [ExpenseCategory] = []
    @Published var invoices: [Invoice] = []
    @Published var mileageLogs: [MileageEntry] = []
    @Published var currencyConfig: CurrencyConfig = CurrencyConfig(baseCurrency: "USD", rates: [:])

    struct ExpenseCategory: Identifiable, Codable {
        let id: UUID; var name: String; var type: CategoryType; var tags: [String]
        enum CategoryType: String, Codable { case personal, businessDeductible, reimbursable }
    }

    struct Invoice: Identifiable, Codable {
        let id: UUID; var clientName: String; var amount: Double; var currency: String
        var status: InvoiceStatus; var date: Date
        enum InvoiceStatus: String, Codable { case pending, paid, overdue }
    }

    struct MileageEntry: Identifiable, Codable {
        let id: UUID; var miles: Double; var purpose: String; var date: Date
    }

    struct CurrencyConfig: Codable {
        var baseCurrency: String; var rates: [String: Double]
    }

    private init() { loadState() }

    // MARK: - Tax Export

    func exportTaxSummary(year: Int) -> TaxSummary {
        return TaxSummary(year: year, totalDeductible: 0, totalReimbursable: 0, byCategory: [:])
    }

    // MARK: - Business Dashboard

    func monthlyPL() -> PLReport {
        return PLReport(revenue: 0, expenses: 0, net: 0, topCategories: [])
    }

    // MARK: - Persistence

    private var stateURL: URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Coin/enterprise.json")
    }

    func saveState() {
        try? FileManager.default.createDirectory(at: stateURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        let state = CoinEnterpriseState(expenseCategories: expenseCategories, invoices: invoices, mileageLogs: mileageLogs, currencyConfig: currencyConfig)
        try? JSONEncoder().encode(state).write(to: stateURL)
    }

    func loadState() {
        guard let data = try? Data(contentsOf: stateURL),
              let state = try? JSONDecoder().decode(CoinEnterpriseState.self, from: data) else { return }
        expenseCategories = state.expenseCategories; invoices = state.invoices
        mileageLogs = state.mileageLogs; currencyConfig = state.currencyConfig
    }
}

struct TaxSummary: Codable {
    let year: Int; let totalDeductible: Double; let totalReimbursable: Double; let byCategory: [String: Double]
}

struct PLReport: Codable {
    let revenue: Double; let expenses: Double; let net: Double; let topCategories: [String]
}

struct CoinEnterpriseState: Codable {
    var expenseCategories: [CoinEnterpriseService.ExpenseCategory]
    var invoices: [CoinEnterpriseService.Invoice]
    var mileageLogs: [CoinEnterpriseService.MileageEntry]
    var currencyConfig: CoinEnterpriseService.CurrencyConfig
}
