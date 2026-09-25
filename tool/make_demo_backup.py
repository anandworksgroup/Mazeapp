"""Writes a Maze Adventure backup file describing a played-in profile.

Used to set up a device for store screenshots without grinding through
40 mazes by hand:

    python tool/make_demo_backup.py store/demo_profile.json
    adb push store/demo_profile.json /sdcard/Download/
    # then in the app: Settings -> Import game data

The file is a normal backup, so the app's own importer validates it and the
unlock/achievement rules are re-applied on load.
"""
import json
import random
import sys
import time

SIZES = ["tiny", "small", "medium", "large", "huge"]
WORLDS = ["forest", "candy", "ocean", "road", "snow", "castle"]
CHARACTERS = ["milo", "luna", "buddy", "clover", "pip", "buzz", "momo", "rex", "spike"]
PAR = {"tiny": 18, "small": 40, "medium": 80, "large": 140, "huge": 260}


def build(count=28, seed=7):
    rng = random.Random(seed)
    now = int(time.time() * 1000)
    day = 86400000
    history = []
    for i in range(count):
        size = SIZES[min(len(SIZES) - 1, rng.randrange(0, 5))]
        moves = round(PAR[size] * rng.uniform(1.0, 1.6))
        time_ms = round(moves * rng.uniform(600, 1100))
        stars = rng.choice([3, 2, 2, 2, 1, 1])
        history.append({
            "id": i + 1,
            "seed": rng.randrange(1, 2 ** 31),
            "size": size,
            "theme_id": WORLDS[i % len(WORLDS)],
            "character_id": CHARACTERS[i % len(CHARACTERS)],
            "mode": "daily" if i % 9 == 0 else "free",
            "day_key": None,
            "completed": 1,
            "time_ms": time_ms,
            "moves": moves,
            "bumps": rng.choice([0, 0, 1, 3, 5]),
            "stars": stars,
            "created_at": now - (count - i) * day // 2,
        })
    # A couple of Daily Mazes with real day keys, including today's.
    for i, entry in enumerate([e for e in history if e["mode"] == "daily"]):
        ts = time.localtime((now - i * day) / 1000)
        entry["day_key"] = time.strftime("%Y-%m-%d", ts)

    play_ms = sum(e["time_ms"] for e in history) + 40 * 60 * 1000
    today = time.strftime("%Y-%m-%d")
    return {
        "format": "maze_adventure_backup",
        "format_version": 1,
        "schema_version": 1,
        "exported_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        "tables": {
            "player": [{
                "id": "demo-profile-0000-0000-000000000001",
                "created_at": now - 30 * day,
                "selected_character": "milo",
                "selected_theme": "forest",
                "selected_size": "medium",
                "total_games": count + 6,
                "total_failed": 6,
                "total_play_time_ms": play_ms,
                "current_streak": 4,
                "longest_streak": 6,
                "last_play_day": today,
                "full_unlock": 0,
            }],
            # Unlocks and achievements are recomputed from history on load,
            # so these only need to exist.
            "characters": [],
            "themes": [],
            "sizes": [],
            "maze_history": history,
            "achievements": [],
            "settings": [
                {"key": "sound", "value": "true"},
                {"key": "music", "value": "true"},
                {"key": "control_mode", "value": "swipe"},
            ],
            "current_game": [],
        },
    }


if __name__ == "__main__":
    out = sys.argv[1] if len(sys.argv) > 1 else "store/demo_profile.json"
    data = build()
    with open(out, "w", encoding="utf8") as f:
        json.dump(data, f, indent=2)
    stars = sum(e["stars"] for e in data["tables"]["maze_history"])
    print(f"{out}: {len(data['tables']['maze_history'])} mazes, {stars} stars")
