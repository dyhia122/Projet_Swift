import Foundation
import Hummingbird
@preconcurrency import SQLite

// DB setup
let db = try Database.setup()
try Database.seedInitialRecipes(db: db)

// Router
let router = Router()

// Helper pour parser les formulaires
func parseForm(_ request: Request) async throws -> [String: String] {
    let buffer = try await request.body.collect(upTo: 1024 * 64)
    let bodyString = String(buffer: buffer)

    var components = URLComponents()
    components.percentEncodedQuery = bodyString

    var formData: [String: String] = [:]

    components.queryItems?.forEach { item in
        formData[item.name] = item.value ?? ""
    }

    return formData
}

// Récupérer toutes les étapes dynamiques envoyées depuis le formulaire
func parseSteps(from form: [String: String]) -> String {
    let etapesTriees =
        form
        .filter { $0.key.hasPrefix("etape_") }
        .sorted { lhs, rhs in
            let leftIndex = Int(lhs.key.replacingOccurrences(of: "etape_", with: "")) ?? 0
            let rightIndex = Int(rhs.key.replacingOccurrences(of: "etape_", with: "")) ?? 0
            return leftIndex < rightIndex
        }
        .map { $0.value.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }

    return etapesTriees.enumerated().map { index, texte in
        "\(index + 1). \(texte)"
    }.joined(separator: "\n")
}

// Validation
func validateRecipeForm(_ form: [String: String]) -> String? {
    let titre = form["titre"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    let ingredients = form["ingredients"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    let categorie = form["categorie"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    let tempsPreparation = Int(form["tempsPreparation"] ?? "") ?? 0
    let etapes = parseSteps(from: form)

    if titre.isEmpty { return "Le titre est obligatoire." }
    if ingredients.isEmpty { return "Les ingrédients sont obligatoires." }
    if etapes.isEmpty { return "Ajoute au moins une étape." }
    if categorie.isEmpty { return "La catégorie est obligatoire." }
    if tempsPreparation <= 0 { return "Le temps de préparation doit être supérieur à 0." }

    return nil
}

// READ - liste + recherche
router.get("/") { request, _ -> HTML in
    let search = request.uri.queryParameters.get("search") ?? ""
    let toutesLesRecettes = try Database.fetchAllRecipes(db: db, search: search)
    return Views.renderIndex(items: toutesLesRecettes, search: search)
}

// PAGE AJOUT
router.get("/add") { _, _ -> HTML in
    return Views.renderAddRecipePage()
}

// READ - détail (VOIR)
router.get("/recipe/:id") { _, context -> HTML in
    guard let idStr = context.parameters.get("id"),
        let targetId = Int64(idStr),
        let recette = try Database.fetchRecipeById(db: db, recipeId: targetId)
    else {
        return Views.renderIndex(items: [], error: "Recette introuvable.")
    }

    return Views.renderRecipeDetail(item: recette)
}

// PAGE MODIFIER
router.get("/edit/:id") { _, context -> HTML in
    guard let idStr = context.parameters.get("id"),
        let targetId = Int64(idStr),
        let recette = try Database.fetchRecipeById(db: db, recipeId: targetId)
    else {
        return Views.renderIndex(items: [], error: "Recette introuvable.")
    }

    return Views.renderEditRecipePage(item: recette)
}

// CREATE
router.post("/add") { request, _ -> Response in
    let form = try await parseForm(request)

    if validateRecipeForm(form) != nil {
        return Response(status: .seeOther, headers: [.location: "/add"])
    }

    let dejaFaite = form["dejaFaite"] != nil
    let etapesAssemblees = parseSteps(from: form)

    let recette = Recette(
        id: nil,
        titre: form["titre"] ?? "",
        ingredients: form["ingredients"] ?? "",
        ingredientsManquants: form["ingredientsManquants"] ?? "",
        etapes: etapesAssemblees,
        categorie: form["categorie"] ?? "",
        note: dejaFaite ? (Int(form["note"] ?? "3") ?? 3) : nil,
        dejaFaite: dejaFaite,
        tempsPreparation: Int(form["tempsPreparation"] ?? "0") ?? 0
    )

    try Database.ajouterRecette(db: db, recette: recette)

    return Response(status: .seeOther, headers: [.location: "/"])
}

// UPDATE complet
router.post("/update/:id") { request, context -> Response in
    guard let idStr = context.parameters.get("id"),
        let targetId = Int64(idStr)
    else {
        return Response(status: .badRequest)
    }

    let form = try await parseForm(request)

    if validateRecipeForm(form) != nil {
        return Response(status: .seeOther, headers: [.location: "/edit/\(targetId)"])
    }

    let dejaFaite = form["dejaFaite"] != nil
    let etapesAssemblees = parseSteps(from: form)

    let recetteModifiee = Recette(
        id: targetId,
        titre: form["titre"] ?? "",
        ingredients: form["ingredients"] ?? "",
        ingredientsManquants: form["ingredientsManquants"] ?? "",
        etapes: etapesAssemblees,
        categorie: form["categorie"] ?? "",
        note: dejaFaite ? (Int(form["note"] ?? "3") ?? 3) : nil,
        dejaFaite: dejaFaite,
        tempsPreparation: Int(form["tempsPreparation"] ?? "0") ?? 0
    )

    try Database.updateRecipe(db: db, recipe: recetteModifiee)

    return Response(status: .seeOther, headers: [.location: "/recipe/\(targetId)"])
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

// TOGGLE statut
router.post("/toggle-cooked/:id") { _, context -> Response in
    guard let idStr = context.parameters.get("id"),
        let targetId = Int64(idStr)
    else {
        return Response(status: .badRequest)
    }

    try Database.toggleCooked(db: db, id: targetId)
    return Response(status: .seeOther, headers: [.location: "/"])
}

// NOTE
router.post("/rate/:id") { request, context -> Response in
    guard let idStr = context.parameters.get("id"),
        let targetId = Int64(idStr)
    else {
        return Response(status: .badRequest)
    }

    let form = try await parseForm(request)
    let note = max(1, min(5, Int(form["note"] ?? "3") ?? 3))

    try Database.updateRating(db: db, id: targetId, newRating: note)

    return Response(status: .seeOther, headers: [.location: "/"])
}

// Start server
let app = Application(
    router: router,
    configuration: .init(address: .hostname("0.0.0.0", port: 8080))
)

print("🚀 Server started at http://localhost:8080")
try await app.runService()
