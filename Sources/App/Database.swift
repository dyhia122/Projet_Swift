import Foundation
@preconcurrency import SQLite

// Fix Sendable issue
extension Connection: @unchecked @retroactive Sendable {}

struct Database {
    static let recettes = Table("recettes")

    static let id = Expression<Int64>("id")
    static let titre = Expression<String>("titre")
    static let ingredients = Expression<String>("ingredients")
    static let ingredientsManquants = Expression<String>("ingredients_manquants")
    static let etapes = Expression<String>("etapes")
    static let categorie = Expression<String>("categorie")
    static let note = Expression<Int>("note")
    static let dejaFaite = Expression<Bool>("deja_faite")
    static let tempsPreparation = Expression<Int>("temps_preparation")

    static func setup() throws -> Connection {
        let db = try Connection("db.sqlite3")

        try db.run(
            recettes.create(ifNotExists: true) { t in
                t.column(id, primaryKey: .autoincrement)
                t.column(titre)
                t.column(ingredients)
                t.column(ingredientsManquants)
                t.column(etapes)
                t.column(categorie)
                t.column(note)
                t.column(dejaFaite)
                t.column(tempsPreparation)
            }
        )

        return db
    }

    static func seedInitialRecipes(db: Connection) throws {
        let count = try db.scalar(recettes.count)

        if count == 0 {
            let recettesExemple = [
                Recette(
                    id: nil,
                    titre: "Pâtes Carbonara",
                    ingredients: "Pâtes, lardons, œufs, parmesan, poivre",
                    ingredientsManquants: "Parmesan",
                    etapes:
                        "1. Faire cuire les pâtes.\n2. Cuire les lardons.\n3. Mélanger les œufs et le parmesan.\n4. Assembler le tout.",
                    categorie: "Italienne",
                    note: 4,
                    dejaFaite: true,
                    tempsPreparation: 20
                ),
                Recette(
                    id: nil,
                    titre: "Pancakes maison",
                    ingredients: "Farine, lait, œufs, sucre, beurre",
                    ingredientsManquants: "",
                    etapes:
                        "1. Mélanger tous les ingrédients.\n2. Laisser reposer 10 minutes.\n3. Cuire à la poêle.",
                    categorie: "Petit-déjeuner",
                    note: 5,
                    dejaFaite: false,
                    tempsPreparation: 15
                ),
                Recette(
                    id: nil,
                    titre: "Salade César",
                    ingredients: "Salade, poulet, croûtons, parmesan, sauce César",
                    ingredientsManquants: "Croûtons",
                    etapes:
                        "1. Couper le poulet.\n2. Mélanger avec la salade.\n3. Ajouter les croûtons, parmesan et sauce.",
                    categorie: "Salade",
                    note: 3,
                    dejaFaite: true,
                    tempsPreparation: 12
                ),
                Recette(
                    id: nil,
                    titre: "Brownies chocolat",
                    ingredients: "Chocolat noir, beurre, sucre, œufs, farine",
                    ingredientsManquants: "Chocolat noir",
                    etapes:
                        "1. Faire fondre le chocolat et le beurre.\n2. Ajouter sucre, œufs et farine.\n3. Cuire au four.",
                    categorie: "Dessert",
                    note: 5,
                    dejaFaite: false,
                    tempsPreparation: 35
                ),
            ]

            for recette in recettesExemple {
                try ajouterRecette(db: db, recette: recette)
            }
        }
    }

    static func fetchAllRecipes(db: Connection, search query: String? = nil) throws -> [Recette] {
        var tableQuery = recettes

        if let query, !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            tableQuery = tableQuery.filter(
                titre.like("%\(query)%") || categorie.like("%\(query)%")
                    || ingredients.like("%\(query)%")
            )
        }

        return try db.prepare(tableQuery.order(titre.asc)).map { row in
            Recette(
                id: row[id],
                titre: row[titre],
                ingredients: row[ingredients],
                ingredientsManquants: row[ingredientsManquants],
                etapes: row[etapes],
                categorie: row[categorie],
                note: row[note],
                dejaFaite: row[dejaFaite],
                tempsPreparation: row[tempsPreparation]
            )
        }
    }

    static func fetchRecipeById(db: Connection, recipeId: Int64) throws -> Recette? {
        let recette = recettes.filter(id == recipeId)

        guard let row = try db.pluck(recette) else {
            return nil
        }

        return Recette(
            id: row[id],
            titre: row[titre],
            ingredients: row[ingredients],
            ingredientsManquants: row[ingredientsManquants],
            etapes: row[etapes],
            categorie: row[categorie],
            note: row[note],
            dejaFaite: row[dejaFaite],
            tempsPreparation: row[tempsPreparation]
        )
    }

    static func ajouterRecette(db: Connection, recette: Recette) throws {
        try db.run(
            recettes.insert(
                titre <- recette.titre,
                ingredients <- recette.ingredients,
                ingredientsManquants <- recette.ingredientsManquants,
                etapes <- recette.etapes,
                categorie <- recette.categorie,
                note <- recette.note,
                dejaFaite <- recette.dejaFaite,
                tempsPreparation <- recette.tempsPreparation
            )
        )
    }

    static func updateRecipe(db: Connection, recipe: Recette) throws {
        guard let recetteId = recipe.id else { return }

        let cible = recettes.filter(id == recetteId)
        try db.run(
            cible.update(
                titre <- recipe.titre,
                ingredients <- recipe.ingredients,
                ingredientsManquants <- recipe.ingredientsManquants,
                etapes <- recipe.etapes,
                categorie <- recipe.categorie,
                note <- recipe.note,
                dejaFaite <- recipe.dejaFaite,
                tempsPreparation <- recipe.tempsPreparation
            )
        )
    }

    static func deleteRecipe(db: Connection, id targetId: Int64) throws {
        let recette = recettes.filter(id == targetId)
        try db.run(recette.delete())
    }

    static func toggleCooked(db: Connection, id targetId: Int64) throws {
        let recette = recettes.filter(id == targetId)

        guard let row = try db.pluck(recette) else { return }
        let current = row[dejaFaite]

        try db.run(recette.update(dejaFaite <- !current))
    }

    static func updateRating(db: Connection, id targetId: Int64, newRating: Int) throws {
        let recette = recettes.filter(id == targetId)
        try db.run(recette.update(note <- newRating))
    }
}
