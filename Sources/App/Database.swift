import Foundation
@preconcurrency import SQLite

// Fix Sendable issue
extension Connection: @unchecked @retroactive Sendable {}

struct Database {
    static let recipes = Table("recipes")

    static let id = Expression<Int64>("id")
    static let title = Expression<String>("title")
    static let ingredients = Expression<String>("ingredients")
    static let missingIngredients = Expression<String>("missing_ingredients")
    static let steps = Expression<String>("steps")
    static let category = Expression<String>("category")
    static let rating = Expression<Int>("rating")
    static let isCooked = Expression<Bool>("is_cooked")
    static let prepTime = Expression<Int>("prep_time")

    static func setup() throws -> Connection {
        let db = try Connection("db.sqlite3")

        try db.run(
            recipes.create(ifNotExists: true) { t in
                t.column(id, primaryKey: .autoincrement)
                t.column(title)
                t.column(ingredients)
                t.column(missingIngredients)
                t.column(steps)
                t.column(category)
                t.column(rating)
                t.column(isCooked)
                t.column(prepTime)
            }
        )

        return db
    }

    static func seedInitialRecipes(db: Connection) throws {
        let count = try db.scalar(recipes.count)

        if count == 0 {
            let sampleRecipes = [
                Recipe(
                    id: nil,
                    title: "Pâtes Carbonara",
                    ingredients: "Pâtes, lardons, œufs, parmesan, poivre",
                    missingIngredients: "Parmesan",
                    steps: "1. Faire cuire les pâtes.\n2. Cuire les lardons.\n3. Mélanger les œufs et le parmesan.\n4. Assembler le tout.",
                    category: "Italienne",
                    rating: 4,
                    isCooked: true,
                    prepTime: 20
                ),
                Recipe(
                    id: nil,
                    title: "Pancakes maison",
                    ingredients: "Farine, lait, œufs, sucre, beurre",
                    missingIngredients: "",
                    steps: "1. Mélanger tous les ingrédients.\n2. Laisser reposer 10 minutes.\n3. Cuire à la poêle.",
                    category: "Petit-déjeuner",
                    rating: 5,
                    isCooked: false,
                    prepTime: 15
                ),
                Recipe(
                    id: nil,
                    title: "Salade César",
                    ingredients: "Salade, poulet, croûtons, parmesan, sauce César",
                    missingIngredients: "Croûtons",
                    steps: "1. Couper le poulet.\n2. Mélanger avec la salade.\n3. Ajouter les croûtons, parmesan et sauce.",
                    category: "Salade",
                    rating: 3,
                    isCooked: true,
                    prepTime: 12
                ),
                Recipe(
                    id: nil,
                    title: "Brownies chocolat",
                    ingredients: "Chocolat noir, beurre, sucre, œufs, farine",
                    missingIngredients: "Chocolat noir",
                    steps: "1. Faire fondre le chocolat et le beurre.\n2. Ajouter sucre, œufs et farine.\n3. Cuire au four.",
                    category: "Dessert",
                    rating: 5,
                    isCooked: false,
                    prepTime: 35
                )
            ]

            for recipe in sampleRecipes {
                try addRecipe(db: db, recipe: recipe)
            }
        }
    }

    static func fetchAllRecipes(db: Connection, search query: String? = nil) throws -> [Recipe] {
        var queryTable = recipes

        if let query, !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            queryTable = queryTable.filter(
                title.like("%\(query)%") ||
                category.like("%\(query)%") ||
                ingredients.like("%\(query)%")
            )
        }

        return try db.prepare(queryTable.order(title.asc)).map { row in
            Recipe(
                id: row[id],
                title: row[title],
                ingredients: row[ingredients],
                missingIngredients: row[missingIngredients],
                steps: row[steps],
                category: row[category],
                rating: row[rating],
                isCooked: row[isCooked],
                prepTime: row[prepTime]
            )
        }
    }

    static func fetchRecipeById(db: Connection, recipeId: Int64) throws -> Recipe? {
        let recipe = recipes.filter(id == recipeId)

        guard let row = try db.pluck(recipe) else {
            return nil
        }

        return Recipe(
            id: row[id],
            title: row[title],
            ingredients: row[ingredients],
            missingIngredients: row[missingIngredients],
            steps: row[steps],
            category: row[category],
            rating: row[rating],
            isCooked: row[isCooked],
            prepTime: row[prepTime]
        )
    }

    static func addRecipe(db: Connection, recipe: Recipe) throws {
        try db.run(
            recipes.insert(
                title <- recipe.title,
                ingredients <- recipe.ingredients,
                missingIngredients <- recipe.missingIngredients,
                steps <- recipe.steps,
                category <- recipe.category,
                rating <- recipe.rating,
                isCooked <- recipe.isCooked,
                prepTime <- recipe.prepTime
            )
        )
    }

    static func updateRecipe(db: Connection, recipe: Recipe) throws {
        guard let recipeId = recipe.id else { return }

        let target = recipes.filter(id == recipeId)
        try db.run(
            target.update(
                title <- recipe.title,
                ingredients <- recipe.ingredients,
                missingIngredients <- recipe.missingIngredients,
                steps <- recipe.steps,
                category <- recipe.category,
                rating <- recipe.rating,
                isCooked <- recipe.isCooked,
                prepTime <- recipe.prepTime
            )
        )
    }

    static func deleteRecipe(db: Connection, id targetId: Int64) throws {
        let recipe = recipes.filter(id == targetId)
        try db.run(recipe.delete())
    }

    static func toggleCooked(db: Connection, id targetId: Int64) throws {
        let recipe = recipes.filter(id == targetId)

        guard let row = try db.pluck(recipe) else { return }
        let current = row[isCooked]

        try db.run(recipe.update(isCooked <- !current))
    }

    static func updateRating(db: Connection, id targetId: Int64, newRating: Int) throws {
        let recipe = recipes.filter(id == targetId)
        try db.run(recipe.update(rating <- newRating))
    }
}