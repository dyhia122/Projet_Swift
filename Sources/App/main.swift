import Foundation
import Hummingbird
@preconcurrency import SQLite

// DB setup
let db = try Database.setup()

// Router
let router = Router()

// READ
router.get("/") { _, _ -> HTML in
    let allRecipes = try Database.fetchAllRecipes(db: db)
    return Views.renderIndex(items: allRecipes)
}

// CREATE
router.post("/add") { request, _ -> Response in
    let buffer = try await request.body.collect(upTo: 1024 * 16)
    let bodyString = String(buffer: buffer)

    var components = URLComponents()
    components.percentEncodedQuery = bodyString

    let title = components.queryItems?.first(where: { $0.name == "title" })?.value ?? ""
    let ingredients = components.queryItems?.first(where: { $0.name == "ingredients" })?.value ?? ""
    let steps = components.queryItems?.first(where: { $0.name == "steps" })?.value ?? ""
    let category = components.queryItems?.first(where: { $0.name == "category" })?.value ?? ""

    let recipe = Recipe(
        id: nil,
        title: title,
        ingredients: ingredients,
        steps: steps,
        category: category
    )

    try Database.addRecipe(db: db, recipe: recipe)

    return Response(status: .seeOther, headers: [.location: "/"])
}

// DELETE
router.post("/delete/:id") { _, context -> Response in
    guard let idStr = context.parameters.get("id"),
        let targetId = Int64(idStr)
    else {
        return Response(status: .badRequest)
    }

    try Database.deleteRecipe(db: db, id: targetId)
    return Response(status: .seeOther, headers: [.location: "/"])
}

// UPDATE
router.post("/update/:id") { request, context -> Response in
    guard let idStr = context.parameters.get("id"),
        let targetId = Int64(idStr)
    else {
        return Response(status: .badRequest)
    }

    let buffer = try await request.body.collect(upTo: 1024 * 16)
    let bodyString = String(buffer: buffer)

    var components = URLComponents()
    components.percentEncodedQuery = bodyString

    let newTitle = components.queryItems?.first(where: { $0.name == "title" })?.value ?? ""

    try Database.updateRecipe(db: db, id: targetId, newTitle: newTitle)

    return Response(status: .seeOther, headers: [.location: "/"])
}

// Start server
let app = Application(
    router: router,
    configuration: .init(address: .hostname("0.0.0.0", port: 8080))
)

print("🚀 Server started at http://localhost:8080")
try await app.runService()
