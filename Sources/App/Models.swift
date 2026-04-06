import Foundation

enum CategorieRecette: String, CaseIterable, Codable, Sendable {
    case italienne = "Italienne"
    case dessert = "Dessert"
    case petitDejeuner = "Petit-déjeuner"
    case salade = "Salade"
    case platPrincipal = "Plat principal"
    case soupe = "Soupe"
    case vegetarien = "Végétarien"
    case rapide = "Rapide"
    case autre = "Autre"
}

struct Recette: Codable, Sendable {
    let id: Int64?
    var titre: String
    var ingredients: String
    var ingredientsManquants: String
    var etapes: String
    var categorie: String
    var note: Int?
    var dejaFaite: Bool
    var tempsPreparation: Int
}
