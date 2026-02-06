# Aritme(bu)tikk

Et morsomt og fargerikt aritmetikk-spill for barn, bygget med Flutter. Svar riktig pa regneoppgaver, tjen poeng og bruk dem i butikken!

<p align="center">
  <img src="screen.jpg" alt="Skjermbilde av spillet" width="300">
</p>

## Funksjoner

- **Fire regnearter** -- addisjon, subtraksjon, ganging og deling
- **Tre vanskelighetsgrader** -- lett, middels og vanskelig for hver kategori
- **10 nivaer** -- progressiv vanskelighetsgrad med tidsbegrensning
- **Poengsystem** -- tjen poeng for riktige svar, med multiplikator for hoeyere vanskelighetsgrad
- **Butikk** -- bruk opptjente poeng pa skjermtid eller lommepenger
- **Highscores** -- folg fremgangen din over tid
- **Lydeffekter** -- lyd for riktig svar, feil svar, nivaoppgang og mer
- **Animasjoner** -- konfetti, shake-effekter og animert bakgrunn

## Kom i gang

### Forutsetninger

- [Git](https://git-scm.com/downloads) -- for a klone prosjektet
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.10.8+) -- inkluderer Dart
- En editor som [VS Code](https://code.visualstudio.com/) eller [Android Studio](https://developer.android.com/studio)

**Plattform-spesifikke krav:**

| Plattform | Krav |
|-----------|------|
| Android   | Android Studio med Android SDK |
| iOS       | macOS med Xcode |
| Web       | Chrome eller annen nettleser |
| Windows   | Visual Studio med C++ desktop-utvikling |

### Installasjon

```bash
# Klon prosjektet fra GitHub
git clone https://github.com/krestian83/aritmebutikk.git

# Ga inn i prosjektmappen
cd aritmebutikk

# Last ned alle avhengigheter (audioplayers, shared_preferences osv.)
flutter pub get

# Kjor appen (velger automatisk en tilkoblet enhet eller emulator)
flutter run
```

For a kjore pa en spesifikk plattform:

```bash
# Kjor i Chrome
flutter run -d chrome

# Kjor pa Windows
flutter run -d windows

# Kjor pa en tilkoblet Android-enhet
flutter run -d android

# Se alle tilgjengelige enheter
flutter devices
```

## Prosjektstruktur

```
lib/
  app/              # App-konfigurasjon og tema
    theme/          # Farger og tema-definisjon
  game/             # Spillogikk
    config/         # Nivakonfigurasjon
    models/         # Datamodeller (sporsmal, kategorier, butikkvarer)
    services/       # Lyd, highscore og poeng-tjenester
    systems/        # Nivahandtering, sporsmalsgenerering, poengberegning, timer
  ui/               # Brukergrensesnitt
    screens/        # Skjermer (meny, kategori, spill, butikk, highscores)
    widgets/        # Gjenbrukbare widgets (svar-knapper, HUD, effekter)
```

## Plattformer

- Android
- iOS
- Web
- Windows

## Teknologi

- [Flutter](https://flutter.dev/) -- UI-rammeverk
- [audioplayers](https://pub.dev/packages/audioplayers) -- lydavspilling
- [shared_preferences](https://pub.dev/packages/shared_preferences) -- lokal lagring av poeng og highscores
