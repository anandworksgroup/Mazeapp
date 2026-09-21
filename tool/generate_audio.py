"""Synthesises every sound and the music loop bundled with the app.

All audio is generated from code so the game ships original, license-free
sound with no downloads. Re-run after changing a sound:

    python tool/generate_audio.py
"""
import math
import os
import random
import struct
import wave

RATE = 22050
ROOT = os.path.join(os.path.dirname(__file__), "..", "assets")


def note(name):
    names = {"C": 0, "C#": 1, "D": 2, "D#": 3, "E": 4, "F": 5, "F#": 6,
             "G": 7, "G#": 8, "A": 9, "A#": 10, "B": 11}
    pitch, octave = name[:-1], int(name[-1])
    semis = names[pitch] + (octave - 4) * 12 - 9
    return 440.0 * 2 ** (semis / 12)


def tone(freq, dur, vol=0.5, shape="sine", attack=0.005, release=None,
         slide_to=None, harmonics=()):
    n = int(RATE * dur)
    release = dur * 0.8 if release is None else release
    out = []
    phase = 0.0
    for i in range(n):
        t = i / RATE
        f = freq if slide_to is None else freq + (slide_to - freq) * (i / n)
        phase += 2 * math.pi * f / RATE
        if shape == "sine":
            v = math.sin(phase)
        elif shape == "triangle":
            v = 2 / math.pi * math.asin(math.sin(phase))
        elif shape == "square":
            v = 0.6 if math.sin(phase) >= 0 else -0.6
        else:
            v = math.sin(phase)
        for mult, amp in harmonics:
            v += amp * math.sin(phase * mult)
        env = min(1.0, t / attack) if attack > 0 else 1.0
        tail = dur - t
        if tail < release:
            env *= max(0.0, tail / release) ** 1.5
        out.append(v * env * vol)
    return out


def silence(dur):
    return [0.0] * int(RATE * dur)


def mix(*tracks):
    n = max(len(t) for t in tracks)
    return [sum(t[i] for t in tracks if i < len(t)) for i in range(n)]


def place(buf, samples, at):
    start = int(at * RATE)
    if len(buf) < start + len(samples):
        buf.extend([0.0] * (start + len(samples) - len(buf)))
    for i, s in enumerate(samples):
        buf[start + i] += s


def write(path, samples, peak=0.85):
    full = os.path.join(ROOT, path)
    os.makedirs(os.path.dirname(full), exist_ok=True)
    top = max(1e-9, max(abs(s) for s in samples))
    scale = min(1.0, peak / top)
    with wave.open(full, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(b"".join(
            struct.pack("<h", int(max(-1, min(1, s * scale)) * 32767))
            for s in samples))
    print(f"wrote {path} ({len(samples) / RATE:.2f}s)")


def sfx():
    write("sounds/button_click.wav",
          tone(880, 0.07, 0.6, slide_to=620, release=0.06), peak=0.6)
    write("sounds/movement.wav",
          tone(520, 0.045, 0.35, "triangle", release=0.04), peak=0.35)
    write("sounds/blocked.wav",
          tone(190, 0.13, 0.5, "square", slide_to=120, release=0.1), peak=0.45)

    goal = []
    for i, n in enumerate(["C5", "E5", "G5", "C6"]):
        place(goal, tone(note(n), 0.16, 0.5, harmonics=((2, 0.2),)), i * 0.075)
    write("sounds/goal.wav", goal)

    success = []
    for i, n in enumerate(["G4", "C5", "E5", "G5"]):
        place(success, tone(note(n), 0.14, 0.45, "triangle"), i * 0.09)
    chord = mix(*[tone(note(n), 0.75, 0.3, harmonics=((2, 0.15), (3, 0.05)),
                       release=0.6) for n in ["C5", "E5", "G5", "C6"]])
    place(success, chord, 0.36)
    write("sounds/success.wav", success)

    unlock = []
    for i in range(7):
        place(unlock, tone(1100 + i * 190, 0.12, 0.35, release=0.1), i * 0.045)
    write("sounds/unlock.wav", unlock)

    ach = []
    place(ach, tone(note("G5"), 0.5, 0.45, harmonics=((2, 0.3), (3, 0.1))), 0)
    place(ach, tone(note("D6"), 0.7, 0.45, harmonics=((2, 0.3), (3, 0.1))), 0.14)
    write("sounds/achievement.wav", ach)


def music():
    """A calm 8-bar loop in C major pentatonic. Seeded so it is reproducible."""
    rng = random.Random(7)
    bpm = 96
    beat = 60 / bpm
    bars = 8
    total = bars * 4 * beat
    buf = silence(total + 0.5)

    chords = [["C3", "G3", "E4"], ["A2", "E3", "C4"], ["F2", "C3", "A3"],
              ["G2", "D3", "B3"]] * 2
    for bar, chord in enumerate(chords):
        t0 = bar * 4 * beat
        for n in chord:
            place(buf, tone(note(n), 4 * beat, 0.07, attack=0.3, release=1.2),
                  t0)
        for b in range(4):
            place(buf, tone(note(chord[0]), beat * 0.9, 0.12, "triangle",
                            release=beat * 0.7), t0 + b * beat)

    scale = ["C5", "D5", "E5", "G5", "A5", "C6"]
    idx = 2
    t = 0.0
    while t < total - beat:
        length = rng.choice([0.5, 0.5, 1, 1, 1.5, 2]) * beat
        idx = max(0, min(len(scale) - 1, idx + rng.choice([-2, -1, 1, 1, 2])))
        if rng.random() > 0.15:
            place(buf, tone(note(scale[idx]), length * 0.95, 0.14,
                            harmonics=((2, 0.12),), release=length * 0.6), t)
        t += length

    # Crossfade the tail into the head so the loop point is seamless.
    loop_len = int(total * RATE)
    tail = buf[loop_len:]
    for i, s in enumerate(tail):
        buf[i] += s
    write("music/theme.wav", buf[:loop_len], peak=0.5)


if __name__ == "__main__":
    sfx()
    music()
