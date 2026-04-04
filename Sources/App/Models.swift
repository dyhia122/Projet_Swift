import Foundation

struct Recipe: Codable, Sendable {
    let id: Int64?
    var title: String
    var ingredients: String
    var missingIngredients: String
    var steps: String
    var category: String
    var rating: Int
    var isCooked: Bool
    var prepTime: Int
}