import Foundation
import Hummingbird

struct Views {
    static func renderIndex(items: [Recipe]) -> HTML {

        let rows = items.map { item in
            """
            <article>
                <h2>\(item.title)</h2>
                <p><strong>Ingrédients:</strong> \(item.ingredients)</p>
                <p><strong>Étapes:</strong> \(item.steps)</p>
                <p><strong>Catégorie:</strong> \(item.category)</p>

                <form action="/delete/\(item.id ?? 0)" method="post">
                    <button type="submit" class="contrast">Supprimer</button>
                </form>

                <form action="/update/\(item.id ?? 0)" method="post">
                    <input name="title" placeholder="Nouveau titre">
                    <button type="submit">Modifier</button>
                </form>
            </article>
            """
        }.joined()

        return HTML(
            content: """
                <!DOCTYPE html>
                <html>
                <head>
                    <meta charset="utf-8">
                    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@picocss/pico@2/css/pico.min.css">
                    <title>Carnet de Recettes</title>
                </head>
                <body class="container">

                    <h1>🍲 Carnet de recettes</h1>

                    <form action="/add" method="post">
                        <input name="title" placeholder="Titre" required>
                        <input name="ingredients" placeholder="Ingrédients" required>
                        <input name="steps" placeholder="Étapes" required>
                        <input name="category" placeholder="Catégorie" required>
                        <button type="submit">Ajouter</button>
                    </form>

                    <hr>

                    \(items.isEmpty ? "<p>Aucune recette</p>" : rows)

                </body>
                </html>
                """)
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
