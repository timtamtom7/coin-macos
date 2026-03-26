import Foundation
import Network

// MARK: - Coin R14: REST API (port 8774) & Webhooks

final class CoinAPIService: ObservableObject {
    static let shared = CoinAPIService()

    private var listener: NWListener?
    private let port: UInt16 = 8774
    @Published var isRunning = false

    private init() {}

    func start() {
        guard listener == nil else { return }
        do {
            let params = NWParameters.tcp
            params.allowLocalEndpointReuse = true
            listener = try NWListener(using: params, on: NWEndpoint.Port(rawValue: port)!)
            listener?.stateUpdateHandler = { [weak self] state in
                DispatchQueue.main.async { self?.isRunning = state == .ready }
            }
            listener?.newConnectionHandler = { [weak self] conn in
                self?.handle(conn)
            }
            listener?.start(queue: .global())
        } catch { print("CoinAPI error: \(error)") }
    }

    func stop() {
        listener?.cancel(); listener = nil
        DispatchQueue.main.async { self.isRunning = false }
    }

    private func handle(_ conn: NWConnection) {
        conn.start(queue: .global())
        conn.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, _, _ in
            guard let data = data, let req = String(data: data, encoding: .utf8) else { conn.cancel(); return }
            let resp = self?.route(req) ?? CoinHTTPResp(code: 404, body: #"{"error":"Not found"}"#)
            let http = "HTTP/1.1 \(resp.code)\r\nContent-Type: application/json\r\nContent-Length: \(resp.body.count)\r\n\r\n\(resp.body)"
            conn.send(content: http.data(using: .utf8), completion: .contentProcessed { _ in conn.cancel() })
        }
    }

    struct CoinHTTPResp { let code: Int; let body: String }

    private func route(_ req: String) -> CoinHTTPResp {
        let lines = req.split(separator: "\r\n")
        guard let rl = lines.first else { return CoinHTTPResp(code: 404, body: #"{"error":"Not found"}"#) }
        let parts = String(rl).split(separator: " ")
        guard parts.count >= 2 else { return CoinHTTPResp(code: 404, body: #"{"error":"Not found"}"#) }
        let path = String(parts[1])
        guard lines.contains(where: { $0.hasPrefix("X-API-Key:") }) else {
            return CoinHTTPResp(code: 401, body: #"{"error":"Unauthorized"}"#)
        }
        switch path {
        case "/accounts": return CoinHTTPResp(code: 200, body: "[]")
        case "/transactions": return CoinHTTPResp(code: 200, body: "[]")
        case "/budgets": return CoinHTTPResp(code: 200, body: "[]")
        case "/summary": return CoinHTTPResp(code: 200, body: #"{"balance":0}"#)
        case "/cashflow": return CoinHTTPResp(code: 200, body: #"{"predicted":0}"#)
        case "/openapi.json": return CoinHTTPResp(code: 200, body: openAPISpec())
        default: return CoinHTTPResp(code: 404, body: #"{"error":"Not found"}"#)
        }
    }

    private func openAPISpec() -> String {
        return #"{"openapi":"3.0.0","info":{"title":"Coin API","version":"1.0"},"paths":{"/accounts":{"get":{"summary":"List accounts"}},"/transactions":{"get":{"summary":"List transactions"}},"/budgets":{"get":{"summary":"List budgets"}},"/summary":{"get":{"summary":"Financial summary"}},"/cashflow":{"get":{"summary":"Cash flow prediction"}}}}"#
    }
}

// MARK: - Coin R15: iOS Companion Stub

final class CoiniOSService: ObservableObject {
    static let shared = CoiniOSService()
    @Published var accounts: [iOSAccountRef] = []
    @Published var widgetData: [String: Any] = [:]

    struct iOSAccountRef: Identifiable {
        let id = UUID(); let name: String; let balance: Double
    }

    private init() {}
}
