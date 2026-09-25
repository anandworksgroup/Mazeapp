# Google Play listing — Maze Adventure

Copy-paste text for the Play Console, plus what each asset is for. Character
limits noted; everything here fits.

## Store listing

**App name** (30 max)

```
Maze Adventure
```

**Short description** (80 max)

```
Cute offline maze game. Pick a buddy, explore worlds, solve endless mazes.
```

**Full description** (4000 max)

```
Maze Adventure is a calm, colourful maze game for kids and grown-ups. Pick a
cute buddy, choose a world, and find your way to the goal. Every maze is made
fresh on your device, so you never run out.

PLAY ANYWHERE
• Works completely offline — perfect for cars, planes and waiting rooms
• No account, no login, no sign-up. Just open and play
• Progress is saved on your device

ENDLESS MAZES
• Mazes are generated as you play, so there is always a new one
• Six sizes, from a gentle 5 × 5 to a giant 32 × 32
• A new Daily Maze every day, the same one for everyone
• Stars for finishing quickly and neatly, and a streak for playing each day

12 CUTE BUDDIES
Milo the mouse, Luna the cat, Buddy the dog, Clover the bunny, Pip the frog,
Buzz the bee, Momo the monkey, Rex the dino, Ollie the owl, Spike, Rudy and
Wiggles. Unlock them by playing.

8 HAND-DRAWN WORLDS
Forest, Candy, Ocean, Town, Snow, Castle, Volcano and Space — each with its
own goal to reach, from a flower to a treasure chest to a planet.

MADE FOR SMALL HANDS
• Four ways to play: swipe, drag, tilt or an on-screen joystick
• Big buttons, simple words, one-hand play
• Left-handed mode, high contrast, large text and reduced animation
• English and Hindi

FAIR AND SIMPLE
• Everything can be unlocked just by playing — nothing is purchase-only
• One optional purchase, Full Unlock, opens everything at once and removes ads
• Ads are family-friendly and only appear between mazes and in a small banner
• You can export your progress to a file and move it to another device

No accounts. No servers. No leaderboards collecting your child's data.
Just mazes.
```

## Graphics

| Asset | File | Play requirement |
| --- | --- | --- |
| App icon | `icon_512.png` | 512 × 512 PNG |
| Feature graphic | `feature_graphic.png` | 1024 × 500 PNG |
| Phone screenshots | `screenshots/01..08` | 1080 × 1920 (9:16), 2–8 images |

Raw device captures (no caption band) are in `store/screenshots/` if the
listing is better served by plain shots.

Tablet screenshots are **not** included. Play only requires them if the app is
offered as tablet-optimised; the game does adapt to tablets, so capture a set
on a tablet device or AVD before ticking that box.

## Categorisation

- Category: Games → Puzzle
- Tags: brain games, offline, kids
- Target age: designed for children — join the **Designed for Families**
  programme, which means the child-directed ad settings the app already sends
  (`tagForChildDirectedTreatment`, `maxAdContentRating=G`) and a content
  rating questionnaire answered as "Everyone".

## Data safety answers

- **Collected by the app itself:** nothing. No account, no analytics, no
  crash reporting, no network calls of its own.
- **Collected by Google AdMob:** device or other IDs, and app activity used
  for ads. Ads are requested as child-directed and non-personalised.
- **Collected by Google Play Billing:** purchase history, if a grown-up buys
  Full Unlock.
- Data is not shared with other companies by the app, and nothing is
  transferred off the device by the game itself.

## Still needed before publishing

1. A privacy policy URL (the in-app Privacy text can be the basis for it).
2. Real AdMob ids (see README) — the build currently uses Google's test ids.
3. The in-app product `maze_adventure_full_unlock` created in Play Console.
4. A release keystore, and an upload of an **app bundle** (`flutter build
   appbundle`), not the APK.
