"""Builds the Google Play graphics from the app's own icon and screenshots.

    python tool/generate_store_assets.py

Outputs into store/play/:
  * feature_graphic.png   1024x500, required by Play
  * icon_512.png          512x512, required by Play
  * screenshots/*.png     the raw device captures in store/screenshots/, each
                          given a caption band so the listing reads well

Screenshots are captured from a real device first (see README); this script
only decorates them. Fonts come from the system, since they are used for
marketing art only and are never shipped inside the app.
"""
import os
import glob
from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.join(os.path.dirname(__file__), "..")
OUT = os.path.join(ROOT, "store", "play")
SHOTS_IN = os.path.join(ROOT, "store", "screenshots")

GREEN_LIGHT = (155, 220, 126)
GREEN_DARK = (62, 142, 65)
INK = (59, 36, 24)
CREAM = (255, 246, 229)
YELLOW = (255, 203, 47)

CAPTIONS = {
    "01_home": "A cute maze for every mood",
    "02_characters": "Pick your buddy — 12 to collect",
    "03_worlds": "Explore 8 hand-drawn worlds",
    "04_sizes": "From tiny 5x5 to a giant 32x32",
    "05_game": "Swipe, drag, tilt or joystick",
    "06_win": "Stars, streaks and no dead ends",
    "07_achievements": "Achievements to chase",
    "08_journey": "Every maze made on your device",
}


def font(size, bold=True):
    for name in ("seguibl.ttf", "ariblk.ttf", "verdanab.ttf", "arialbd.ttf"):
        path = os.path.join("C:\\", "Windows", "Fonts", name)
        if os.path.exists(path):
            return ImageFont.truetype(path, size)
    return ImageFont.load_default()


def gradient(size, top, bottom, diagonal=True):
    img = Image.new("RGB", size)
    d = ImageDraw.Draw(img)
    w, h = size
    steps = h if not diagonal else w + h
    for i in range(steps):
        t = i / max(1, steps - 1)
        color = tuple(round(top[c] + (bottom[c] - top[c]) * t) for c in range(3))
        if diagonal:
            d.line([(i, 0), (0, i)], fill=color, width=2)
        else:
            d.line([(0, i), (w, i)], fill=color)
    return img


def maze_pattern(img, alpha=40, cell=96, width=14):
    """Faint maze walls, the same motif as the icon background."""
    layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    w, h = img.size
    segments = [
        (0.1, 0.0, 0.1, 0.55), (0.1, 0.55, 0.42, 0.55), (0.42, 0.2, 0.42, 0.55),
        (0.25, 0.2, 0.42, 0.2), (0.6, 0.0, 0.6, 0.3), (0.6, 0.3, 0.88, 0.3),
        (0.88, 0.3, 0.88, 0.75), (0.32, 0.78, 0.88, 0.78), (0.32, 0.78, 0.32, 1.0),
        (0.7, 0.45, 0.7, 0.62), (0.05, 0.85, 0.2, 0.85),
    ]
    for x0, y0, x1, y1 in segments:
        d.line([(x0 * w, y0 * h), (x1 * w, y1 * h)],
               fill=(255, 255, 255, alpha), width=width, joint="curve")
    return Image.alpha_composite(img.convert("RGBA"), layer)


def outlined_text(draw, xy, text, fnt, fill, outline, stroke=6, anchor="la"):
    draw.text(xy, text, font=fnt, fill=fill, stroke_width=stroke,
              stroke_fill=outline, anchor=anchor)


def feature_graphic():
    size = (1024, 500)
    img = maze_pattern(gradient(size, GREEN_LIGHT, GREEN_DARK), alpha=46, width=18)
    d = ImageDraw.Draw(img)

    icon = Image.open(os.path.join(ROOT, "store", "app_icon_1024.png")).convert("RGBA")
    icon = icon.resize((330, 330), Image.LANCZOS)
    # Round the icon corners so it sits on the banner like an app tile.
    mask = Image.new("L", icon.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, icon.size[0] - 1, icon.size[1] - 1],
                                           radius=74, fill=255)
    img.paste(icon, (78, 85), mask)
    # Outline the tile so it reads as an app icon against the same greens.
    d.rounded_rectangle([78, 85, 78 + 329, 85 + 329], radius=74, outline=INK, width=7)

    outlined_text(d, (470, 140), "Maze", font(92), YELLOW, INK, 8)
    outlined_text(d, (470, 238), "Adventure", font(92), YELLOW, INK, 8)
    outlined_text(d, (472, 356), "Offline  •  12 buddies  •  8 worlds",
                  font(30), CREAM, INK, 5)
    outlined_text(d, (472, 400), "No login, no accounts", font(30), CREAM, INK, 5)
    img.convert("RGB").save(os.path.join(OUT, "feature_graphic.png"))
    print("feature_graphic.png")


def store_icon():
    icon = Image.open(os.path.join(ROOT, "store", "app_icon_1024.png")).convert("RGB")
    icon.resize((512, 512), Image.LANCZOS).save(os.path.join(OUT, "icon_512.png"))
    print("icon_512.png")


def screenshots():
    out_dir = os.path.join(OUT, "screenshots")
    os.makedirs(out_dir, exist_ok=True)
    files = sorted(glob.glob(os.path.join(SHOTS_IN, "*.png")))
    if not files:
        print("no screenshots in store/screenshots — capture them first")
        return
    for path in files:
        name = os.path.splitext(os.path.basename(path))[0]
        shot = Image.open(path).convert("RGB")
        # Drop the device status bar: the clock and battery add nothing.
        shot = shot.crop((0, round(shot.size[1] * 0.036), shot.size[0], shot.size[1]))
        w, h = Image.open(path).size
        band = round(h * 0.13)
        canvas = maze_pattern(gradient((w, h), GREEN_LIGHT, GREEN_DARK),
                              alpha=40, width=16).convert("RGB")
        # Device capture, shrunk to leave room for the caption band.
        inner = shot.resize((round(w * 0.9), round((h - band) * 0.9)), Image.LANCZOS)
        x = (w - inner.size[0]) // 2
        y = band + (h - band - inner.size[1]) // 2
        frame = Image.new("RGB", (inner.size[0] + 12, inner.size[1] + 12), INK)
        canvas.paste(frame, (x - 6, y - 6))
        canvas.paste(inner, (x, y))

        d = ImageDraw.Draw(canvas)
        caption = CAPTIONS.get(name, "")
        if caption:
            # Shrink the caption until it fits the banner width.
            size = round(band * 0.36)
            fnt = font(size)
            while size > 20 and d.textlength(caption, font=fnt) > w * 0.9:
                size -= 2
                fnt = font(size)
            outlined_text(d, (w // 2, band // 2), caption, fnt, CREAM, INK, 6, anchor="mm")
        canvas.save(os.path.join(out_dir, f"{name}.png"))
        print(f"screenshots/{name}.png  {canvas.size[0]}x{canvas.size[1]}")


if __name__ == "__main__":
    os.makedirs(OUT, exist_ok=True)
    store_icon()
    feature_graphic()
    screenshots()
