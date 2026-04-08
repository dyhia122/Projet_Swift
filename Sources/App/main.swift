import Foundation
import Hummingbird
@preconcurrency import SQLite

let db = try Database.setup()
try Database.seedInitialRecipes(db: db)

let router = Router()

func parseForm(_ request: Request) async throws -> [String: String] {
    let buffer = try await request.body.collect(upTo: 1024 * 16)
    let bodyString = String(buffer: buffer)

    var components = URLComponents()
    components.percentEncodedQuery = bodyString

    var formData: [String: String] = [:]

    components.queryItems?.forEach { item in
        formData[item.name] = item.value ?? ""
    }

    return formData
}

func getSessionToken(from request: Request) -> String? {
    request.headers[values: .cookie]
        .joined(separator: "; ")
        .split(separator: ";")
        .map { $0.trimmingCharacters(in: .whitespaces) }
        .first(where: { $0.hasPrefix("session=") })?
        .replacingOccurrences(of: "session=", with: "")
}

func getCurrentUserId(from request: Request) -> Int64? {
    guard let token = getSessionToken(from: request) else { return nil }
    return SessionManager.shared.getUserId(from: token)
}

func validateRecipeForm(_ form: [String: String]) -> String? {
    let titre = form["titre"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    let ingredients = form["ingredients"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    let etapes = form["etapes"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    let categorie = form["categorie"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    let tempsPreparation = Int(form["tempsPreparation"] ?? "") ?? 0

    if titre.isEmpty { return "Le titre est obligatoire." }
    if ingredients.isEmpty { return "Les ingrédients sont obligatoires." }
    if etapes.isEmpty { return "Les étapes sont obligatoires." }
    if categorie.isEmpty { return "La catégorie est obligatoire." }
    if tempsPreparation <= 0 { return "Le temps de préparation doit être supérieur à 0." }

    return nil
}

// MARK: AUTH

router.get("/register") { _, _ -> HTML in
    Views.renderRegisterPage()
}

router.post("/register") { request, _ -> Response in
    let form = try await parseForm(request)

    let nom = form["nom"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    let email = form["email"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    let motDePasse = form["motDePasse"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

    guard !nom.isEmpty, !email.isEmpty, !motDePasse.isEmpty else {
        return Response(status: .seeOther, headers: [.location: "/register"])
    }

    if try Database.fetchUserByEmail(db: db, userEmail: email) == nil {
        try Database.createUser(
            db: db,
            user: Utilisateur(id: nil, nom: nom, email: email, motDePasse: motDePasse)
        )
    }

    return Response(status: .seeOther, headers: [.location: "/login"])
}

router.get("/login") { _, _ -> HTML in
    Views.renderLoginPage()
}

router.post("/login") { request, _ -> Response in
    let form = try await parseForm(request)

    let email = form["email"] ?? ""
    let motDePasse = form["motDePasse"] ?? ""

    guard let user = try Database.fetchUserByEmail(db: db, userEmail: email),
        user.motDePasse == motDePasse,
        let userId = user.id
    else {
        return Response(status: .seeOther, headers: [.location: "/login"])
    }

    let token = SessionManager.shared.createSession(for: userId)

    return Response(
        status: .seeOther,
        headers: [
            .location: "/",
            .setCookie: "session=\(token); Path=/; HttpOnly",
        ]
    )
}

router.get("/logout") { request, _ -> Response in
    if let token = getSessionToken(from: request) {
        SessionManager.shared.removeSession(token: token)
    }

    return Response(
        status: .seeOther,
        headers: [
            .location: "/login",
            .setCookie: "session=deleted; Path=/; Max-Age=0",
        ]
    )
}

// MARK: HOME

router.get("/") { request, _ -> HTML in
    guard let userId = getCurrentUserId(from: request),
        let user = try Database.fetchUserById(db: db, id: userId)
    else {
        return Views.renderWelcomePage()
    }

    let search = request.uri.queryParameters.get("search") ?? ""
    let toutesLesRecettes = try Database.fetchAllRecipes(db: db, userId: userId, search: search)
    return Views.renderIndex(items: toutesLesRecettes, search: search, userName: user.nom)
}

// MARK: ADD

router.get("/add") { request, _ -> HTML in
    guard getCurrentUserId(from: request) != nil else {
        return Views.renderLoginPage()
    }
    return Views.renderAddRecipePage()
}

router.post("/add") { request, _ -> Response in
    guard let userId = getCurrentUserId(from: request) else {
        return Response(status: .seeOther, headers: [.location: "/login"])
    }

    let form = try await parseForm(request)

    if validateRecipeForm(form) != nil {
        return Response(status: .seeOther, headers: [.location: "/add"])
    }

    let dejaFaite = form["dejaFaite"] != nil

    let recette = Recette(
        id: nil,
        utilisateurId: userId,
        titre: form["titre"] ?? "",
        ingredients: form["ingredients"] ?? "",
        ingredientsManquants: form["ingredientsManquants"] ?? "",
        etapes: form["etapes"] ?? "",
        categorie: form["categorie"] ?? "",
        note: dejaFaite ? (Int(form["note"] ?? "3") ?? 3) : nil,
        dejaFaite: dejaFaite,
        tempsPreparation: Int(form["tempsPreparation"] ?? "0") ?? 0
    )

    try Database.ajouterRecette(db: db, recette: recette)
    return Response(status: .seeOther, headers: [.location: "/"])
}

// MARK: DETAILS

router.get("/recipe/:id") { request, context -> HTML in
    guard let userId = getCurrentUserId(from: request) else {
        return Views.renderLoginPage()
    }

    guard let idStr = context.parameters.get("id"),
        let targetId = Int64(idStr),
        let recette = try Database.fetchRecipeById(db: db, recipeId: targetId, userId: userId)
    else {
        return Views.renderIndex(items: [], error: "Recette introuvable.", userName: "Utilisateur")
    }

    return Views.renderRecipeDetail(item: recette)
}

// MARK: EDIT

router.get("/edit/:id") { request, context -> HTML in
    guard let userId = getCurrentUserId(from: request) else {
        return Views.renderLoginPage()
    }

    guard let idStr = context.parameters.get("id"),
        let targetId = Int64(idStr),
        let recette = try Database.fetchRecipeById(db: db, recipeId: targetId, userId: userId)
    else {
        return Views.renderIndex(items: [], error: "Recette introuvable.", userName: "Utilisateur")
    }

    return Views.renderEditRecipePage(item: recette)
}

router.post("/update/:id") { request, context -> Response in
    guard let userId = getCurrentUserId(from: request) else {
        return Response(status: .seeOther, headers: [.location: "/login"])
    }

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

    let recetteModifiee = Recette(
        id: targetId,
        utilisateurId: userId,
        titre: form["titre"] ?? "",
        ingredients: form["ingredients"] ?? "",
        ingredientsManquants: form["ingredientsManquants"] ?? "",
        etapes: form["etapes"] ?? "",
        categorie: form["categorie"] ?? "",
        note: dejaFaite ? (Int(form["note"] ?? "3") ?? 3) : nil,
        dejaFaite: dejaFaite,
        tempsPreparation: Int(form["tempsPreparation"] ?? "0") ?? 0
    )

    try Database.updateRecipe(db: db, recipe: recetteModifiee)

    return Response(status: .seeOther, headers: [.location: "/recipe/\(targetId)"])
}

// MARK: DELETE

router.post("/delete/:id") { request, context -> Response in
    guard let userId = getCurrentUserId(from: request) else {
        return Response(status: .seeOther, headers: [.location: "/login"])
    }

    guard let idStr = context.parameters.get("id"),
        let targetId = Int64(idStr)
    else {
        return Response(status: .badRequest)
    }

    try Database.deleteRecipe(db: db, id: targetId, userId: userId)
    return Response(status: .seeOther, headers: [.location: "/"])
}

// MARK: TOGGLE

router.post("/toggle-cooked/:id") { request, context -> Response in
    guard let userId = getCurrentUserId(from: request) else {
        return Response(status: .seeOther, headers: [.location: "/login"])
    }

    guard let idStr = context.parameters.get("id"),
        let targetId = Int64(idStr)
    else {
        return Response(status: .badRequest)
    }

    try Database.toggleCooked(db: db, id: targetId, userId: userId)
    return Response(status: .seeOther, headers: [.location: "/"])
}

// MARK: RATE

router.post("/rate/:id") { request, context -> Response in
    guard let userId = getCurrentUserId(from: request) else {
        return Response(status: .seeOther, headers: [.location: "/login"])
    }

    guard let idStr = context.parameters.get("id"),
        let targetId = Int64(idStr)
    else {
        return Response(status: .badRequest)
    }

    let form = try await parseForm(request)
    let note = max(1, min(5, Int(form["note"] ?? "3") ?? 3))

    try Database.updateRating(db: db, id: targetId, userId: userId, newRating: note)

    return Response(status: .seeOther, headers: [.location: "/"])
}

// MARK: SHOPPING LIST

router.get("/shopping-list") { request, _ -> HTML in
    guard let userId = getCurrentUserId(from: request) else {
        return Views.renderLoginPage()
    }

    let shoppingItems = try Database.fetchShoppingList(db: db, userId: userId)
    return Views.renderShoppingListPage(items: shoppingItems)
}

let app = Application(
    router: router,
    configuration: .init(address: .hostname("0.0.0.0", port: 8080))
)

print("🚀 Server started at http://localhost:8080")
try await app.runService()
