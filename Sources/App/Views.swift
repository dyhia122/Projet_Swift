import Foundation
import Hummingbird

struct Views {

    static let categories = [
        "Italienne",
        "Dessert",
        "Petit-déjeuner",
        "Salade",
        "Plat principal",
        "Soupe",
        "Boisson",
        "Snack",
        "Végétarienne",
        "Autre",
    ]

    static func etoiles(_ note: Int?) -> String {
        guard let note else { return "—" }
        let noteSecurisee = max(1, min(5, note))
        return String(repeating: "⭐", count: noteSecurisee)
    }

    static func badgeStatut(_ dejaFaite: Bool) -> String {
        dejaFaite
            ? "<span class='badge badge-success'>✅ Déjà faite</span>"
            : "<span class='badge badge-warning'>🕒 À essayer</span>"
    }

    static func optionsCategories(selected: String? = nil) -> String {
        categories.map { cat in
            "<option value='\(cat)' \(selected == cat ? "selected" : "")>\(cat)</option>"
        }.joined()
    }

    static func noteOptions(selected: Int? = nil) -> String {
        (1...5).map { n in
            "<option value='\(n)' \(selected == n ? "selected" : "")>\(n) ⭐</option>"
        }.joined()
    }

    static func renderIndex(items: [Recette], search: String = "", error: String? = nil) -> HTML {

        let rows = items.map { item in
            """
            <article class="recipe-card">
                <div class="recipe-header">
                    <div>
                        <p class="mini-label">RECETTE</p>
                        <h2>\(item.titre)</h2>
                        <div class="recipe-badges">
                            <span class="badge badge-category">🍽 \(item.categorie)</span>
                            \(badgeStatut(item.dejaFaite))
                        </div>
                    </div>

                    <div class="recipe-rating">
                        \(item.dejaFaite
                            ? """
                            <div class="stars">\(etoiles(item.note))</div>
                            <small>\(item.note ?? 0)/5</small>
                            """
                            : """
                            <div class="stars">🚫</div>
                            <small>Pas encore notée</small>
                            """)
                    </div>
                </div>

                <div class="info-grid">
                    <div class="info-box">
                        <span>⏱ Temps</span>
                        <strong>\(item.tempsPreparation) min</strong>
                    </div>
                    <div class="info-box">
                        <span>🧂 Ingrédients</span>
                        <strong>\(item.ingredients.components(separatedBy: ",").count)</strong>
                    </div>
                    <div class="info-box">
                        <span>🛒 Manquants</span>
                        <strong>\(item.ingredientsManquants.isEmpty ? 0 : item.ingredientsManquants.components(separatedBy: ",").count)</strong>
                    </div>
                </div>

                <div class="recipe-section-box">
                    <h3>🧂 Ingrédients</h3>
                    <p>\(item.ingredients)</p>
                </div>

                <div class="recipe-section-box missing-box">
                    <h3>🛒 Ingrédients manquants</h3>
                    <p>\(item.ingredientsManquants.isEmpty ? "Aucun ingrédient manquant 🎉" : item.ingredientsManquants)</p>
                </div>

                <div class="recipe-section-box">
                    <h3>👨‍🍳 Étapes</h3>
                    <p>\(item.etapes.replacingOccurrences(of: "\n", with: "<br>"))</p>
                </div>

                <div class="action-grid">
                    <form action="/toggle-cooked/\(item.id ?? 0)" method="post">
                        <button type="submit" class="outline">Basculer le statut</button>
                    </form>

                    \(item.dejaFaite
                        ? """
                        <form action="/rate/\(item.id ?? 0)" method="post" class="inline-form">
                            <select name="note">
                                \(noteOptions(selected: item.note))
                            </select>
                            <button type="submit">Noter</button>
                        </form>
                        """
                        : """
                        <div class="disabled-box">La note sera disponible une fois la recette réalisée.</div>
                        """)

                    <form action="/delete/\(item.id ?? 0)" method="post">
                        <button type="submit" class="contrast">Supprimer</button>
                    </form>
                </div>

                <div class="link-row">
                    <a href="/recipe/\(item.id ?? 0)" class="detail-link">👁 Voir la recette</a>
                    <a href="/recipe/\(item.id ?? 0)/edit" class="detail-link">✏️ Modifier</a>
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

                    <style>
                        :root {
                            --primary: #e67e22;
                            --primary-hover: #cf711d;
                            --primary-focus: rgba(230, 126, 34, 0.2);
                            --card-bg: rgba(255, 255, 255, 0.85);
                            --border-soft: rgba(0, 0, 0, 0.08);
                            --text-soft: #6b7280;
                            --success-bg: #e8fff2;
                            --success-text: #0f8a4b;
                            --warning-bg: #fff6e8;
                            --warning-text: #b76a00;
                            --category-bg: #f4f1ff;
                            --category-text: #6b46c1;
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
                            padding-top: 2rem;
                            padding-bottom: 4rem;
                        }

                        .hero {
                            text-align: center;
                            padding: 2rem 1rem 1rem 1rem;
                            margin-bottom: 2rem;
                        }

                        .hero h1 {
                            font-size: clamp(2.2rem, 5vw, 4rem);
                            margin-bottom: 0.6rem;
                            line-height: 1.05;
                        }

                        .hero p {
                            font-size: 1.08rem;
                            color: var(--text-soft);
                            max-width: 700px;
                            margin: 0 auto;
                        }

                        .hero-chip {
                            display: inline-block;
                            background: rgba(255,255,255,0.8);
                            border: 1px solid var(--border-soft);
                            padding: 0.5rem 0.9rem;
                            border-radius: 999px;
                            margin-bottom: 1rem;
                            font-size: 0.9rem;
                        }

                        .glass-panel {
                            background: var(--card-bg);
                            border: 1px solid var(--border-soft);
                            border-radius: 24px;
                            box-shadow: 0 20px 50px rgba(0,0,0,0.08);
                            padding: 1.5rem;
                        }

                        .section-spacing {
                            margin-top: 2rem;
                        }

                        .error-box {
                            background: #fff1f1;
                            color: #9b1c1c;
                            border: 1px solid #f2b8b8;
                            padding: 1rem 1.1rem;
                            border-radius: 16px;
                            margin-bottom: 1.5rem;
                            font-weight: 600;
                        }

                        .form-grid {
                            display: grid;
                            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
                            gap: 1rem;
                            margin-top: 1.25rem;
                        }

                        .form-full {
                            grid-column: 1 / -1;
                        }

                        textarea {
                            min-height: 130px;
                            resize: vertical;
                        }

                        .recipes-grid {
                            display: grid;
                            grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
                            gap: 1.4rem;
                        }

                        .recipe-card {
                            background: rgba(255,255,255,0.92);
                            border: 1px solid var(--border-soft);
                            border-radius: 26px;
                            padding: 1.35rem;
                            box-shadow: 0 18px 40px rgba(0,0,0,0.07);
                        }

                        .recipe-header {
                            display: flex;
                            justify-content: space-between;
                            align-items: flex-start;
                            gap: 1rem;
                            margin-bottom: 1rem;
                        }

                        .mini-label {
                            font-size: 0.72rem;
                            letter-spacing: 0.12em;
                            color: var(--text-soft);
                            margin-bottom: 0.35rem;
                            font-weight: 700;
                        }

                        .recipe-badges {
                            display: flex;
                            gap: 0.5rem;
                            flex-wrap: wrap;
                            margin-top: 0.75rem;
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

                        .badge-category {
                            background: var(--category-bg);
                            color: var(--category-text);
                        }

                        .badge-success {
                            background: var(--success-bg);
                            color: var(--success-text);
                        }

                        .badge-warning {
                            background: var(--warning-bg);
                            color: var(--warning-text);
                        }

                        .recipe-rating {
                            text-align: right;
                            min-width: 110px;
                            background: rgba(255, 248, 220, 0.7);
                            border: 1px solid rgba(230, 200, 100, 0.25);
                            padding: 0.8rem;
                            border-radius: 18px;
                        }

                        .stars {
                            font-size: 1.15rem;
                            margin-bottom: 0.2rem;
                        }

                        .info-grid {
                            display: grid;
                            grid-template-columns: repeat(3, 1fr);
                            gap: 0.8rem;
                            margin-bottom: 1rem;
                        }

                        .info-box {
                            background: rgba(248, 250, 252, 0.95);
                            border: 1px solid rgba(0,0,0,0.05);
                            border-radius: 18px;
                            padding: 0.85rem;
                        }

                        .recipe-section-box {
                            background: rgba(249, 250, 251, 0.85);
                            border: 1px solid rgba(0,0,0,0.05);
                            border-radius: 18px;
                            padding: 1rem;
                            margin-top: 0.85rem;
                        }

                        .missing-box {
                            border-left: 5px solid #f59e0b;
                        }

                        .action-grid {
                            display: grid;
                            gap: 0.8rem;
                            margin-top: 1.2rem;
                        }

                        .inline-form {
                            display: grid;
                            grid-template-columns: 1fr 1fr;
                            gap: 0.7rem;
                        }

                        .disabled-box {
                            background: #f3f4f6;
                            border: 1px dashed #d1d5db;
                            padding: 1rem;
                            border-radius: 14px;
                            color: #6b7280;
                            font-size: 0.95rem;
                        }

                        .link-row {
                            display: flex;
                            gap: 1rem;
                            margin-top: 1rem;
                            flex-wrap: wrap;
                        }

                        .detail-link {
                            font-weight: 700;
                            text-decoration: none;
                        }
                    </style>
                </head>
                <body class="container">
                    <main>
                        <section class="hero">
                            <div class="hero-chip">Projet Swift CRUD • Hummingbird 2 • SQLite</div>
                            <h1>🍲 Mon carnet de recettes</h1>
                            <p>Organise tes recettes, note-les, suis ce qu’il te manque et garde tout au même endroit.</p>
                        </section>

                        \(error != nil ? "<div class='error-box'>⚠️ \(error!)</div>" : "")

                        <section class="glass-panel">
                            <form action="/" method="get">
                                <label for="search"><strong>🔍 Rechercher une recette</strong></label>
                                <input type="search" name="search" placeholder="Ex: pâtes, dessert, salade..." value="\(search)">
                            </form>
                        </section>

                        <section class="section-spacing glass-panel">
                            <h2>➕ Ajouter une nouvelle recette</h2>

                            <form action="/add" method="post">
                                <div class="form-grid">
                                    <div>
                                        <label>Titre</label>
                                        <input name="titre" placeholder="Ex: Tiramisu maison" required>
                                    </div>

                                    <div>
                                        <label>Catégorie</label>
                                        <select name="categorie" required>
                                            <option value="">-- Choisir une catégorie --</option>
                                            \(optionsCategories())
                                        </select>
                                    </div>

                                    <div>
                                        <label>Temps de préparation (min)</label>
                                        <input name="tempsPreparation" type="number" min="1" placeholder="30" required>
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
                                        <label>
                                            <input type="checkbox" name="dejaFaite" id="dejaFaiteAdd" onchange="toggleNoteAdd()">
                                            J’ai déjà réalisé cette recette
                                        </label>
                                    </div>

                                    <div id="noteSectionAdd" class="form-full" style="display:none;">
                                        <label>Note</label>
                                        <select name="note">
                                            \(noteOptions(selected: 3))
                                        </select>
                                    </div>
                                </div>

                                <button type="submit">Ajouter la recette</button>
                            </form>
                        </section>

                        <section class="section-spacing">
                            <h2>📚 Mes recettes (\(items.count))</h2>

                            \(items.isEmpty
                            ? "<div class='glass-panel'><h3>Aucune recette trouvée</h3><p>Ajoute ta première recette 👨‍🍳</p></div>"
                            : "<div class='recipes-grid'>\(rows)</div>")
                        </section>
                    </main>

                    <script>
                        function toggleNoteAdd() {
                            const checkbox = document.getElementById('dejaFaiteAdd');
                            const noteSection = document.getElementById('noteSectionAdd');
                            noteSection.style.display = checkbox.checked ? 'block' : 'none';
                        }
                    </script>
                </body>
                </html>
                """
        )
    }

    static func renderRecipeView(item: Recette) -> HTML {
        HTML(
            content: """
                <!DOCTYPE html>
                <html lang="fr">
                <head>
                    <meta charset="utf-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1">
                    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@picocss/pico@2/css/pico.min.css">
                    <title>\(item.titre)</title>
                </head>
                <body class="container">
                    <main style="max-width:900px; margin:auto; padding:2rem;">
                        <a href="/">← Retour</a>

                        <article>
                            <h1>👁 \(item.titre)</h1>
                            <p><strong>Catégorie :</strong> \(item.categorie)</p>
                            <p><strong>Temps :</strong> \(item.tempsPreparation) min</p>
                            <p><strong>Statut :</strong> \(item.dejaFaite ? "Déjà faite" : "Pas encore faite")</p>
                            <p><strong>Note :</strong> \(item.dejaFaite ? "\(item.note ?? 0)/5" : "Pas de note")</p>

                            <hr>

                            <h3>🧂 Ingrédients</h3>
                            <p>\(item.ingredients)</p>

                            <h3>🛒 Ingrédients manquants</h3>
                            <p>\(item.ingredientsManquants.isEmpty ? "Aucun 🎉" : item.ingredientsManquants)</p>

                            <h3>👨‍🍳 Étapes</h3>
                            <p>\(item.etapes.replacingOccurrences(of: "\n", with: "<br>"))</p>

                            <hr>

                            <a href="/recipe/\(item.id ?? 0)/edit" role="button">✏️ Modifier cette recette</a>
                        </article>
                    </main>
                </body>
                </html>
                """
        )
    }

    static func renderRecipeEdit(item: Recette, error: String? = nil) -> HTML {
        HTML(
            content: """
                <!DOCTYPE html>
                <html lang="fr">
                <head>
                    <meta charset="utf-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1">
                    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@picocss/pico@2/css/pico.min.css">
                    <title>Modifier \(item.titre)</title>
                </head>
                <body class="container">
                    <main style="max-width:900px; margin:auto; padding:2rem;">
                        <a href="/recipe/\(item.id ?? 0)">← Retour à la recette</a>

                        <article>
                            <h1>✏️ Modifier la recette</h1>

                            \(error != nil ? "<div style='background:#fff1f1;padding:1rem;border-radius:12px;'>⚠️ \(error!)</div>" : "")

                            <form action="/update/\(item.id ?? 0)" method="post">
                                <label>Titre</label>
                                <input name="titre" value="\(item.titre)" required>

                                <label>Catégorie</label>
                                <select name="categorie" required>
                                    \(optionsCategories(selected: item.categorie))
                                </select>

                                <label>Temps de préparation (min)</label>
                                <input name="tempsPreparation" type="number" min="1" value="\(item.tempsPreparation)" required>

                                <label>Ingrédients</label>
                                <textarea name="ingredients" required>\(item.ingredients)</textarea>

                                <label>Ingrédients manquants</label>
                                <textarea name="ingredientsManquants">\(item.ingredientsManquants)</textarea>

                                <label>Étapes</label>
                                <textarea name="etapes" required>\(item.etapes)</textarea>

                                <label>
                                    <input type="checkbox" name="dejaFaite" id="dejaFaiteEdit" \(item.dejaFaite ? "checked" : "") onchange="toggleNoteEdit()">
                                    Déjà réalisée
                                </label>

                                <div id="noteSectionEdit" style="display:\(item.dejaFaite ? "block" : "none");">
                                    <label>Note</label>
                                    <select name="note">
                                        \(noteOptions(selected: item.note ?? 3))
                                    </select>
                                </div>

                                <button type="submit">Enregistrer</button>
                            </form>

                            <hr>

                            <form action="/delete/\(item.id ?? 0)" method="post">
                                <button type="submit" class="contrast">Supprimer cette recette</button>
                            </form>
                        </article>
                    </main>

                    <script>
                        function toggleNoteEdit() {
                            const checkbox = document.getElementById('dejaFaiteEdit');
                            const noteSection = document.getElementById('noteSectionEdit');
                            noteSection.style.display = checkbox.checked ? 'block' : 'none';
                        }
                    </script>
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
