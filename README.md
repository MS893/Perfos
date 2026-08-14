# Perfos décollage et atterrisage ✈️

Application Flutter pour le calcul des performances de décollage et d'atterrissage pour les avions **F-GYKX**, **F-BVCY** et **F-HAIX**.

## 📋 Présentation

Cet outil permet aux pilotes de calculer rapidement les distances de roulement et de passage des 15m (50ft) en fonction des conditions réelles :
*   **Altitude** du terrain
*   **Température** extérieure (avec calcul automatique du Delta ISA)
*   **Masse** de l'avion
*   **Vent** (Face/Arrière)
*   **Type de piste** (Dur / Herbe)
*   **État de la surface** (Sèche / Mouillée)

## 🛠 Logique de Calcul

L'application utilise une logique robuste basée sur les manuels de vol :
*   **Interpolation/Extrapolation trilinéaire** sur l'altitude, la température et la masse.
*   **Coefficients de vent spécifiques** à chaque machine (non-linéaire).
*   **Gestion multi-tableaux** pour les avions anciens (ex: F-BVCY avec tableaux herbe/dur séparés).
*   **Marge de sécurité "Pilote Standard"** : Ajout automatique de +15% pour coller à la réalité opérationnelle.
*   **Alertes visuelles** : Code couleur (Orange/Rouge) pour indiquer si le résultat est interpolé ou extrapolé.

## 🚀 Installation & Tests

1.  **Récupérer les dépendances :**
    ```bash
    flutter pub get
    ```
2.  **Lancer les tests :**
    ```bash
    flutter test
    ```
3.  **Lancer l'application :**
    ```bash
    flutter run
    ```

## ⚠️ Avertissement (Disclaimer)

Cette application est un outil d'aide au calcul et ne remplace en aucun cas le manuel de vol officiel de l'avion (AFM). Le pilote reste seul responsable de la préparation de son vol.

---
Développé pour une utilisation en aéroclub. 🛠️
