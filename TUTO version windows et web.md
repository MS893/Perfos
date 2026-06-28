## 📑 Tutoriel de déploiement Windows et Web (exemple avec Perfos)

### Avant chaque compilation (Checklist)

1. Assurez-vous d'avoir enregistré vos modifications dans vos fichiers Dart.
2. Si vous avez ajouté des images ou des polices, vérifiez qu'elles sont bien déclarées dans le `pubspec.yaml`.

---

## 🌐 Partie 1 : Mettre à jour la version Web (GitHub Pages)

Ouvrez le terminal d'Android Studio (assurez-vous d'être à la racine du projet) et exécutez ces commandes :

```bash
# 1. Compiler la version finale pour le Web (en ciblant le bon dépôt)
flutter build web --base-href="/Perfos/"

# 2. Se déplacer dans le dossier contenant le site généré
cd build/web

# 3. Initialiser le Git local de ce dossier spécifique
git init

# 4. Connecter ce dossier à votre GitHub
git remote add origin https://github.com/ms893/Perfos.git

# 5. Créer et basculer sur la branche dédiée à l'hébergement Web
git checkout -b gh-pages

# 6. Ajouter et valider tous les fichiers compilés
git add .
git commit -m "Mise à jour de l'application Web"

# 7. Envoyer sur GitHub en écrasant l'ancienne version
git push origin gh-pages --force

# 8. Revenir à la racine du projet (très important pour la suite !)
cd ../..

```

> 💡 **Rappel :** Après l'envoi, attendez environ 1 minute que GitHub traite les fichiers, puis actualisez votre navigateur avec **`Ctrl + F5`** (ou `Cmd + Shift + R` sur Mac) pour vider le cache et voir les nouveautés.

---

## 🪟 Partie 2 : Mettre à jour la version Windows

Depuis la racine de votre projet dans le terminal :

```bash
# 1. Compiler l'application pour Windows
flutter build windows

```

### Où récupérer les fichiers ?

Une fois la compilation terminée, ouvrez votre explorateur de fichiers Windows et allez dans :
📂 `Perfos / build / windows / x64 / runner / Release /`

### Comment la distribuer à vos utilisateurs ?

1. Sélectionnez **l'intégralité** du contenu de ce dossier `Release` (le fichier `Perfos.exe`, les fichiers `.dll` et le dossier `data`).
2. Faites un clic droit ➔ **Envoyer vers** ➔ **Dossier compressé (zippé)**.
3. Donnez le nom que vous souhaitez à ce fichier `.zip` (ex: `Perfos_Windows.zip`). C'est ce fichier unique que vous pouvez partager !

---

### 🛠️ Conseil bonus pour aller plus vite : Le Script Automatique

Si vous ne voulez plus taper toutes ces commandes pour le Web, vous pouvez créer un fichier nommé `deploy_web.bat` à la racine de votre projet (sous Windows) et coller le texte de la **Partie 1** dedans. À l'avenir, un simple double-clic sur ce fichier mettra votre site GitHub Pages à jour automatiquement !