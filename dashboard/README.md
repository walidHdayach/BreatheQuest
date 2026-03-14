# BreatheQuest – Dashboard (optionnel)

Page React (Vite) pour afficher des stats agrégées.

## Configuration

1. Copiez votre config Firebase dans `src/App.jsx` (remplacez `YOUR_API_KEY`, `YOUR_PROJECT_ID`, etc.).
2. **Règles Firestore** : par défaut, seuls les utilisateurs connectés peuvent lire leurs propres données. Pour que ce dashboard lise tous les utilisateurs, vous pouvez :
   - utiliser un **backend** (Firebase Admin SDK) qui lit Firestore et expose une API, ou
   - en **démo** uniquement : adapter temporairement les règles pour autoriser la lecture de `users` (ex. `allow read: if true;`) puis les remettre après.

## Lancer

```bash
npm install
npm run dev
```

Ouvrir l’URL affichée (ex. http://localhost:5173).
