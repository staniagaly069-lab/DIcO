# Dictionnaire Français ↔ Lingala

Application mobile Flutter 100% offline (Android / iOS).

**Concepteur :** Erly Rolvinst BASSOMBI
**Email :** ebassombi@gmail.com
**Téléphone :** +242 069101357

## Fonctionnalités

- Recherche instantanée Français → Lingala et Lingala → Français
- Mode hors-ligne (données JSON locales dans `assets/data/`)
- Prononciation TextToSpeech (`flutter_tts`)
- Favoris et historique (`shared_preferences`)
- Mode sombre / clair
- Material 3, BottomNavigationBar, splash screen
- Copier / partager une traduction

## Lancer le projet (FlutLab.io ou local)

```bash
flutter pub get
flutter run
```

## Données

Les données sont extraites du *Dictionnaire Français – Lingala – Sango* (DICOplus,
sous la direction de M. Ngalasso-Mwatha) et stockées dans :

- `assets/data/francais_lingala.json` (~9 400 entrées)
- `assets/data/lingala_francais.json` (~8 600 entrées)

Format :
```json
[
  { "francais": "bonjour", "lingala": "mbote" }
]
```

> Les images `assets/images/logo.png` et `assets/images/splash.png` ne sont pas
> incluses : ajoutez les vôtres avant la compilation (ou supprimez les références
> dans `splash_screen.dart`).



## Architecture et conformité compilation

Pour aligner un autre projet sur cette base Flutter (architecture, SDK, versions Gradle/Kotlin/Android et plugins), consultez le guide dédié : [`GUIDE_ARCHITECTURE_COMPILATION.md`](GUIDE_ARCHITECTURE_COMPILATION.md).

## Installation Flutter + Android (Linux)

Si tu pars de zéro, lance simplement :

```bash
bash scripts/setup_flutter_android.sh
```

Ensuite dans le projet :

```bash
flutter pub get
flutter run
```

> Le script installe Flutter, Android SDK command line tools, platform-tools, build-tools et accepte les licences.
