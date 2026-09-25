# Maze Adventure

A cute, offline maze game for Android, iPhone and iPad, built in Flutter.
Pick a character, choose a world and a maze size, then solve procedurally
generated mazes forever.

- **No login, no account, no backend.** First launch creates a local profile
  (a random UUID that never leaves the device).
- **Works in airplane mode.** Gameplay never needs the internet. The network is
  only used by the AdMob ads and by the optional Full Unlock purchase; with no
  connection the ads simply do not appear and the game is unaffected.
- **All artwork and audio are original and generated from code**: the
  characters, worlds and goals are vector painters, and the sounds and music
  are synthesised by `tool/generate_audio.py`.

## Run

```bash
flutter pub get
flutter run
```

On this Windows machine, Android builds need the Gradle temp-dir workaround:

```bash
TMP='C:\gradle-tmp' TEMP='C:\gradle-tmp' flutter build apk --debug
```

## Tests

```bash
flutter test
```

- `maze_engine_test`: determinism (pinned PRNG), every cell reachable,
  symmetric walls, difficulty rising with size, collision, sliding, daily seed.
- `progress_test`: first launch, unlocks, achievements, streaks, abandon
  counting, resume, settings, Full Unlock, backup round-trip, reset.
- `movement_test`: drag steering, one bump per wall hold, queued turns.
- `app_flow_test`: boots the real app on a temp SQLite DB and plays Home →
  Play → character → world → size → solves the maze → results → next maze →
  pause → home → every menu screen.

## Layout

```
lib/
  app/            app shell, router, theme, AppController (state), AppScope
  core/           audio, catalog + config, localization (ARB), backup, widgets
  database/       SQLite schema, DAO, models
  features/
    maze/         generator (seeded), engine (session, difficulty, seeds),
                  movement (input → steps, joystick), view (game, painters)
    character/    character painter + animation, Characters screen
    themes/       world art (decorations, goals, scenes), Worlds screen
    home/         splash, home, play flow, pickers
    achievements/ progression rules + screen
    statistics/   My Journey
    settings/     settings, Full Unlock
assets/           sounds/, music/, config/game_config.json
tool/             generate_audio.py, generate_icons_test.dart, solve_swipes.dart,
                  generate_store_assets.py, make_demo_backup.py
store/            app icon, Play screenshots and listing text
```

## Ads

Google AdMob, configured for a children's audience
(`tagForChildDirectedTreatment`, `tagForUnderAgeOfConsent`, content rating G):

- a banner pinned to the bottom of every screen (`AdBannerBar`, in the app
  shell) that takes up no space at all until an ad has loaded;
- a full-screen ad after every second finished maze, shown when the player
  leaves the result screen rather than on top of the celebration, and never
  twice within 45 seconds;
- buying **Full Unlock** removes both.

The repository only contains Google's public **test** ad ids, so debug builds
can never touch live inventory. Real ids go in at build time:

```bash
flutter build appbundle --release \
  -PadmobAppId=ca-app-pub-XXX~YYY \
  --dart-define=ADMOB_BANNER_ANDROID=ca-app-pub-XXX/YYY \
  --dart-define=ADMOB_INTERSTITIAL_ANDROID=ca-app-pub-XXX/YYY \
  --dart-define=ADMOB_BANNER_IOS=ca-app-pub-XXX/YYY \
  --dart-define=ADMOB_INTERSTITIAL_IOS=ca-app-pub-XXX/YYY
```

The iOS app id lives in `ios/Runner/Info.plist` (`GADApplicationIdentifier`)
and must be swapped there by hand.

## Store assets

`store/` holds everything for the Play listing: the icon, raw device
screenshots in `store/screenshots/`, and ready-to-upload art plus listing text
in `store/play/` (see `store/play/listing.md`).

```bash
python tool/generate_store_assets.py     # icon 512, feature graphic, captions
python tool/make_demo_backup.py store/demo_profile.json   # played-in profile
```

`demo_profile.json` is a normal backup file: push it to a device and import it
from Settings to set up a profile worth screenshotting.

## Design notes

- **One generator × many seeds.** A maze is fully defined by `(seed, size)`.
  `SeededRandom` is mulberry32, not `dart:math`, so a saved seed rebuilds the
  identical maze on every platform and version. Its output is pinned by a test,
  so don't change it.
- **Generator**: an iterative recursive backtracker ("growing tree" with a
  branch chance), plus optional braiding (loops) for small, forgiving mazes.
  The goal is the edge cell farthest from the start by walking distance.
- **Difficulty** is measured, not assumed: size, path length, decisions on
  the path, dead ends and turns (`DifficultyAnalyzer`).
- **Daily Maze**: `seed = FNV-1a(local date + salt)`, so everyone gets the same
  maze with no server. There's no leaderboard, since nothing is uploaded.
- **Saving**: an unfinished maze is stored as seed + position + trail +
  moves/time (`current_game` table), autosaved every 2 s and when the app goes
  to the background.
- **Controls**: swipe (one swipe runs down the corridor to the next fork; a
  sideways swipe mid-run turns at the next opening), drag, tilt (calibrated
  to how the phone is held) and joystick. Arrow keys/WASD work too. Collision
  lives only in `GameSession.step`.
- **Unlocks**: 5 characters, 3 worlds and 5 sizes are free. Everything else
  unlocks by playing (completions or stars). Full Unlock only skips the wait.

## Before release

- Create the non-consumable product `maze_adventure_full_unlock` in Play
  Console and App Store Connect (the id is in `assets/config/game_config.json`).
- Swap in real AdMob ids (see **Ads**) and add a privacy policy URL.
- Set up release signing for Android and a bundle id/team for iOS.
- Only English and Hindi ship today. Add an ARB file under
  `lib/core/localization/arb/` and a code in `shippedLocales` for each new
  language.
- Regenerate icons after art changes: `flutter test tool/generate_icons_test.dart`.
  The 1024px store icon is written to `store/app_icon_1024.png`.
