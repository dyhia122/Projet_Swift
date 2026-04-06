import Foundation

struct Recette: Codable, Sendable {
    let id: Int64?
    var titre: String
    var ingredients: String
    var ingredientsManquants: String
    var etapes: String
    var categorie: String
    var note: Int
    var dejaFaite: Bool
    var tempsPreparation: Int
}