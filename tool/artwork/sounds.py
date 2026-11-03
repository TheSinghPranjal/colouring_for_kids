"""Synthesises the app's soft sound effects (original, generated in code)."""
import math, os, random, struct, wave

RATE = 22050
OUT = os.path.join(os.path.dirname(__file__), "..", "..", "assets", "sounds")


def write(name, samples, volume):
    os.makedirs(OUT, exist_ok=True)
    with wave.open(os.path.join(OUT, name), "w") as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(RATE)
        w.writeframes(b"".join(struct.pack("<h", int(max(-1, min(1, s)) * 32767 * volume)) for s in samples))


def env(i, n, attack=0.01, release=0.6):
    t = i / RATE; dur = n / RATE
    a = min(1, t / attack) if attack else 1
    r = math.exp(-t / (dur * release))
    return a * r


def tone(freqs, dur, attack=0.005, release=0.35, glide=0.0):
    n = int(RATE * dur); out = []
    for i in range(n):
        t = i / RATE
        s = sum(math.sin(2 * math.pi * f * (1 + glide * t) * t) * amp for f, amp in freqs)
        out.append(s * env(i, n, attack, release))
    return out

# Soft wooden "tick" for picking a colour.
write("tap.wav", tone([(880, 0.6), (1320, 0.25)], 0.09, 0.002, 0.18), 0.35)
# Gentle rising "bloop" for filling a region.
write("fill.wav", tone([(520, 0.7), (780, 0.2)], 0.22, 0.004, 0.3, glide=1.6), 0.4)
# Quiet brush swish: filtered noise.
random.seed(4)
n = int(RATE * 0.18); prev = 0; sw = []
for i in range(n):
    prev = prev * 0.92 + random.uniform(-1, 1) * 0.08
    sw.append(prev * 3 * math.sin(math.pi * i / n))
write("brush.wav", sw, 0.3)
# Two-note chime for a saved picture.
c = tone([(660, 0.5), (1320, 0.15)], 0.45, 0.005, 0.4)
d = tone([(990, 0.5), (1980, 0.12)], 0.6, 0.005, 0.45)
gap = int(RATE * 0.12)
write("chime.wav", [c[i] if i < len(c) else 0 for i in range(gap + len(d))][:gap] + [ (c[gap + i] if gap + i < len(c) else 0) + d[i] for i in range(len(d))], 0.35)
# Soft "pop" for stickers.
write("pop.wav", tone([(600, 0.8)], 0.12, 0.002, 0.2, glide=-2.5), 0.35)
