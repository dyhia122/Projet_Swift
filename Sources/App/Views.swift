import Foundation
import Hummingbird

struct Views {

    static func stars(_ rating: Int) -> String {
        let safeRating = max(1, min(5, rating))
        return String(repeating: "⭐", count: safeRating)
    }

    static func renderIndex(items: [Recipe], search: String = "", error: String? = nil) -> HTML {
        let rows = items.map { item in
            """
            <article>
                <header>
                    <h2>\(item.title)</h2>
                    <p><strong>Catégorie:</strong> \(item.category)</p>
                    <p><strong>Note:</strong> \(stars(item.rating)) (\(item.rating)/5)</p>
                    <p><strong>Temps de préparation:</strong> \(item.prepTime) min</p>
                    <p><strong>Statut:</strong> \(item.isCooked ? "✅ Déjà faite" : "🕒 À essayer")</p>
                </header>

                <p><strong>Ingrédients:</strong> \(item.ingredients)</p>
                <p><strong>Ingrédients manquants:</strong> \(item.missingIngredients.isEmpty ? "Aucun 🎉" : item.missingIngredients)</p>
                <p><strong>Étapes:</strong> \(item.steps)</p>

                <div class="grid">
                    <form action="/toggle-cooked/\(item.id ?? 0)" method="post">
                        <button type="submit">Basculer statut</button>
                    </form>

                    <form action="/delete/\(item.id ?? 0)" method="post">
                        <button type="submit" class="contrast">Supprimer</button>
                    </form>

                    <form action="/rate/\(item.id ?? 0)" method="post">
                        <select name="rating">
                            <option value="1">1 ⭐</option>
                            <option value="2">2 ⭐</option>
                            <option value="3">3 ⭐</option>
                            <option value="4">4 ⭐</option>
                            <option value="5">5 ⭐</option>
                        </select>
                        <button type="submit">Noter</button>
                    </form>
                </div>

                <p><a href="/recipe/\(item.id ?? 0)">Voir / Modifier la recette</a></p>
            </article>
            """
        }.joined()

        return HTML(
            content: """
            <!DOCTYPE html>
            <html lang="fr">
            <head>
                <meta charset="utf-8">
                <meta name="viewport" content="width=device-width, initial-scale=1">
                <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@picocss/pico@2/css/pico.min.css">
                <title>Carnet de recettes</title>
                <style>
                    .badge {
                        display: inline-block;
                        padding: 0.2rem 0.6rem;
                        border-radius: 999px;
                        background: #f3f4f6;
                        font-size: 0.9rem;
                    }
                    .hero {
                        margin: 2rem 0;
                    }
                </style>
            </head>
            <body class="container">
                <main>
                    <section class="hero">
                        <h1>🍲 Carnet de recettes</h1>
                        <p>Ajoute, note et organise tes recettes préférées.</p>
                    </section>

                    \(error != nil ? "<article><strong>Erreur :</strong> \(error!)</article>" : "")

                    <section>
                        <h2>🔍 Recherche</h2>
                        <form action="/" method="get">
                            <input type="search" name="search" placeholder="Rechercher une recette, une catégorie..." value="\(search)">
                            <button type="submit">Rechercher</button>
                        </form>
                    </section>

                    <section>
                        <h2>➕ Ajouter une recette</h2>
                        <form action="/add" method="post">
                            <input name="title" placeholder="Titre" required>
                            <input name="category" placeholder="Catégorie" required>
                            <input name="prepTime" type="number" min="1" placeholder="Temps de préparation (min)" required>
                            <textarea name="ingredients" placeholder="Ingrédients (séparés par des virgules)" required></textarea>
                            <textarea name="missingIngredients" placeholder="Ingrédients manquants (optionnel)"></textarea>
                            <textarea name="steps" placeholder="Étapes de préparation" required></textarea>

                            <label for="rating">Note initiale</label>
                            <select name="rating">
                                <option value="1">1 ⭐</option>
                                <option value="2">2 ⭐</option>
                                <option value="3" selected>3 ⭐</option>
                                <option value="4">4 ⭐</option>
                                <option value="5">5 ⭐</option>
                            </select>

                            <label>
                                <input type="checkbox" name="isCooked">
                                Déjà réalisée
                            </label>

                            <button type="submit">Ajouter la recette</button>
                        </form>
                    </section>

                    <hr>

                    <section>
                        <h2>📚 Toutes les recettes</h2>
                        \(items.isEmpty ? "<p>Aucune recette trouvée.</p>" : rows)
                    </section>
                </main>
            </body>
            </html>
            """
        )
    }

    static func renderRecipeDetail(item: Recipe, error: String? = nil) -> HTML {
        HTML(
            content: """
            <!DOCTYPE html>
            <html lang="fr">
            <head>
                <meta charset="utf-8">
                <meta name="viewport" content="width=device-width, initial-scale=1">
                <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@picocss/pico@2/css/pico.min.css">
                <title>\(item.title)</title>
            </head>
            <body class="container">
                <main>
                    <p><a href="/">← Retour à l'accueil</a></p>

                    <h1>🍽️ Modifier la recette</h1>

                    \(error != nil ? "<article><strong>Erreur :</strong> \(error!)</article>" : "")

                    <form action="/update/\(item.id ?? 0)" method="post">
                        <input name="title" value="\(item.title)" required>
                        <input name="category" value="\(item.category)" required>
                        <input name="prepTime" type="number" min="1" value="\(item.prepTime)" required>

                        <textarea name="ingredients" required>\(item.ingredients)</textarea>
                        <textarea name="missingIngredients">\(item.missingIngredients)</textarea>
                        <textarea name="steps" required>\(item.steps)</textarea>

                        <label for="rating">Note</label>
                        <select name="rating">
                            <option value="1" \(item.rating == 1 ? "selected" : "")>1 ⭐</option>
                            <option value="2" \(item.rating == 2 ? "selected" : "")>2 ⭐</option>
                            <option value="3" \(item.rating == 3 ? "selected" : "")>3 ⭐</option>
                            <option value="4" \(item.rating == 4 ? "selected" : "")>4 ⭐</option>
                            <option value="5" \(item.rating == 5 ? "selected" : "")>5 ⭐</option>
                        </select>

                        <label>
                            <input type="checkbox" name="isCooked" \(item.isCooked ? "checked" : "")>
                            Déjà réalisée
                        </label>

                        <button type="submit">Enregistrer les modifications</button>
                    </form>

                    <form action="/delete/\(item.id ?? 0)" method="post">
                        <button type="submit" class="contrast">Supprimer cette recette</button>
                    </form>
                </main>
            </body>
            </html>
            """
        )
    }
}

// HTML helper
struct HTML: ResponseGenerator {
    let content: String

    func response(from request: Request, context: some RequestContext) throws -> Response {
        Response(
            status: .ok,
            headers: [.contentType: "text/html"],
            body: .init(byteBuffer: .init(string: content))
        )
    }
}