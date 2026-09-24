# Cortify

All-in-one Flutter home for the **Cortis** fandom — official updates, schedule, community, discography, voting/support tools, and a private fan diary. Local data is stored with **sqflite**.

## Features (from the proposal)

1. **Official Hub & Smart Schedule** — verified announcements, member-filtered schedule, local-time display, reminders  
2. **Safe Community** — feed / official / fan projects, hearts, optional translations  
3. **Content Library** — discography, lyrics + translations, favorites, gallery shortcuts  
4. **Support & Voting Hub** — campaign guides, activity logging, milestone badges  
5. **Personal Fan Diary** — private memories, bias widget, wallpapers  

## Run

```bash
flutter pub get
flutter run
```

Needs a device/emulator (Android / iOS). SQLite is local-only; seed data loads on first launch.

## Stack

- Flutter / Dart  
- sqflite + path  
- google_fonts (Fraunces + DM Sans)  
- intl  

## Project structure

```
lib/
  main.dart
  theme/
  models/
  database/database_helper.dart
  screens/   # hub, community, library, support, diary
  widgets/
```
