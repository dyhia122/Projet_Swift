import Foundation

final class SessionManager: @unchecked Sendable {
    static let shared = SessionManager()

    private var sessions: [String: Int64] = [:]
    private let lock = NSLock()

    private init() {}

    func createSession(for userId: Int64) -> String {
        let token = UUID().uuidString
        lock.lock()
        sessions[token] = userId
        lock.unlock()
        return token
    }

    func getUserId(from token: String) -> Int64? {
        lock.lock()
        defer { lock.unlock() }
        return sessions[token]
    }

    func removeSession(token: String) {
        lock.lock()
        sessions.removeValue(forKey: token)
        lock.unlock()
    }
}
