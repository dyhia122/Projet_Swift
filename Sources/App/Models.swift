import Foundation

struct Recipe: Codable, Sendable {
    let id: Int64?
    var title: String
    var ingredients: String
    var steps: String
    var category: String
}
