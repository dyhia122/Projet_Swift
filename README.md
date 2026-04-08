# Carnet de recette
C'est une application web CRUD developpee en swift et sqLite

L'application permet a l'utilisateur de:
-creer de nouvelles recettes
-Modifier les recettes existantes
-Consulter la liste des recettes existantes
-Afficher une page de detail pour chaque recette
-Rechercher des recettes
-Supprimer une recette
-Noter les recettes
-Maquer la recette comme deja faite
-Créer un compte et se connecter

---

## Technologies utilisees:
-Swift
-SqLite
-HTML
-Pico CSS

---

## Fonctionnalites

1. Create -> Ajouter une nouvelle recette
2. Read -> Affichage de toutes les recettes
3. Update -> Modification d'une recette deja existante
4. Delete -> Suppression d'une recette
5. Rechercher –> Filtrer les recettes par titre, catégorie ou ingrédient
6. Noter –> Ajouter une note de 1 à 5 étoiles
7. Marquer comme faite –> Indiquer si la recette a été réalisée
8. Liste de courses –> Regroupe automatiquement les ingrédients manquan

## Modèle de données

Chaque recette contient les champs suivants :

- `id` : identifiant unique auto-incrémenté
- `titre` : titre de la recette
- `ingredients` : ingrédients nécessaires
- `missingIngredients` : ingrédients manquants
- `etapes` : étapes de préparation
- `categorie` : catégorie de la recette
- `note` : note de 1 à 5
- `faite` : indique si la recette a déjà été réalisée
- `tempspreparation` : temps de préparation en minutes



---

## 3. Build & Run

Open the integrated terminal and run:

```bash
./build.sh
```

This resolves dependencies and compiles the project. When it finishes, start the server:

```bash
./run.sh
```

Codespaces will detect that port **8080** is now in use and show a pop-up — click **"Open in Browser"** (or find it under the **Ports** tab). You should see the Task List app running live.

> To stop the server press `Ctrl + C` in the terminal.

---

## 4. Project Structure

```
.devcontainer/
  devcontainer.json     # Codespaces container config (Swift 6.2, VS Code extensions, port forwarding)
Sources/App/
  main.swift            # Entry point — server setup and HTTP route definitions
  Models.swift          # Data model: the TaskItem struct
  Database.swift        # SQLite setup and all database queries
  Views.swift           # HTML page rendering (returns pages to the browser)
Package.swift           # Swift package definition — dependencies and build targets
build.sh                # Helper script: resolve + compile
run.sh                  # Helper script: start the server
```

---
## 5. Routes

### GET
- `GET /`
  - Affiche la liste des recettes
  - Supporte la recherche avec `?search=...`

- `GET /recipe/:id`
  - Affiche la page détail d’une recette


### POST
- `POST /add`
  - Ajoute une nouvelle recette

- `POST /update/:id`
  - Met à jour une recette existante

- `POST /delete/:id`
  - Supprime une recette

- `POST /toggle-cooked/:id`
  - Change le statut "faite / pas encore faite"

- `POST /rate/:id`
  - Met à jour la note d’une recette
## Lancer le projet

Dans GitHub Codespaces :

```bash
./build.sh
./run.sh
