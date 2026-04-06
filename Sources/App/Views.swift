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
            <article class="recipe-card">
                <header>
                    <div class="card-top">
                        <div>
                            <h2>\(item.title)</h2>
                            <p class="category-badge">\(item.category)</p>
                        </div>
                        <div class="rating-box">
                            <p>\(stars(item.rating))</p>
                            <small>\(item.rating)/5</small>
                        </div>
                    </div>
                </header>

                <div class="recipe-meta">
                    <p><strong>⏱ Temps :</strong> \(item.prepTime) min</p>
                    <p><strong>📌 Statut :</strong> \(item.isCooked ? "✅ Déjà faite" : "🕒 À essayer")</p>
                </div>

                <p><strong>🧂 Ingrédients :</strong><br>\(item.ingredients)</p>
                <p><strong>🛒 Ingrédients manquants :</strong><br>\(item.missingIngredients.isEmpty ? "Aucun 🎉" : item.missingIngredients)</p>
                <p><strong>👨‍🍳 Étapes :</strong><br>\(item.steps)</p>

                <div class="button-grid">
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

                <p><a href="/recipe/\(item.id ?? 0)">✏️ Voir / Modifier la recette</a></p>
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
                    body {
                        background: linear-gradient(to bottom, #fffaf5, #fff);
                    }

                    .hero {
                        margin: 2rem 0 1rem 0;
                        text-align: center;
                    }

                    .hero h1 {
                        margin-bottom: 0.5rem;
                    }

                    .hero p {
                        color: #666;
                    }

                    .top-actions {
                        margin: 2rem 0;
                    }

                    details.recipe-form {
                        background: white;
                        border: 1px solid #e5e7eb;
                        border-radius: 16px;
                        padding: 1rem 1.25rem;
                        box-shadow: 0 8px 24px rgba(0,0,0,0.05);
                    }

                    details.recipe-form summary {
                        cursor: pointer;
                        font-size: 1.1rem;
                        font-weight: 700;
                        list-style: none;
                    }

                    details.recipe-form summary::-webkit-details-marker {
                        display: none;
                    }

                    details.recipe-form summary::after {
                        content: "▼";
                        float: right;
                        font-size: 0.9rem;
                    }

                    details.recipe-form[open] summary::after {
                        content: "▲";
                    }

                    .search-box,
                    .recipe-section {
                        margin-top: 2rem;
                    }

                    .recipe-card {
                        border-radius: 20px;
                        border: 1px solid #ececec;
                        box-shadow: 0 10px 25px rgba(0,0,0,0.05);
                        background: white;
                    }

                    .card-top {
                        display: flex;
                        justify-content: space-between;
                        align-items: start;
                        gap: 1rem;
                    }

                    .category-badge {
                        display: inline-block;
                        background: #f3f4f6;
                        padding: 0.35rem 0.7rem;
                        border-radius: 999px;
                        font-size: 0.85rem;
                        margin-top: 0.25rem;
                    }

                    .rating-box {
                        text-align: right;
                        min-width: 80px;
                    }

                    .recipe-meta {
                        display: grid;
                        grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
                        gap: 0.5rem;
                        margin: 1rem 0;
                    }

                    .button-grid {
                        display: grid;
                        grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
                        gap: 0.75rem;
                        margin-top: 1rem;
                    }

                    .button-grid form {
                        margin: 0;
                    }

                    .button-grid button,
                    .button-grid select {
                        width: 100%;
                    }

                    .empty-box {
                        text-align: center;
                        padding: 2rem;
                        background: white;
                        border-radius: 16px;
                        border: 1px dashed #d1d5db;
                    }

                    .error-box {
                        background: #fff4f4;
                        border: 1px solid #f3b1b1;
                        color: #8a1f1f;
                        padding: 1rem;
                        border-radius: 12px;
                        margin-top: 1rem;
                    }

                    footer {
                        margin: 3rem 0 2rem 0;
                        text-align: center;
                        color: #888;
                        font-size: 0.9rem;
                    }
                </style>
            </head>
            <body class="container">
                <main>
                    <section class="hero">
                        <h1>🍲 Carnet de recettes</h1>
                        <p>Ajoute, organise et note tes recettes préférées.</p>
                    </section>

                    \(error != nil ? "<div class='error-box'><strong>Erreur :</strong> \(error!)</div>" : "")

                    <section class="search-box">
                        <h2>🔍 Recherche</h2>
                        <form action="/" method="get">
                            <input type="search" name="search" placeholder="Rechercher une recette, une catégorie..." value="\(search)">
                            <button type="submit">Rechercher</button>
                        </form>
                    </section>

                    <section class="top-actions">
                        <details class="recipe-form">
                            <summary>➕ Ajouter une recette</summary>

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
                        </details>
                    </section>

                    <section class="recipe-section">
                        <h2>📚 Toutes les recettes</h2>
                        \(items.isEmpty ? "<div class='empty-box'><p>Aucune recette trouvée.</p></div>" : rows)
                    </section>

                    <footer>
                        <p>Projet final Swift CRUD App — Hummingbird 2 + SQLite</p>
                    </footer>
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

                <style>
                    body {
                        background: linear-gradient(to bottom, #fffaf5, #fff);
                    }

                    .detail-card {
                        background: white;
                        padding: 2rem;
                        border-radius: 20px;
                        box-shadow: 0 10px 25px rgba(0,0,0,0.05);
                        border: 1px solid #ececec;
                        margin-top: 2rem;
                    }

                    .error-box {
                        background: #fff4f4;
                        border: 1px solid #f3b1b1;
                        color: #8a1f1f;
                        padding: 1rem;
                        border-radius: 12px;
                        margin: 1rem 0;
                    }
                </style>
            </head>
            <body class="container">
                <main>
                    <p><a href="/">← Retour à l'accueil</a></p>

                    <section class="detail-card">
                        <h1>🍽️ Modifier la recette</h1>

                        \(error != nil ? "<div class='error-box'><strong>Erreur :</strong> \(error!)</div>" : "")

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
                    </section>
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