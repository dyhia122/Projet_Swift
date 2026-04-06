import Foundation
import Hummingbird

struct Views {

    // MARK: - Helpers

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

    static func categoriesOptions(selected: String? = nil) -> String {
        Database.categoriesDisponibles.map { categorie in
            let isSelected = selected == categorie ? "selected" : ""
            return "<option value='\(categorie)' \(isSelected)>\(categorie)</option>"
        }.joined()
    }

    static func layout(title: String, content: String) -> HTML {
        HTML(
            content: """
                <!DOCTYPE html>
                <html lang="fr">
                <head>
                    <meta charset="utf-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1">
                    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@picocss/pico@2/css/pico.min.css">
                    <title>\(title)</title>

                    <style>
                        :root {
                            --primary: #f97316;
                            --primary-hover: #ea580c;
                            --primary-focus: rgba(249, 115, 22, 0.2);
                            --card-bg: rgba(255, 255, 255, 0.92);
                            --border-soft: rgba(15, 23, 42, 0.08);
                            --text-soft: #64748b;
                            --success-bg: #ecfdf5;
                            --success-text: #047857;
                            --warning-bg: #fff7ed;
                            --warning-text: #c2410c;
                            --category-bg: #f5f3ff;
                            --category-text: #6d28d9;
                            --surface: rgba(255,255,255,0.75);
                        }

                        html {
                            scroll-behavior: smooth;
                        }

                        body {
                            min-height: 100vh;
                            background:
                                radial-gradient(circle at top left, rgba(255, 237, 213, 0.9), transparent 28%),
                                radial-gradient(circle at top right, rgba(254, 215, 170, 0.55), transparent 32%),
                                linear-gradient(180deg, #fffaf5 0%, #fff7f0 100%);
                            color: #1e293b;
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
                            max-width: 720px;
                            margin: 0 auto;
                        }

                        .hero-chip {
                            display: inline-block;
                            background: rgba(255,255,255,0.85);
                            border: 1px solid var(--border-soft);
                            padding: 0.5rem 0.95rem;
                            border-radius: 999px;
                            margin-bottom: 1rem;
                            font-size: 0.9rem;
                            backdrop-filter: blur(12px);
                            box-shadow: 0 8px 24px rgba(0,0,0,0.04);
                        }

                        .glass-panel {
                            background: var(--surface);
                            backdrop-filter: blur(16px);
                            border: 1px solid var(--border-soft);
                            border-radius: 26px;
                            box-shadow: 0 22px 50px rgba(15, 23, 42, 0.08);
                            padding: 1.5rem;
                        }

                        .section-spacing {
                            margin-top: 2rem;
                        }

                        .page-shell {
                            max-width: 920px;
                            margin: 0 auto;
                        }

                        .page-card {
                            background: var(--card-bg);
                            border: 1px solid var(--border-soft);
                            border-radius: 30px;
                            padding: 2rem;
                            box-shadow: 0 24px 55px rgba(15, 23, 42, 0.08);
                        }

                        .page-header {
                            margin-bottom: 1.5rem;
                        }

                        .page-header h1 {
                            margin-bottom: 0.45rem;
                        }

                        .page-header p {
                            color: var(--text-soft);
                            margin-bottom: 0;
                        }

                        .back-link {
                            display: inline-block;
                            margin-bottom: 1rem;
                            font-weight: 700;
                            text-decoration: none;
                        }

                        .error-box {
                            background: #fff1f2;
                            color: #be123c;
                            border: 1px solid #fecdd3;
                            padding: 1rem 1.1rem;
                            border-radius: 16px;
                            margin-bottom: 1.5rem;
                            font-weight: 600;
                        }

                        .search-row {
                            display: flex;
                            gap: 1rem;
                            align-items: end;
                            flex-wrap: wrap;
                        }

                        .search-row form {
                            flex: 1;
                            margin: 0;
                        }

                        .search-row input {
                            margin-bottom: 0;
                        }

                        .top-actions {
                            display: flex;
                            justify-content: space-between;
                            align-items: center;
                            gap: 1rem;
                            flex-wrap: wrap;
                        }

                        .section-title {
                            display: flex;
                            justify-content: space-between;
                            align-items: center;
                            gap: 1rem;
                            margin-bottom: 1rem;
                            flex-wrap: wrap;
                        }

                        .section-title h2 {
                            margin: 0;
                        }

                        .count-badge {
                            background: rgba(255,255,255,0.85);
                            border: 1px solid var(--border-soft);
                            border-radius: 999px;
                            padding: 0.45rem 0.85rem;
                            font-weight: 700;
                        }

                        .recipes-grid {
                            display: grid;
                            grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
                            gap: 1.4rem;
                        }

                        .recipe-card {
                            background: rgba(255,255,255,0.96);
                            border: 1px solid var(--border-soft);
                            border-radius: 28px;
                            padding: 1.35rem;
                            box-shadow: 0 18px 40px rgba(15, 23, 42, 0.07);
                            transition: transform 0.18s ease, box-shadow 0.18s ease;
                        }

                        .recipe-card:hover {
                            transform: translateY(-5px);
                            box-shadow: 0 28px 60px rgba(15, 23, 42, 0.10);
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

                        .recipe-header h2 {
                            margin: 0;
                            font-size: 1.5rem;
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
                            min-width: 120px;
                            background: rgba(255, 248, 220, 0.7);
                            border: 1px solid rgba(230, 200, 100, 0.25);
                            padding: 0.8rem;
                            border-radius: 18px;
                        }

                        .stars {
                            font-size: 1.05rem;
                            margin-bottom: 0.2rem;
                            font-weight: 700;
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

                        .info-box span {
                            display: block;
                            font-size: 0.8rem;
                            color: var(--text-soft);
                            margin-bottom: 0.25rem;
                        }

                        .info-box strong {
                            font-size: 1rem;
                        }

                        .recipe-section-box {
                            background: rgba(249, 250, 251, 0.85);
                            border: 1px solid rgba(0,0,0,0.05);
                            border-radius: 18px;
                            padding: 1rem;
                            margin-top: 0.85rem;
                        }

                        .recipe-section-box h3 {
                            margin-top: 0;
                            margin-bottom: 0.5rem;
                            font-size: 1rem;
                        }

                        .missing-box {
                            border-left: 5px solid #f59e0b;
                        }

                        .action-grid {
                            display: grid;
                            grid-template-columns: 1fr;
                            gap: 0.8rem;
                            margin-top: 1.2rem;
                        }

                        .action-grid form {
                            margin: 0;
                        }

                        .inline-form {
                            display: grid;
                            grid-template-columns: 1fr 1fr;
                            gap: 0.7rem;
                        }

                        .link-row {
                            display: flex;
                            gap: 0.8rem;
                            flex-wrap: wrap;
                            margin-top: 1rem;
                        }

                        .empty-box {
                            text-align: center;
                            padding: 3rem 1.5rem;
                            background: rgba(255,255,255,0.82);
                            border: 1px dashed rgba(0,0,0,0.12);
                            border-radius: 24px;
                        }

                        .form-grid {
                            display: grid;
                            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
                            gap: 1rem;
                            margin-top: 1rem;
                        }

                        .form-full {
                            grid-column: 1 / -1;
                        }

                        textarea {
                            min-height: 130px;
                            resize: vertical;
                        }

                        .danger-zone {
                            margin-top: 1.5rem;
                            padding-top: 1.5rem;
                            border-top: 1px solid rgba(0,0,0,0.08);
                        }

                        .footer-note {
                            text-align: center;
                            margin-top: 3rem;
                            color: var(--text-soft);
                            font-size: 0.92rem;
                        }

                        @media (max-width: 768px) {
                            .recipe-header {
                                flex-direction: column;
                            }

                            .recipe-rating {
                                width: 100%;
                                text-align: left;
                            }

                            .info-grid {
                                grid-template-columns: 1fr;
                            }

                            .inline-form {
                                grid-template-columns: 1fr;
                            }

                            .page-card {
                                padding: 1.2rem;
                            }

                            .top-actions {
                                flex-direction: column;
                                align-items: stretch;
                            }
                        }
                    </style>
                </head>
                <body class="container">
                    \(content)
                </body>
                </html>
                """
        )
    }

    // MARK: - Home

    static func renderIndex(items: [Recette], search: String = "", error: String? = nil) -> HTML {
        let rows = items.map { item in
            let noteHtml =
                item.dejaFaite
                ? """
                <form action="/rate/\(item.id ?? 0)" method="post" class="inline-form">
                    <select name="note">
                        <option value="1" \(item.note == 1 ? "selected" : "")>1 ⭐</option>
                        <option value="2" \(item.note == 2 ? "selected" : "")>2 ⭐</option>
                        <option value="3" \(item.note == 3 ? "selected" : "")>3 ⭐</option>
                        <option value="4" \(item.note == 4 ? "selected" : "")>4 ⭐</option>
                        <option value="5" \(item.note == 5 ? "selected" : "")>5 ⭐</option>
                    </select>
                    <button type="submit">Noter</button>
                </form>
                """
                : "<p><em>La recette doit être faite avant d’être notée 👨‍🍳</em></p>"

            return """
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
                            <div class="stars">\(etoiles(item.note))</div>
                            <small>\(item.dejaFaite ? "\(item.note ?? 0)/5" : "Pas testée")</small>
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

                    <div class="action-grid">
                        <form action="/toggle-cooked/\(item.id ?? 0)" method="post">
                            <button type="submit" class="outline">Basculer le statut</button>
                        </form>

                        \(noteHtml)

                        <form action="/delete/\(item.id ?? 0)" method="post">
                            <button type="submit" class="contrast">Supprimer</button>
                        </form>
                    </div>

                    <div class="link-row">
                        <a href="/recipe/\(item.id ?? 0)" role="button" class="secondary">👁 Voir</a>
                        <a href="/edit/\(item.id ?? 0)" role="button">✏️ Modifier</a>
                    </div>
                </article>
                """
        }.joined()

        return layout(
            title: "Carnet de recettes",
            content: """
                <main>
                    <section class="hero">
                        <div class="hero-chip">Projet Swift CRUD • Hummingbird 2 • SQLite</div>
                        <h1>🍲 Mon carnet de recettes</h1>
                        <p>Organise tes recettes, garde une trace de ce que tu cuisines et retrouve tout rapidement dans une interface propre et agréable.</p>
                    </section>

                    \(error != nil ? "<div class='error-box'>⚠️ \(error!)</div>" : "")

                    <section class="glass-panel">
                        <div class="top-actions">
                            <form action="/" method="get" style="flex:1; margin:0;">
                                <label for="search"><strong>🔍 Rechercher une recette</strong></label>
                                <input type="search" name="search" placeholder="Ex: pâtes, dessert, salade..." value="\(search)">
                            </form>

                            <a href="/add" role="button">➕ Ajouter une recette</a>
                        </div>
                    </section>

                    <section class="section-spacing">
                        <div class="section-title">
                            <h2>📚 Mes recettes</h2>
                            <span class="count-badge">\(items.count) recette(s)</span>
                        </div>

                        \(items.isEmpty
                        ? "<div class='empty-box'><h3>Aucune recette trouvée</h3><p>Ajoute ta première recette pour commencer 👨‍🍳</p></div>"
                        : "<div class='recipes-grid'>\(rows)</div>")
                    </section>

                    <p class="footer-note">Fait en Swift avec Hummingbird 2 et SQLite</p>
                </main>
                """
        )
    }

    // MARK: - Add Page

    static func renderAddRecipePage(categories: [String], error: String? = nil) -> HTML {
        return layout(
            title: "Ajouter une recette",
            content: """
                <main class="page-shell">
                    <a href="/" class="back-link">← Retour à l’accueil</a>

                    <section class="page-card">
                        <div class="page-header">
                            <h1>➕ Ajouter une nouvelle recette</h1>
                            <p>Ajoute une recette complète à ton carnet personnel.</p>
                        </div>

                        \(error != nil ? "<div class='error-box'>⚠️ \(error!)</div>" : "")

                        <form action="/add" method="post">
                            <div class="form-grid">
                                <div>
                                    <label>Titre</label>
                                    <input name="titre" placeholder="Ex: Tiramisu maison" required>
                                </div>

                                <div>
                                    <label>Catégorie</label>
                                    <select name="categorie" required>
                                        <option value="">Choisir une catégorie</option>
                                        \(categoriesOptions())
                                    </select>
                                </div>

                                <div>
                                    <label>Temps de préparation (min)</label>
                                    <input name="tempsPreparation" type="number" min="1" placeholder="30" required>
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
                                    <textarea name="ingredients" placeholder="Ex: mascarpone, café, biscuits, cacao..." required></textarea>
                                </div>

                                <div class="form-full">
                                    <label>Ingrédients manquants</label>
                                    <textarea name="ingredientsManquants" placeholder="Ex: cacao, biscuits (laisser vide si rien ne manque)"></textarea>
                                </div>

                                <div class="form-full">
                                    <label>Étapes</label>
                                    <textarea name="etapes" placeholder="Décris la préparation étape par étape..." required></textarea>
                                </div>

                                <div class="form-full">
                                    <label>
                                        <input type="checkbox" name="dejaFaite">
                                        J’ai déjà réalisé cette recette
                                    </label>
                                </div>
                            </div>

                            <button type="submit">Ajouter la recette</button>
                        </form>
                    </section>
                </main>
                """
        )
    }

    // MARK: - View Page

    static func renderRecipeDetail(item: Recette) -> HTML {
        let noteBlock =
            item.dejaFaite
            ? "<p><strong>⭐ Note :</strong> \(item.note ?? 0)/5</p>"
            : "<p><strong>⭐ Note :</strong> Pas encore notée</p>"

        return layout(
            title: item.titre,
            content: """
                <main class="page-shell">
                    <a href="/" class="back-link">← Retour à l’accueil</a>

                    <section class="page-card">
                        <div class="page-header">
                            <h1>👁 \(item.titre)</h1>
                            <p>Consulte tous les détails de cette recette.</p>
                        </div>

                        <div class="recipe-badges" style="margin-bottom:1rem;">
                            <span class="badge badge-category">🍽 \(item.categorie)</span>
                            \(badgeStatut(item.dejaFaite))
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
                                <span>⭐ Évaluation</span>
                                <strong>\(item.dejaFaite ? "\(item.note ?? 0)/5" : "Pas testée")</strong>
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

                        <div class="recipe-section-box">
                            <h3>📌 Informations</h3>
                            \(noteBlock)
                        </div>

                        <div class="link-row">
                            <a href="/edit/\(item.id ?? 0)" role="button">✏️ Modifier la recette</a>
                            <a href="/" role="button" class="secondary">🏠 Retour à l’accueil</a>
                        </div>
                    </section>
                </main>
                """
        )
    }

    // MARK: - Edit Page

    static func renderEditRecipePage(item: Recette, categories: [String], error: String? = nil)
        -> HTML
    {
        return layout(
            title: "Modifier \(item.titre)",
            content: """
                <main class="page-shell">
                    <a href="/" class="back-link">← Retour à l’accueil</a>

                    <section class="page-card">
                        <div class="page-header">
                            <h1>✏️ Modifier la recette</h1>
                            <p>Tu peux mettre à jour toutes les informations de cette recette.</p>
                        </div>

                        \(error != nil ? "<div class='error-box'>⚠️ \(error!)</div>" : "")

                        <form action="/update/\(item.id ?? 0)" method="post">
                            <div class="form-grid">
                                <div>
                                    <label>Titre</label>
                                    <input name="titre" value="\(item.titre)" required>
                                </div>

                                <div>
                                    <label>Catégorie</label>
                                    <select name="categorie" required>
                                        \(categoriesOptions(selected: item.categorie))
                                    </select>
                                </div>

                                <div>
                                    <label>Temps de préparation (min)</label>
                                    <input name="tempsPreparation" type="number" min="1" value="\(item.tempsPreparation)" required>
                                </div>

                                <div>
                                    <label>Note</label>
                                    <select name="note">
                                        <option value="1" \(item.note == 1 ? "selected" : "")>1 ⭐</option>
                                        <option value="2" \(item.note == 2 ? "selected" : "")>2 ⭐</option>
                                        <option value="3" \(item.note == 3 ? "selected" : "")>3 ⭐</option>
                                        <option value="4" \(item.note == 4 ? "selected" : "")>4 ⭐</option>
                                        <option value="5" \(item.note == 5 ? "selected" : "")>5 ⭐</option>
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
                                    <label>
                                        <input type="checkbox" name="dejaFaite" \(item.dejaFaite ? "checked" : "")>
                                        Déjà réalisée
                                    </label>
                                </div>
                            </div>

                            <button type="submit">Enregistrer les modifications</button>
                        </form>

                        <div class="danger-zone">
                            <form action="/delete/\(item.id ?? 0)" method="post">
                                <button type="submit" class="contrast">Supprimer cette recette</button>
                            </form>
                        </div>
                    </section>
                </main>
                """
        )
    }

    // MARK: - Message Page

    static func renderMessagePage(title: String, message: String) -> HTML {
        return layout(
            title: title,
            content: """
                <main class="page-shell">
                    <a href="/" class="back-link">← Retour à l’accueil</a>

                    <section class="page-card">
                        <div class="page-header">
                            <h1>⚠️ \(title)</h1>
                            <p>\(message)</p>
                        </div>

                        <a href="/" role="button">Retourner à l’accueil</a>
                    </section>
                </main>
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
