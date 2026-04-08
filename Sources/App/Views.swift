import Foundation
import Hummingbird

struct Views {

    static let categories = CategorieRecette.allCases.map { $0.rawValue }

    static func etoiles(_ note: Int?) -> String {
        guard let note else { return "Pas encore notée" }
        let noteSecurisee = max(1, min(5, note))
        return String(repeating: "⭐", count: noteSecurisee)
    }

    static func badgeStatut(_ dejaFaite: Bool) -> String {
        dejaFaite
            ? "<span class='badge badge-success'>✅ Déjà faite</span>"
            : "<span class='badge badge-warning'>🕒 À essayer</span>"
    }

    static func noteHTML(_ item: Recette) -> String {
        if item.dejaFaite, let note = item.note {
            return """
                <div class="recipe-rating">
                    <div class="stars">\(etoiles(note))</div>
                    <small>\(note)/5</small>
                </div>
                """
        } else {
            return """
                <div class="recipe-rating muted-rating">
                    <div class="stars">📝</div>
                    <small>Pas encore faite</small>
                </div>
                """
        }
    }

    static func categoryOptions(selected: String? = nil) -> String {
        categories.map { category in
            let isSelected = selected == category ? "selected" : ""
            return "<option value='\(category)' \(isSelected)>\(category)</option>"
        }.joined()
    }

    static func baseStyles() -> String {
        """
        <style>
            :root {
                --primary: #e67e22;
                --primary-hover: #cf711d;
                --card-bg: rgba(255, 255, 255, 0.92);
                --border-soft: rgba(0, 0, 0, 0.08);
                --text-soft: #6b7280;
                --success-bg: #e8fff2;
                --success-text: #0f8a4b;
                --warning-bg: #fff6e8;
                --warning-text: #b76a00;
                --category-bg: #f4f1ff;
                --category-text: #6b46c1;
                --surface-soft: rgba(249, 250, 251, 0.9);
            }

            body {
                min-height: 100vh;
                background:
                    radial-gradient(circle at top left, rgba(255, 216, 176, 0.5), transparent 25%),
                    radial-gradient(circle at top right, rgba(255, 231, 204, 0.7), transparent 30%),
                    linear-gradient(180deg, #fffaf5 0%, #fff7f0 100%);
                color: #1f2937;
            }

            .container {
                max-width: 1100px;
                padding-top: 1.2rem;
                padding-bottom: 4rem;
            }

            .topbar {
                display: flex;
                justify-content: space-between;
                align-items: center;
                gap: 1rem;
                flex-wrap: wrap;
                margin-bottom: 1.5rem;
            }

            .glass-panel, .page-card, .recipe-card {
                background: var(--card-bg);
                border: 1px solid var(--border-soft);
                border-radius: 24px;
                box-shadow: 0 20px 50px rgba(0,0,0,0.08);
                padding: 1.4rem;
            }

            .search-grid {
                display: grid;
                grid-template-columns: 1fr auto;
                gap: 0.8rem;
                align-items: end;
            }

            .search-input input {
                margin-bottom: 0;
                padding-left: 1rem;
                border-radius: 16px;
                background: rgba(255,255,255,0.95);
                border: 1px solid rgba(230, 126, 34, 0.18);
                box-shadow: inset 0 2px 6px rgba(0,0,0,0.03);
            }

            .search-actions {
                display: flex;
                gap: 0.75rem;
                flex-wrap: wrap;
                align-items: center;
            }

            .search-actions button,
            .search-actions a[role="button"] {
                border-radius: 16px !important;
                padding: 0.9rem 1.25rem !important;
                font-weight: 700 !important;
                border: none !important;
                box-shadow: 0 10px 20px rgba(230,126,34,0.18);
                transition: all 0.18s ease;
            }

            .search-actions button {
                background: linear-gradient(135deg, #ff9f43, #e67e22) !important;
                color: white !important;
            }

            .search-actions button:hover {
                transform: translateY(-2px);
                box-shadow: 0 14px 24px rgba(230,126,34,0.25);
            }

            .search-actions a[role="button"] {
                background: white !important;
                color: #e67e22 !important;
                border: 1px solid rgba(230,126,34,0.22) !important;
            }

            .search-actions a[role="button"]:hover {
                transform: translateY(-2px);
                background: #fff7ef !important;
            }

            .recipes-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
                gap: 1.4rem;
            }

            .recipe-header {
                display: flex;
                justify-content: space-between;
                align-items: flex-start;
                gap: 1rem;
                margin-bottom: 1rem;
            }

            .badge {
                display: inline-flex;
                align-items: center;
                gap: 0.35rem;
                border-radius: 999px;
                padding: 0.45rem 0.8rem;
                font-size: 0.8rem;
                font-weight: 700;
            }

            .badge-category { background: var(--category-bg); color: var(--category-text); }
            .badge-success { background: var(--success-bg); color: var(--success-text); }
            .badge-warning { background: var(--warning-bg); color: var(--warning-text); }

            .recipe-rating {
                text-align: right;
                min-width: 110px;
                background: rgba(255, 248, 220, 0.7);
                padding: 0.8rem;
                border-radius: 18px;
            }

            .info-grid {
                display: grid;
                grid-template-columns: repeat(3, 1fr);
                gap: 0.8rem;
                margin-bottom: 1rem;
            }

            .info-box, .recipe-section-box {
                background: var(--surface-soft);
                border: 1px solid rgba(0,0,0,0.05);
                border-radius: 18px;
                padding: 1rem;
                margin-top: 0.85rem;
            }

            .inline-form {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 0.7rem;
            }

            .form-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
                gap: 1rem;
            }

            .form-full { grid-column: 1 / -1; }

            textarea {
                min-height: 130px;
                resize: vertical;
            }

            .auth-card {
                max-width: 500px;
                margin: 4rem auto;
            }

            .auth-links {
                margin-top: 1rem;
                text-align: center;
            }

            .shopping-list {
                list-style: none;
                padding: 0;
                margin-top: 1rem;
            }

            .shopping-list li {
                background: rgba(255,255,255,0.95);
                border: 1px solid rgba(0,0,0,0.06);
                padding: 1rem;
                border-radius: 16px;
                margin-bottom: 0.75rem;
                font-weight: 600;
            }

            @media (max-width: 768px) {
                .recipe-header,
                .search-grid,
                .inline-form,
                .info-grid {
                    grid-template-columns: 1fr;
                    flex-direction: column;
                }
            }
        </style>
        """
    }

    static func renderWelcomePage() -> HTML {
        HTML(
            content: """
                <!DOCTYPE html>
                <html lang="fr">
                <head>
                    <meta charset="utf-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1">
                    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@picocss/pico@2/css/pico.min.css">
                    <title>Bienvenue</title>
                    \(baseStyles())
                </head>
                <body class="container">
                    <main class="page-card auth-card">
                        <h1>🍲 Mon carnet de recettes</h1>
                        <p>Connecte-toi ou crée un compte pour gérer tes recettes.</p>
                        <div style="display:flex; gap:1rem; flex-wrap:wrap;">
                            <a href="/login" role="button">🔐 Se connecter</a>
                            <a href="/register" role="button" class="secondary">📝 S’inscrire</a>
                        </div>
                    </main>
                </body>
                </html>
                """)
    }

    static func renderLoginPage() -> HTML {
        HTML(
            content: """
                <!DOCTYPE html>
                <html lang="fr">
                <head>
                    <meta charset="utf-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1">
                    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@picocss/pico@2/css/pico.min.css">
                    <title>Connexion</title>
                    \(baseStyles())
                </head>
                <body class="container">
                    <main class="page-card auth-card">
                        <h1>🔐 Connexion</h1>
                        <form action="/login" method="post">
                            <label>Email</label>
                            <input type="email" name="email" required>

                            <label>Mot de passe</label>
                            <input type="password" name="motDePasse" required>

                            <button type="submit">Se connecter</button>
                        </form>

                        <div class="auth-links">
                            <p>Pas encore de compte ? <a href="/register">Créer un compte</a></p>
                        </div>
                    </main>
                </body>
                </html>
                """)
    }

    static func renderRegisterPage() -> HTML {
        HTML(
            content: """
                <!DOCTYPE html>
                <html lang="fr">
                <head>
                    <meta charset="utf-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1">
                    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@picocss/pico@2/css/pico.min.css">
                    <title>Inscription</title>
                    \(baseStyles())
                </head>
                <body class="container">
                    <main class="page-card auth-card">
                        <h1>📝 Inscription</h1>
                        <form action="/register" method="post">
                            <label>Nom</label>
                            <input type="text" name="nom" required>

                            <label>Email</label>
                            <input type="email" name="email" required>

                            <label>Mot de passe</label>
                            <input type="password" name="motDePasse" required>

                            <button type="submit">Créer mon compte</button>
                        </form>

                        <div class="auth-links">
                            <p>Déjà un compte ? <a href="/login">Se connecter</a></p>
                        </div>
                    </main>
                </body>
                </html>
                """)
    }

    static func renderIndex(
        items: [Recette], search: String = "", error: String? = nil,
        userName: String = "Utilisateur"
    ) -> HTML {
        let rows = items.map { item in
            let noteSection = noteHTML(item)

            let ratingForm =
                item.dejaFaite
                ? """
                <form action="/rate/\(item.id ?? 0)" method="post" class="inline-form">
                    <select name="note">
                        <option value="1">1 ⭐</option>
                        <option value="2">2 ⭐</option>
                        <option value="3">3 ⭐</option>
                        <option value="4">4 ⭐</option>
                        <option value="5">5 ⭐</option>
                    </select>
                    <button type="submit">Noter</button>
                </form>
                """
                : "<button type='button' class='secondary' disabled>Note disponible après réalisation</button>"

            return """
                <article class="recipe-card">
                    <div class="recipe-header">
                        <div>
                            <h2>\(item.titre)</h2>
                            <div style="display:flex; gap:0.5rem; flex-wrap:wrap;">
                                <span class="badge badge-category">🍽 \(item.categorie)</span>
                                \(badgeStatut(item.dejaFaite))
                            </div>
                        </div>
                        \(noteSection)
                    </div>

                    <div class="info-grid">
                        <div class="info-box"><strong>⏱ \(item.tempsPreparation) min</strong></div>
                        <div class="info-box"><strong>🧂 \(item.ingredients.components(separatedBy: ",").count) ingrédients</strong></div>
                        <div class="info-box"><strong>🛒 \(item.ingredientsManquants.isEmpty ? 0 : item.ingredientsManquants.components(separatedBy: ",").count) manquants</strong></div>
                    </div>

                    <div class="recipe-section-box">
                        <h3>🧂 Ingrédients</h3>
                        <p>\(item.ingredients)</p>
                    </div>

                    <div class="recipe-section-box">
                        <h3>👨‍🍳 Étapes</h3>
                        <p>\(item.etapes.replacingOccurrences(of: "\n", with: "<br>"))</p>
                    </div>

                    <div style="display:grid; gap:0.8rem; margin-top:1rem;">
                        <form action="/toggle-cooked/\(item.id ?? 0)" method="post">
                            <button type="submit" class="outline">Basculer le statut</button>
                        </form>

                        \(ratingForm)

                        <form action="/delete/\(item.id ?? 0)" method="post">
                            <button type="submit" class="contrast">Supprimer</button>
                        </form>
                    </div>

                    <div style="display:flex; gap:1rem; flex-wrap:wrap; margin-top:1rem;">
                        <a href="/recipe/\(item.id ?? 0)">👁 Voir</a>
                        <a href="/edit/\(item.id ?? 0)">✏️ Modifier</a>
                    </div>
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
                    \(baseStyles())
                </head>
                <body class="container">
                    <main>
                        <div class="topbar">
                            <div>
                                <h1>🍲 Mon carnet de recettes</h1>
                                <p>Bienvenue, <strong>\(userName)</strong> 👋</p>
                            </div>
                            <div style="display:flex; gap:0.8rem; flex-wrap:wrap;">
                                <a href="/shopping-list" role="button" class="secondary">🛒 Liste de courses</a>
                                <a href="/add" role="button">➕ Ajouter</a>
                                <a href="/logout" role="button" class="contrast">🚪 Déconnexion</a>
                            </div>
                        </div>

                        \(error != nil ? "<div><strong>\(error!)</strong></div>" : "")

                        <section class="glass-panel">
                            <form action="/" method="get">
                                <div class="search-grid">
                                    <div class="search-input">
                                        <label><strong>🔍 Rechercher une recette</strong></label>
                                        <input type="search" name="search" placeholder="Titre, catégorie, ingrédient..." value="\(search)">
                                    </div>
                                    <div class="search-actions">
                                        <button type="submit">Rechercher</button>
                                        <a href="/" role="button">Réinitialiser</a>
                                    </div>
                                </div>
                            </form>
                        </section>

                        <section style="margin-top:1.6rem;">
                            \(items.isEmpty
                        ? "<div class='page-card'><h3>Aucune recette trouvée</h3></div>"
                        : "<div class='recipes-grid'>\(rows)</div>")
                        </section>
                    </main>
                </body>
                </html>
                """)
    }

    static func renderAddRecipePage(error: String? = nil) -> HTML {
        HTML(
            content: """
                <!DOCTYPE html>
                <html lang="fr">
                <head>
                    <meta charset="utf-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1">
                    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@picocss/pico@2/css/pico.min.css">
                    <title>Ajouter une recette</title>
                    \(baseStyles())
                </head>
                <body class="container">
                    <main>
                        <a href="/">← Retour</a>
                        <section class="page-card">
                            <h1>➕ Ajouter une recette</h1>

                            <form action="/add" method="post">
                                <div class="form-grid">
                                    <div>
                                        <label>Titre</label>
                                        <input name="titre" required>
                                    </div>

                                    <div>
                                        <label>Catégorie</label>
                                        <select name="categorie" required>
                                            \(categoryOptions())
                                        </select>
                                    </div>

                                    <div>
                                        <label>Temps de préparation (min)</label>
                                        <input name="tempsPreparation" type="number" min="1" required>
                                    </div>

                                    <div>
                                        <label>Note initiale</label>
                                        <select name="note">
                                            <option value="1">1 ⭐</option>
                                            <option value="2">2 ⭐</option>
                                            <option value="3" selected>3 ⭐</option>
                                            <option value="4">4 ⭐</option>
                                            <option value="5">5 ⭐</option>
                                        </select>
                                    </div>

                                    <div class="form-full">
                                        <label>Ingrédients</label>
                                        <textarea name="ingredients" required></textarea>
                                    </div>

                                    <div class="form-full">
                                        <label>Ingrédients manquants</label>
                                        <textarea name="ingredientsManquants"></textarea>
                                    </div>

                                    <div class="form-full">
                                        <label>Étapes</label>
                                        <textarea name="etapes" required></textarea>
                                    </div>

                                    <div class="form-full">
                                        <label><input type="checkbox" name="dejaFaite"> J’ai déjà réalisé cette recette</label>
                                    </div>
                                </div>

                                <button type="submit">Ajouter la recette</button>
                            </form>
                        </section>
                    </main>
                </body>
                </html>
                """)
    }

    static func renderRecipeDetail(item: Recette) -> HTML {
        HTML(
            content: """
                <!DOCTYPE html>
                <html lang="fr">
                <head>
                    <meta charset="utf-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1">
                    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@picocss/pico@2/css/pico.min.css">
                    <title>\(item.titre)</title>
                    \(baseStyles())
                </head>
                <body class="container">
                    <main>
                        <a href="/">← Retour</a>
                        <section class="page-card">
                            <h1>👁 \(item.titre)</h1>
                            <div class="recipe-section-box"><h3>Catégorie</h3><p>\(item.categorie)</p></div>
                            <div class="recipe-section-box"><h3>Temps</h3><p>\(item.tempsPreparation) min</p></div>
                            <div class="recipe-section-box"><h3>Ingrédients</h3><p>\(item.ingredients)</p></div>
                            <div class="recipe-section-box"><h3>Ingrédients manquants</h3><p>\(item.ingredientsManquants.isEmpty ? "Aucun 🎉" : item.ingredientsManquants)</p></div>
                            <div class="recipe-section-box"><h3>Étapes</h3><p>\(item.etapes.replacingOccurrences(of: "\n", with: "<br>"))</p></div>
                            <a href="/edit/\(item.id ?? 0)" role="button">✏️ Modifier</a>
                        </section>
                    </main>
                </body>
                </html>
                """)
    }

    static func renderEditRecipePage(item: Recette) -> HTML {
        HTML(
            content: """
                <!DOCTYPE html>
                <html lang="fr">
                <head>
                    <meta charset="utf-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1">
                    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@picocss/pico@2/css/pico.min.css">
                    <title>Modifier \(item.titre)</title>
                    \(baseStyles())
                </head>
                <body class="container">
                    <main>
                        <a href="/recipe/\(item.id ?? 0)">← Retour</a>
                        <section class="page-card">
                            <h1>✏️ Modifier la recette</h1>

                            <form action="/update/\(item.id ?? 0)" method="post">
                                <div class="form-grid">
                                    <div>
                                        <label>Titre</label>
                                        <input name="titre" value="\(item.titre)" required>
                                    </div>

                                    <div>
                                        <label>Catégorie</label>
                                        <select name="categorie" required>
                                            \(categoryOptions(selected: item.categorie))
                                        </select>
                                    </div>

                                    <div>
                                        <label>Temps de préparation</label>
                                        <input name="tempsPreparation" type="number" min="1" value="\(item.tempsPreparation)" required>
                                    </div>

                                    <div>
                                        <label>Note</label>
                                        <select name="note">
                                            <option value="1" \((item.note ?? 3) == 1 ? "selected" : "")>1 ⭐</option>
                                            <option value="2" \((item.note ?? 3) == 2 ? "selected" : "")>2 ⭐</option>
                                            <option value="3" \((item.note ?? 3) == 3 ? "selected" : "")>3 ⭐</option>
                                            <option value="4" \((item.note ?? 3) == 4 ? "selected" : "")>4 ⭐</option>
                                            <option value="5" \((item.note ?? 3) == 5 ? "selected" : "")>5 ⭐</option>
                                        </select>
                                    </div>

                                    <div class="form-full">
                                        <label>Ingrédients</label>
                                        <textarea name="ingredients" required>\(item.ingredients)</textarea>
                                    </div>

                                    <div class="form-full">
                                        <label>Ingrédients manquants</label>
                                        <textarea name="ingredientsManquants">\(item.ingredientsManquants)</textarea>
                                    </div>

                                    <div class="form-full">
                                        <label>Étapes</label>
                                        <textarea name="etapes" required>\(item.etapes)</textarea>
                                    </div>

                                    <div class="form-full">
                                        <label><input type="checkbox" name="dejaFaite" \(item.dejaFaite ? "checked" : "")> Déjà réalisée</label>
                                    </div>
                                </div>

                                <button type="submit">Enregistrer</button>
                            </form>
                        </section>
                    </main>
                </body>
                </html>
                """)
    }

    static func renderShoppingListPage(items: [String]) -> HTML {
        let content =
            items.isEmpty
            ? "<p>Aucun ingrédient manquant 🎉</p>"
            : "<ul class='shopping-list'>" + items.map { "<li>🛒 \($0)</li>" }.joined() + "</ul>"

        return HTML(
            content: """
                <!DOCTYPE html>
                <html lang="fr">
                <head>
                    <meta charset="utf-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1">
                    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@picocss/pico@2/css/pico.min.css">
                    <title>Liste de courses</title>
                    \(baseStyles())
                </head>
                <body class="container">
                    <main>
                        <a href="/">← Retour</a>
                        <section class="page-card">
                            <h1>🛒 Ma liste de courses</h1>
                            <p>Voici tous les ingrédients manquants regroupés automatiquement.</p>
                            \(content)
                        </section>
                    </main>
                </body>
                </html>
                """)
    }
}

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
