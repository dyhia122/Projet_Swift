import Foundation
@preconcurrency import SQLite

// Fix Sendable issue
extension Connection: @unchecked @retroactive Sendable {}

struct Database {
    static let recipes = Table("recipes")

    static let id = Expression<Int64>("id")
    static let title = Expression<String>("title")
    static let ingredients = Expression<String>("ingredients")
    static let steps = Expression<String>("steps")
    static let category = Expression<String>("category")

    static func setup() throws -> Connection {
        let db = try Connection("db.sqlite3")

        try db.run(
            recipes.create(ifNotExists: true) { t in
                t.column(id, primaryKey: .autoincrement)
                t.column(title)
                t.column(ingredients)
                t.column(steps)
                t.column(category)
            })

        return db
    }

    static func fetchAllRecipes(db: Connection) throws -> [Recipe] {
        try db.prepare(recipes).map {
            Recipe(
                id: $0[id],
                title: $0[title],
                ingredients: $0[ingredients],
                steps: $0[steps],
                category: $0[category]
            )
        }
    }

    static func addRecipe(db: Connection, recipe: Recipe) throws {
        try db.run(
            recipes.insert(
                title <- recipe.title,
                ingredients <- recipe.ingredients,
                steps <- recipe.steps,
                category <- recipe.category
            ))
    }

    static func deleteRecipe(db: Connection, id targetId: Int64) throws {
        let recipe = recipes.filter(id == targetId)
        try db.run(recipe.delete())
    }

    static func updateRecipe(db: Connection, id targetId: Int64, newTitle: String) throws {
        let recipe = recipes.filter(id == targetId)
        try db.run(recipe.update(title <- newTitle))
    }
}
