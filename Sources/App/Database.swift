import Foundation
@preconcurrency import SQLite

extension Connection: @unchecked @retroactive Sendable {}

struct Database {
    static let utilisateurs = Table("utilisateurs")
    static let recettes = Table("recettes")

    // USERS
    static let userId = Expression<Int64>("id")
    static let nom = Expression<String>("nom")
    static let email = Expression<String>("email")
    static let motDePasse = Expression<String>("mot_de_passe")

    // RECIPES
    static let id = Expression<Int64>("id")
    static let utilisateurId = Expression<Int64>("utilisateur_id")
    static let titre = Expression<String>("titre")
    static let ingredients = Expression<String>("ingredients")
    static let ingredientsManquants = Expression<String>("ingredients_manquants")
    static let etapes = Expression<String>("etapes")
    static let categorie = Expression<String>("categorie")
    static let note = Expression<Int?>("note")
    static let dejaFaite = Expression<Bool>("deja_faite")
    static let tempsPreparation = Expression<Int>("temps_preparation")

    static func setup() throws -> Connection {
        let db = try Connection("db.sqlite3")

        // TABLE USERS
        try db.run(
            utilisateurs.create(ifNotExists: true) { t in
                t.column(userId, primaryKey: .autoincrement)
                t.column(nom)
                t.column(email, unique: true)
                t.column(motDePasse)
            }
        )

        // TABLE RECIPES
        try db.run(
            recettes.create(ifNotExists: true) { t in
                t.column(id, primaryKey: .autoincrement)
                t.column(utilisateurId)
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

    // MARK: - USERS

    static func createUser(db: Connection, user: Utilisateur) throws {
        try db.run(
            utilisateurs.insert(
                nom <- user.nom,
                email <- user.email,
                motDePasse <- user.motDePasse
            )
        )
    }

    static func fetchUserByEmail(db: Connection, userEmail: String) throws -> Utilisateur? {
        let query = utilisateurs.filter(email == userEmail)

        guard let row = try db.pluck(query) else { return nil }

        return Utilisateur(
            id: row[userId],
            nom: row[nom],
            email: row[email],
            motDePasse: row[motDePasse]
        )
    }

    static func fetchUserById(db: Connection, id targetId: Int64) throws -> Utilisateur? {
        let query = utilisateurs.filter(userId == targetId)

        guard let row = try db.pluck(query) else { return nil }

        return Utilisateur(
            id: row[userId],
            nom: row[nom],
            email: row[email],
            motDePasse: row[motDePasse]
        )
    }

    // MARK: - RECIPES

    static func seedInitialRecipes(db: Connection) throws {
        let existingUser = try fetchUserByEmail(db: db, userEmail: "demo@demo.com")

        let demoUserId: Int64

        if let existingUser, let id = existingUser.id {
            demoUserId = id
        } else {
            let demo = Utilisateur(
                id: nil,
                nom: "Demo User",
                email: "demo@demo.com",
                motDePasse: "demo123"
            )
            try createUser(db: db, user: demo)
            demoUserId = try fetchUserByEmail(db: db, userEmail: "demo@demo.com")?.id ?? 1
        }

        let count = try db.scalar(recettes.count)

        if count == 0 {
            let recettesExemple = [
                Recette(
                    id: nil,
                    utilisateurId: demoUserId,
                    titre: "Pâtes Carbonara",
                    ingredients: "Pâtes, lardons, œufs, parmesan, poivre",
                    ingredientsManquants: "Parmesan",
                    etapes:
                        "Faire cuire les pâtes\nCuire les lardons\nMélanger les œufs et le parmesan\nAssembler le tout",
                    categorie: "Italienne",
                    note: 4,
                    dejaFaite: true,
                    tempsPreparation: 20
                ),
                Recette(
                    id: nil,
                    utilisateurId: demoUserId,
                    titre: "Pancakes maison",
                    ingredients: "Farine, lait, œufs, sucre, beurre",
                    ingredientsManquants: "",
                    etapes:
                        "Mélanger tous les ingrédients\nLaisser reposer 10 minutes\nCuire à la poêle",
                    categorie: "Petit-déjeuner",
                    note: nil,
                    dejaFaite: false,
                    tempsPreparation: 15
                ),
            ]

            for recette in recettesExemple {
                try ajouterRecette(db: db, recette: recette)
            }
        }
    }

    static func normalize(_ text: String) -> String {
        text
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func fetchAllRecipes(
        db: Connection, userId targetUserId: Int64, search query: String? = nil
    ) throws -> [Recette] {
        let allRecipes = try db.prepare(
            recettes
                .filter(utilisateurId == targetUserId)
                .order(titre.asc)
        ).map { row in
            Recette(
                id: row[id],
                utilisateurId: row[utilisateurId],
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

        guard let query, !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return allRecipes
        }

        let normalizedQuery = normalize(query)

        return allRecipes.filter { recette in
            normalize(recette.titre).contains(normalizedQuery)
                || normalize(recette.categorie).contains(normalizedQuery)
                || normalize(recette.ingredients).contains(normalizedQuery)
                || normalize(recette.ingredientsManquants).contains(normalizedQuery)
        }
    }

    static func fetchRecipeById(db: Connection, recipeId: Int64, userId targetUserId: Int64) throws
        -> Recette?
    {
        let recette = recettes.filter(id == recipeId && utilisateurId == targetUserId)

        guard let row = try db.pluck(recette) else { return nil }

        return Recette(
            id: row[id],
            utilisateurId: row[utilisateurId],
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
                utilisateurId <- recette.utilisateurId,
                titre <- recette.titre,
                ingredients <- recette.ingredients,
                ingredientsManquants <- recette.ingredientsManquants,
                etapes <- recette.etapes,
                categorie <- recette.categorie,
                note <- (recette.dejaFaite ? recette.note : nil),
                dejaFaite <- recette.dejaFaite,
                tempsPreparation <- recette.tempsPreparation
            )
        )
    }

    static func updateRecipe(db: Connection, recipe: Recette) throws {
        guard let recetteId = recipe.id else { return }

        let cible = recettes.filter(id == recetteId && utilisateurId == recipe.utilisateurId)
        try db.run(
            cible.update(
                titre <- recipe.titre,
                ingredients <- recipe.ingredients,
                ingredientsManquants <- recipe.ingredientsManquants,
                etapes <- recipe.etapes,
                categorie <- recipe.categorie,
                note <- (recipe.dejaFaite ? recipe.note : nil),
                dejaFaite <- recipe.dejaFaite,
                tempsPreparation <- recipe.tempsPreparation
            )
        )
    }

    static func deleteRecipe(db: Connection, id targetId: Int64, userId targetUserId: Int64) throws
    {
        let recette = recettes.filter(id == targetId && utilisateurId == targetUserId)
        try db.run(recette.delete())
    }

    static func toggleCooked(db: Connection, id targetId: Int64, userId targetUserId: Int64) throws
    {
        let recette = recettes.filter(id == targetId && utilisateurId == targetUserId)

        guard let row = try db.pluck(recette) else { return }
        let current = row[dejaFaite]
        let currentNote = row[note]

        try db.run(
            recette.update(
                dejaFaite <- !current,
                note <- (!current ? (currentNote ?? 3) : nil)
            )
        )
    }

    static func updateRating(
        db: Connection, id targetId: Int64, userId targetUserId: Int64, newRating: Int
    ) throws {
        let recette = recettes.filter(id == targetId && utilisateurId == targetUserId)

        guard let row = try db.pluck(recette), row[dejaFaite] == true else { return }

        try db.run(recette.update(note <- newRating))
    }

    static func fetchShoppingList(db: Connection, userId targetUserId: Int64) throws -> [String] {
        let recipes = try fetchAllRecipes(db: db, userId: targetUserId)

        let ingredients =
            recipes
            .flatMap { $0.ingredientsManquants.components(separatedBy: ",") }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        return Array(Set(ingredients)).sorted()
    }
}
