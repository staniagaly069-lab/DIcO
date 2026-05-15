# Guide d'architecture et de compilation Flutter

Ce document sert de référence pour rendre un autre projet compatible avec
l'architecture de cette application **Dictionnaire Français ↔ Lingala** et
réduire les erreurs de compilation. Il décrit la structure attendue, les SDK,
les versions de plugins, les assets et les points de contrôle avant build.

## 1. Objectif de l'architecture

L'application est une application Flutter mobile **100% hors-ligne**. Elle ne
contient pas de backend, pas de Firebase, pas de base de données SQLite et pas
d'API distante. Les données sont embarquées dans `assets/data/` au format JSON,
puis chargées en mémoire au démarrage.

Principes à conserver dans les autres projets :

- garder une logique simple en couches : `models`, `services`, `data`,
  `screens`, `widgets`, `utils` ;
- centraliser les chemins d'assets, clés de préférences et constantes dans
  `lib/utils/constants.dart` ;
- déclarer toutes les routes dans `lib/utils/routes.dart` ;
- stocker les petits états persistants avec `shared_preferences` ;
- éviter les dépendances natives non indispensables pour rester compatible avec
  FlutLab, Android Studio et les builds Flutter standards.

## 2. Versions et SDK à utiliser

### Flutter et Dart

| Élément | Version/règle dans ce projet | Recommandation pour un autre projet |
| --- | --- | --- |
| Flutter | `3.24.0` dans `scripts/setup_flutter_android.sh` | Utiliser Flutter `3.24.0` ou une version stable compatible avec Dart 3 |
| Dart SDK | `>=3.0.0 <4.0.0` dans `pubspec.yaml` | Garder cette contrainte si le code est Dart 3 |
| Type de projet | `app` dans `.metadata` | Créer un projet Flutter application |

> Si vous partez d'un environnement vide Linux/CI, le script
> `scripts/setup_flutter_android.sh` installe Flutter `3.24.0`, Android SDK
> Platform 34 et Build Tools 34.0.0.

### Android

| Élément | Version/règle dans ce projet |
| --- | --- |
| Android Gradle Plugin | `com.android.application` `8.2.1` |
| Kotlin Gradle Plugin | `org.jetbrains.kotlin.android` `1.9.10` |
| Flutter Gradle Plugin Loader | `dev.flutter.flutter-plugin-loader` `1.0.0` |
| Gradle Wrapper | `8.7` (`gradle-8.7-all.zip`) |
| `compileSdk` | `34` |
| `targetSdk` | `34` |
| `minSdk` | `21` |
| Android Build Tools installés par le script | `34.0.0` |
| Java/Kotlin bytecode | JVM `1.8` |
| AndroidX | activé (`android.useAndroidX=true`) |
| Jetifier | activé (`android.enableJetifier=true`) |

Pour une compilation Android fiable avec AGP 8.x, utilisez de préférence un
JDK 17. Évitez de modifier simultanément Gradle, AGP, Kotlin et Flutter : si une
mise à jour est nécessaire, changez une seule famille de versions puis testez.

### iOS

| Élément | Version/règle dans ce projet |
| --- | --- |
| Plateforme minimale Flutter iOS | `MinimumOSVersion` `12.0` dans `ios/Flutter/AppFrameworkInfo.plist` |
| Version app iOS | `$(FLUTTER_BUILD_NAME)` et `$(FLUTTER_BUILD_NUMBER)` |
| Nom affiché | `Dictionnaire FR-Lingala` |

## 3. Dépendances Flutter

Les dépendances sont volontairement limitées :

| Type | Package | Version déclarée | Rôle |
| --- | --- | --- | --- |
| Runtime | `flutter` | SDK Flutter | Framework UI |
| Runtime | `cupertino_icons` | `^1.0.6` | Icônes iOS/Cupertino |
| Runtime | `flutter_tts` | `^3.8.5` | Prononciation Text-to-Speech |
| Runtime | `shared_preferences` | `^2.2.2` | Favoris, historique et thème |
| Dev | `flutter_lints` | `^3.0.0` | Règles d'analyse Dart/Flutter |
| Dev | `flutter_test` | SDK Flutter | Tests unitaires/widgets |

Pour conformer un autre projet :

1. copiez ces dépendances dans `pubspec.yaml` ;
2. lancez `flutter pub get` ;
3. si vous ajoutez un package natif, vérifiez sa compatibilité Android `minSdk 21`,
   iOS 12 et Flutter 3/Dart 3 ;
4. pour une application, versionnez le fichier `pubspec.lock` généré afin de
   figer les versions réellement résolues.

## 4. Structure de dossiers à reproduire

```text
lib/
  main.dart                    # initialisation Flutter, thème, routes
  data/
    local_dictionary.dart      # cache mémoire + recherche locale
  models/
    word_model.dart            # modèle de donnée sérialisable JSON
  screens/
    splash_screen.dart         # chargement initial
    home_screen.dart           # recherche principale
    favorites_screen.dart      # favoris persistés
    history_screen.dart        # historique persisté
    settings_screen.dart       # thème et informations
  services/
    json_service.dart          # lecture des assets JSON
    favorite_service.dart      # persistance favoris
    history_service.dart       # persistance historique
  utils/
    constants.dart             # constantes globales
    routes.dart                # table de routes MaterialApp
    themes.dart                # thèmes clair/sombre
  widgets/
    custom_appbar.dart         # composants UI réutilisables
    search_bar_widget.dart
    word_card.dart
assets/
  data/
    francais_lingala.json
    lingala_francais.json
  images/
    logo.png
    splash.png
android/
ios/
test/
```

Règle pratique : une classe ne doit pas connaître toute l'application. Les
écrans assemblent l'interface, les services lisent/écrivent les données, les
modèles décrivent la donnée, et `utils` contient la configuration partagée.

## 5. Contrat des données JSON

Les fichiers de dictionnaire doivent être déclarés dans `pubspec.yaml` sous
`flutter.assets`. Le format attendu est une liste d'objets avec les clés
`francais` et `lingala` :

```json
[
  { "francais": "bonjour", "lingala": "mbote" }
]
```

À adapter pour un autre domaine :

- gardez un modèle Dart unique dans `lib/models/` ;
- gardez une méthode `fromJson` et une méthode `toJson` ;
- exposez un identifiant stable pour les favoris/historiques ;
- mettez à jour `AppConstants.asset...` si les noms de fichiers changent ;
- vérifiez que chaque fichier asset est listé dans `pubspec.yaml`, sinon le build
  compile mais l'application échoue au chargement.

## 6. Configuration Android à conserver

### `android/settings.gradle`

Conservez la résolution du SDK Flutter via `local.properties` et les plugins :

```gradle
plugins {
    id "dev.flutter.flutter-plugin-loader" version "1.0.0"
    id "com.android.application" version "8.2.1" apply false
    id "org.jetbrains.kotlin.android" version "1.9.10" apply false
}
```

### `android/app/build.gradle`

Conservez les valeurs suivantes, sauf besoin métier explicite :

```gradle
android {
    namespace "com.lovable.dictionnaire_fr_lingala"
    compileSdk 34

    defaultConfig {
        applicationId "com.lovable.dictionnaire_fr_lingala"
        minSdk 21
        targetSdk 34
    }
}
```

Pour un autre projet, changez seulement `namespace` et `applicationId` pour
votre identifiant, par exemple `com.example.mon_app`. Gardez `compileSdk`,
`targetSdk` et `minSdk` tant que les dépendances ne demandent pas autre chose.

### `android/gradle.properties`

Gardez au minimum :

```properties
org.gradle.jvmargs=-Xmx4G
android.useAndroidX=true
android.enableJetifier=true
```

## 7. Configuration iOS à conserver

- Garder `ios/Flutter/Debug.xcconfig` et `ios/Flutter/Release.xcconfig` avec
  `#include "Generated.xcconfig"`.
- Garder iOS minimum 12.0 si vous utilisez les mêmes plugins.
- Adapter uniquement le nom affiché, le bundle identifier et les icônes via les
  outils Flutter/Xcode habituels.

## 8. Procédure de mise en conformité d'un autre projet

1. Créer ou nettoyer le projet : `flutter create mon_projet`.
2. Copier l'arborescence `lib/`, `assets/`, `android/`, `ios/` si vous voulez un
   clone architectural complet.
3. Adapter `pubspec.yaml` : nom, description, version, SDK Dart, dépendances et
   assets.
4. Adapter les constantes dans `lib/utils/constants.dart`.
5. Adapter `namespace` et `applicationId` Android.
6. Adapter les noms iOS dans `ios/Runner/Info.plist`.
7. Lancer `flutter pub get`.
8. Lancer `flutter analyze`.
9. Lancer `flutter test`.
10. Lancer `flutter build apk --debug` ou `flutter run`.

## 9. Checklist anti-erreurs de compilation

Avant de compiler, vérifiez :

- `flutter --version` indique une version stable compatible Dart 3 ;
- `flutter doctor` ne signale pas de problème Android SDK/Xcode bloquant ;
- les chemins dans `pubspec.yaml` existent vraiment ;
- l'indentation YAML de `pubspec.yaml` est correcte ;
- `android/local.properties` contient `flutter.sdk=...` sur la machine locale ;
- le package Android (`namespace`/`applicationId`) est unique ;
- aucun import Dart ne pointe vers un fichier supprimé ou renommé ;
- `flutter_tts` et `shared_preferences` sont récupérés par `flutter pub get` ;
- les fichiers JSON sont valides (`[` ... `]`, guillemets doubles, pas de virgule
  finale interdite) ;
- si vous changez les noms de clés JSON, vous mettez aussi à jour
  `WordModel.fromJson`, `toJson` et les écrans qui affichent les champs.

## 10. Commandes de référence

```bash
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

Sur Linux/CI sans SDK installé :

```bash
bash scripts/setup_flutter_android.sh
export PATH="$HOME/flutter/bin:$HOME/Android/Sdk/cmdline-tools/latest/bin:$HOME/Android/Sdk/platform-tools:$PATH"
flutter pub get
flutter build apk --debug
```

## 11. Règle de maintenance recommandée

Pour que l'application continue à compiler :

- ne mettez pas à jour toutes les dépendances en même temps ;
- conservez une matrice de versions Flutter/Gradle/AGP/Kotlin testée ;
- ajoutez ou mettez à jour un test minimal dans `test/` après chaque changement ;
- exécutez `flutter analyze` et `flutter test` avant chaque livraison ;
- versionnez les assets et le `pubspec.lock` d'application après résolution des
  dépendances.
